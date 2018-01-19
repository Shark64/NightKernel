; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; pci.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



bits 32



PCIGetDeviceCount:
	; Returns the total number of devices (functions) across all PCI busses in the system
	;  input:
	;   n/a
	;
	;  output:
	;   PCI device count
	;
	;  changes: eax, ebx, ecx, edx

	; first, clear the counter
	mov dword [.PCIDevices], 0

	mov ecx, 0
	.ProbeBusLoop:
		mov [.PCIBus], ecx
		mov ecx, 0
		.ProbeDeviceLoop:
			mov [.PCIDevice], ecx
			mov ecx, 0
			.ProbeFunctionLoop:
				mov [.PCIFunction], ecx
				pusha
				mov eax, PCIDeviceInfo
				push eax
				push ecx
				push dword [.PCIDevice]
				push dword [.PCIBus]
				call PCIReadAll
				popa

				; if the vendor ID is 0xFFFF, it's invalid
				cmp word [PCIDeviceInfo.PCIVendorID], 0xFFFF
				je .InfoSkip
					; if we get here, the device is valid, so let's increment the counter
					inc dword [.PCIDevices]
				.InfoSkip:
			inc ecx
			cmp ecx, 8
			jne .ProbeFunctionLoop

		mov ecx, [.PCIDevice]
		inc ecx
		cmp ecx, 32
		jne .ProbeDeviceLoop

	mov ecx, [.PCIBus]
	inc ecx
	cmp ecx, 256
	jne .ProbeBusLoop

	; all done with the loops, so we load up the return value and exit
	pop eax
	push dword [.PCIDevices]
	push eax
ret
.PCIDevices										dd 0x00000000
.PCIBus											dd 0x00000000
.PCIDevice										dd 0x00000000
.PCIFunction									dd 0x00000000



PCIDetect:
	; Pokes the 32-bit I/O register at 0x0CF8 to see if there's a PCI controller there
	;  input:
	;   n/a
	;
	;  output:
	;   PCI controller presence
	;		0 = false
	;		1 = true
	;
	;  changes: eax, ebx, ecx, edx

	pop ecx

	; write a vcalue to the port
	mov dx, [PCIAddressPort]
	mov eax, 0x19801988
	out dx, eax

	; clear eax for sanity and to give the previous write time to "settle in"
	mov eax, 0x00000000
	
	; read it back
	in eax, dx

	; now compare to see what we got
	cmp eax, 0x19801988
	je .ItMatched
	push dword [kFalse]
	jmp .AllDone

	.ItMatched:
	push dword [kTrue]

	.AllDone:
	push ecx
ret



PCIReadAll:
	; Gets all info for the specified PCI device and fills it into the struct at the given address
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI info struct address
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, ecx, edx, esi, edi

	pop edi
	pop dword [.bus]
	pop dword [.device]
	pop dword [.function]
	pop esi
	push edi

	; set the number of reads we need to do
	mov ecx, 64

	; start the loop to copy all the info
	.ReadLoop:
		; adjust ecx to point to the correct PCI register
		dec ecx

		pusha

		; get the register
		push ecx
		push dword [.function]
		push dword [.device]
		push dword [.bus]
		call PCIReadDWord
		pop eax

		; fixup for eax
		mov [.temp], eax
		popa
		mov eax, [.temp]

		; calculate the write address
		mov edi, esi
		mov edx, ecx
		shl edx, 2
		add edi, edx

		; adjust ecx back to normal
		inc ecx

		; write the register to the struct
		mov [edi], eax

	loop .ReadLoop
ret
.bus											dd 0x00000000
.device											dd 0x00000000
.function										dd 0x00000000
.temp											dd 0x00000000



PCIReadDeviceNumber:
	; Returns the total number of devices (functions) across all PCI busses in the system
	;  input:
	;   Device number (obtain count of devices first from PCIGetDeviceCount())
	;	PCI info struct address
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, ecx, edx

	; get the device number from the stack
	pop dword [.returnAddress]
	pop dword [.deviceNumber]
	pop dword [.destAddress]

	; see if the device requested is outside the valid number of devices
	mov eax, dword [tSystem.PCIDeviceCount]
	cmp dword [.deviceNumber], eax
	jbe .ValidRequest
	jmp .Exit

	.ValidRequest:
	; first, clear the counter and BDF values
	mov dword [.PCIDevices], 0
	mov dword [.PCIBus], 0
	mov dword [.PCIDevice], 0
	mov dword [.PCIFunction], 0

	mov ecx, 0
	.ProbeBusLoop:
		mov [.PCIBus], ecx
		mov ecx, 0
		.ProbeDeviceLoop:
			mov [.PCIDevice], ecx
			mov ecx, 0
			.ProbeFunctionLoop:
				mov [.PCIFunction], ecx
				pusha
				mov eax, PCIDeviceInfo
				push eax
				push ecx
				push dword [.PCIDevice]
				push dword [.PCIBus]
				call PCIReadAll
				popa

				; if the vendor ID is 0xFFFF, it's invalid
				cmp word [PCIDeviceInfo.PCIVendorID], 0xFFFF
				je .InfoSkip

					; if we get here, the device is valid, so let's increment the counter
					inc dword [.PCIDevices]

					; see if we're on the right device
					mov eax, dword [.deviceNumber]
					cmp dword [.PCIDevices], eax
					jne .InfoSkip

					; if we get here, the device matched, so we copy the data to the address specified
					push 256
					push dword [.destAddress]
					push PCIDeviceInfo
					call MemCopy

					; And we're all done! No need to hang around this dusty old town.
					jmp .Exit

				.InfoSkip:
			inc ecx
			cmp ecx, 8
			jne .ProbeFunctionLoop

		mov ecx, [.PCIDevice]
		inc ecx
		cmp ecx, 32
		jne .ProbeDeviceLoop

	mov ecx, [.PCIBus]
	inc ecx
	cmp ecx, 256
	jne .ProbeBusLoop

.Exit:
push dword [.PCIBus]
push dword [.PCIDevice]
push dword [.PCIFunction]
push dword [.returnAddress]
ret
.PCIDevices										dd 0x00000000
.PCIBus											dd 0x00000000
.PCIDevice										dd 0x00000000
.PCIFunction									dd 0x00000000
.deviceNumber									dd 0x00000000
.destAddress									dd 0x00000000
.returnAddress									dd 0x00000000



PCIReadByte:
	; Reads an 8-bit register value from the PCI target specified
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;
	;  output:
	;   register value
	;
	;  changes: eax, ebx, dx, edi

	pop edi

	; we start by building a value out of the bus, device, function and register values provided
	mov eax, 0x00000000							; clear the destination
	pop ebx										; load the PCI bus provided
	and ebx, 0x000000FF							; PCI registers are 8 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 5									; shift left 5 bits to get ready for the next section

	pop ebx										; load the PCI device provided
	and ebx, 0x0000001F							; PCI devices are 5 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 3									; shift left 3 bits to get ready for the next section

	pop ebx										; load the PCI function provided
	and ebx, 0x00000007							; PCI functions are 3 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 6									; shift left 6 bits to get ready for the next section

	pop ebx										; load the PCI registers provided
	and ebx, 0x0000003F							; PCI registers are 6 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 2									; shift left 2 bits to finalize and align

	or eax, 0x80000000							; set bit 31 to enable configuration

	; write the value we just built to select the proper target
	mov dx, [PCIAddressPort]
	out dx, eax

	; read the register back
	mov dx, [PCIDataPort]
	mov eax, 0x00000000
	in al, dx

	;push the result
	push eax

	; restore the return address
	push edi
ret



PCIReadWord:
	; Reads a 16-bit register value from the PCI target specified
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;
	;  output:
	;   register value
	;
	;  changes: eax, ebx, dx, edi

	pop edi

	; we start by building a value out of the bus, device, function and register values provided
	mov eax, 0x00000000							; clear the destination
	pop ebx										; load the PCI bus provided
	and ebx, 0x000000FF							; PCI registers are 8 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 5									; shift left 5 bits to get ready for the next section

	pop ebx										; load the PCI device provided
	and ebx, 0x0000001F							; PCI devices are 5 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 3									; shift left 3 bits to get ready for the next section

	pop ebx										; load the PCI function provided
	and ebx, 0x00000007							; PCI functions are 3 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 6									; shift left 6 bits to get ready for the next section

	pop ebx										; load the PCI registers provided
	and ebx, 0x0000003F							; PCI registers are 6 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 2									; shift left 2 bits to finalize and align

	or eax, 0x80000000							; set bit 31 to enable configuration

	; write the value we just built to select the proper target
	mov dx, [PCIAddressPort]
	out dx, eax

	; read the register back
	mov dx, [PCIDataPort]
	mov eax, 0x00000000
	in ax, dx

	;push the result
	push eax

	; restore the return address
	push edi
ret



PCIReadDWord:
	; Reads a 32-bit register value from the PCI target specified
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;
	;  output:
	;   register value
	;
	;  changes: eax, ebx, dx, edi

	pop edi

	; we start by building a value out of the bus, device, function and register values provided
	mov eax, 0x00000000							; clear the destination
	pop ebx										; load the PCI bus provided
	and ebx, 0x000000FF							; PCI registers are 8 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 5									; shift left 5 bits to get ready for the next section

	pop ebx										; load the PCI device provided
	and ebx, 0x0000001F							; PCI devices are 5 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 3									; shift left 3 bits to get ready for the next section

	pop ebx										; load the PCI function provided
	and ebx, 0x00000007							; PCI functions are 3 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 6									; shift left 6 bits to get ready for the next section

	pop ebx										; load the PCI registers provided
	and ebx, 0x0000003F							; PCI registers are 6 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 2									; shift left 2 bits to finalize and align

	or eax, 0x80000000							; set bit 31 to enable configuration

	; write the value we just built to select the proper target
	mov dx, [PCIAddressPort]
	out dx, eax

	; read the register back
	mov dx, [PCIDataPort]
	in eax, dx

	;push the result
	push eax

	; restore the return address
	push edi
ret



PCIWriteByte:
	; Writes an 8-bit value to the target PCI register specified
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;	value to write
	;
	;  output:
	;   n/a
	;
	;  changes: eax, dx, edi

	pop edi

	; we start by building a value out of the bus, device, function and register values provided
	mov eax, 0x00000000							; clear the destination
	pop ebx										; load the PCI bus provided
	and ebx, 0x000000FF							; PCI registers are 8 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 5									; shift left 5 bits to get ready for the next section

	pop ebx										; load the PCI device provided
	and ebx, 0x0000001F							; PCI devices are 5 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 3									; shift left 3 bits to get ready for the next section

	pop ebx										; load the PCI function provided
	and ebx, 0x00000007							; PCI functions are 3 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 6									; shift left 6 bits to get ready for the next section

	pop ebx										; load the PCI registers provided
	and ebx, 0x0000003F							; PCI registers are 6 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 2									; shift left 2 bits to finalize and align

	or eax, 0x80000000							; set bit 31 to enable configuration

	; write the value we just built to select the proper target
	mov dx, [PCIAddressPort]
	out dx, eax

	; get the value to write from the stack
	pop eax

	; write the data register
	mov dx, [PCIDataPort]
	out dx, al

	; restore the return address
	push edi
ret



PCIWriteWord:
	; Writes a 16-bit value to the target PCI register specified
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;	value to write
	;
	;  output:
	;   n/a
	;
	;  changes: eax, dx, edi

	pop edi

	; we start by building a value out of the bus, device, function and register values provided
	mov eax, 0x00000000							; clear the destination
	pop ebx										; load the PCI bus provided
	and ebx, 0x000000FF							; PCI registers are 8 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 5									; shift left 5 bits to get ready for the next section

	pop ebx										; load the PCI device provided
	and ebx, 0x0000001F							; PCI devices are 5 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 3									; shift left 3 bits to get ready for the next section

	pop ebx										; load the PCI function provided
	and ebx, 0x00000007							; PCI functions are 3 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 6									; shift left 6 bits to get ready for the next section

	pop ebx										; load the PCI registers provided
	and ebx, 0x0000003F							; PCI registers are 6 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 2									; shift left 2 bits to finalize and align

	or eax, 0x80000000							; set bit 31 to enable configuration

	; write the value we just built to select the proper target
	mov dx, [PCIAddressPort]
	out dx, eax

	; get the value to write from the stack
	pop eax

	; write the data register
	mov dx, [PCIDataPort]
	out dx, ax

	; restore the return address
	push edi
ret



PCIWriteDWord:
	; Writes a 32-bit value to the target PCI register specified
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;	value to write
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, dx, edi

	pop edi

	; we start by building a value out of the bus, device, function and register values provided
	mov eax, 0x00000000							; clear the destination
	pop ebx										; load the PCI bus provided
	and ebx, 0x000000FF							; PCI registers are 8 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 5									; shift left 5 bits to get ready for the next section

	pop ebx										; load the PCI device provided
	and ebx, 0x0000001F							; PCI devices are 5 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 3									; shift left 3 bits to get ready for the next section

	pop ebx										; load the PCI function provided
	and ebx, 0x00000007							; PCI functions are 3 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 6									; shift left 6 bits to get ready for the next section

	pop ebx										; load the PCI registers provided
	and ebx, 0x0000003F							; PCI registers are 6 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 2									; shift left 2 bits to finalize and align

	or eax, 0x80000000							; set bit 31 to enable configuration

	; write the value we just built to select the proper target
	mov dx, [PCIAddressPort]
	out dx, eax

	; get the value to write from the stack
	pop eax

	; write the data register
	mov dx, [PCIDataPort]
	out dx, eax

	; restore the return address
	push edi
ret



; for PCI bus access
PCIAddressPort									dw 0x0CF8
PCIDataPort										dw 0x0CFC

; the struct to hold all data about a single PCI device
PCIDeviceInfo:
.PCIVendorID									dw 0x0000
.PCIDeviceID									dw 0x0000
.PCICommand										dw 0x0000
.PCIStatus										dw 0x0000
.PCIRevision									db 0x00
.PCIProgIf										db 0x00
.PCISubclass									db 0x00
.PCIClass										db 0x00
.PCICacheLineSize								db 0x00
.PCILatencyTimer								db 0x00
.PCIHeaderType									db 0x00
.PCIBIST										db 0x00
.PCIBAR0										dd 0x00000000
.PCIBAR1										dd 0x00000000
.PCIBAR2										dd 0x00000000
.PCIBAR3										dd 0x00000000
.PCIBAR4										dd 0x00000000
.PCIBAR5										dd 0x00000000
.PCICardbusCISPointer							dd 0x00000000
.PCISubsystemVendorID							dw 0x0000
.PCISubsystemID									dw 0x0000
.PCIExpansionROMBaseAddress						dd 0x00000000
.PCICapabilitiesPointer							db 0x00
.PCIReserved									times 7 db 0x00
.PCIInterruptLine								db 0x00
.PCIInterruptPin								db 0x00
.PCIMaxGrant									db 0x00
.PCIMaxLatency									db 0x00
.PCIRegisters									times 192 db 0x00
PCIClass:
.00$											db 'Unclassified device                ', 0x00
.01$											db 'Mass Storage Controller            ', 0x00
.02$											db 'Network Controller                 ', 0x00
.03$											db 'Display Controller                 ', 0x00
.04$											db 'Multimedia Controller              ', 0x00
.05$											db 'Memory Controller                  ', 0x00
.06$											db 'Bridge Device                      ', 0x00
.07$											db 'Simple Communication Controller    ', 0x00
.08$											db 'Generic System Peripheral          ', 0x00
.09$											db 'Input Device                       ', 0x00
.0A$											db 'Docking Station                    ', 0x00
.0B$											db 'Processor                          ', 0x00
.0C$											db 'USB Controller                     ', 0x00
.0D$											db 'Wireless Controller                ', 0x00
.0E$											db 'Intelligent I/O Controller         ', 0x00
.0F$											db 'Satellite Communications Controller', 0x00
.10$											db 'Encryption Controller              ', 0x00
.11$											db 'Signal Processing Controller       ', 0x00
.12$											db 'Processing Accelerator             ', 0x00
.13$											db 'Non-Essential Instrumentation      ', 0x00
.14$											db '                                   ', 0x00
.15$											db '                                   ', 0x00
.16$											db '                                   ', 0x00
.17$											db '                                   ', 0x00
.18$											db '                                   ', 0x00
.19$											db '                                   ', 0x00
.1A$											db '                                   ', 0x00
.1B$											db '                                   ', 0x00
.1C$											db '                                   ', 0x00
.1D$											db '                                   ', 0x00
.1E$											db '                                   ', 0x00
.1F$											db '                                   ', 0x00
.20$											db '                                   ', 0x00
.21$											db '                                   ', 0x00
.22$											db '                                   ', 0x00
.23$											db '                                   ', 0x00
.24$											db '                                   ', 0x00
.25$											db '                                   ', 0x00
.26$											db '                                   ', 0x00
.27$											db '                                   ', 0x00
.28$											db '                                   ', 0x00
.29$											db '                                   ', 0x00
.2A$											db '                                   ', 0x00
.2B$											db '                                   ', 0x00
.2C$											db '                                   ', 0x00
.2D$											db '                                   ', 0x00
.2E$											db '                                   ', 0x00
.2F$											db '                                   ', 0x00
.30$											db '                                   ', 0x00
.31$											db '                                   ', 0x00
.32$											db '                                   ', 0x00
.33$											db '                                   ', 0x00
.34$											db '                                   ', 0x00
.35$											db '                                   ', 0x00
.36$											db '                                   ', 0x00
.37$											db '                                   ', 0x00
.38$											db '                                   ', 0x00
.39$											db '                                   ', 0x00
.3A$											db '                                   ', 0x00
.3B$											db '                                   ', 0x00
.3C$											db '                                   ', 0x00
.3D$											db '                                   ', 0x00
.3E$											db '                                   ', 0x00
.3F$											db '                                   ', 0x00
.40$											db 'Coprocessor                        ', 0x00
.41$											db '                                   ', 0x00
.42$											db '                                   ', 0x00
.43$											db '                                   ', 0x00
.44$											db '                                   ', 0x00
.45$											db '                                   ', 0x00
.46$											db '                                   ', 0x00
.47$											db '                                   ', 0x00
.48$											db '                                   ', 0x00
.49$											db '                                   ', 0x00
.4A$											db '                                   ', 0x00
.4B$											db '                                   ', 0x00
.4C$											db '                                   ', 0x00
.4D$											db '                                   ', 0x00
.4E$											db '                                   ', 0x00
.4F$											db '                                   ', 0x00
.50$											db '                                   ', 0x00
.51$											db '                                   ', 0x00
.52$											db '                                   ', 0x00
.53$											db '                                   ', 0x00
.54$											db '                                   ', 0x00
.55$											db '                                   ', 0x00
.56$											db '                                   ', 0x00
.57$											db '                                   ', 0x00
.58$											db '                                   ', 0x00
.59$											db '                                   ', 0x00
.5A$											db '                                   ', 0x00
.5B$											db '                                   ', 0x00
.5C$											db '                                   ', 0x00
.5D$											db '                                   ', 0x00
.5E$											db '                                   ', 0x00
.5F$											db '                                   ', 0x00
.60$											db '                                   ', 0x00
.61$											db '                                   ', 0x00
.62$											db '                                   ', 0x00
.63$											db '                                   ', 0x00
.64$											db '                                   ', 0x00
.65$											db '                                   ', 0x00
.66$											db '                                   ', 0x00
.67$											db '                                   ', 0x00
.68$											db '                                   ', 0x00
.69$											db '                                   ', 0x00
.6A$											db '                                   ', 0x00
.6B$											db '                                   ', 0x00
.6C$											db '                                   ', 0x00
.6D$											db '                                   ', 0x00
.6E$											db '                                   ', 0x00
.6F$											db '                                   ', 0x00
.70$											db '                                   ', 0x00
.71$											db '                                   ', 0x00
.72$											db '                                   ', 0x00
.73$											db '                                   ', 0x00
.74$											db '                                   ', 0x00
.75$											db '                                   ', 0x00
.76$											db '                                   ', 0x00
.77$											db '                                   ', 0x00
.78$											db '                                   ', 0x00
.79$											db '                                   ', 0x00
.7A$											db '                                   ', 0x00
.7B$											db '                                   ', 0x00
.7C$											db '                                   ', 0x00
.7D$											db '                                   ', 0x00
.7E$											db '                                   ', 0x00
.7F$											db '                                   ', 0x00
.80$											db '                                   ', 0x00
.81$											db '                                   ', 0x00
.82$											db '                                   ', 0x00
.83$											db '                                   ', 0x00
.84$											db '                                   ', 0x00
.85$											db '                                   ', 0x00
.86$											db '                                   ', 0x00
.87$											db '                                   ', 0x00
.88$											db '                                   ', 0x00
.89$											db '                                   ', 0x00
.8A$											db '                                   ', 0x00
.8B$											db '                                   ', 0x00
.8C$											db '                                   ', 0x00
.8D$											db '                                   ', 0x00
.8E$											db '                                   ', 0x00
.8F$											db '                                   ', 0x00
.90$											db '                                   ', 0x00
.91$											db '                                   ', 0x00
.92$											db '                                   ', 0x00
.93$											db '                                   ', 0x00
.94$											db '                                   ', 0x00
.95$											db '                                   ', 0x00
.96$											db '                                   ', 0x00
.97$											db '                                   ', 0x00
.98$											db '                                   ', 0x00
.99$											db '                                   ', 0x00
.9A$											db '                                   ', 0x00
.9B$											db '                                   ', 0x00
.9C$											db '                                   ', 0x00
.9D$											db '                                   ', 0x00
.9E$											db '                                   ', 0x00
.9F$											db '                                   ', 0x00
.A0$											db '                                   ', 0x00
.A1$											db '                                   ', 0x00
.A2$											db '                                   ', 0x00
.A3$											db '                                   ', 0x00
.A4$											db '                                   ', 0x00
.A5$											db '                                   ', 0x00
.A6$											db '                                   ', 0x00
.A7$											db '                                   ', 0x00
.A8$											db '                                   ', 0x00
.A9$											db '                                   ', 0x00
.AA$											db '                                   ', 0x00
.AB$											db '                                   ', 0x00
.AC$											db '                                   ', 0x00
.AD$											db '                                   ', 0x00
.AE$											db '                                   ', 0x00
.AF$											db '                                   ', 0x00
.B0$											db '                                   ', 0x00
.B1$											db '                                   ', 0x00
.B2$											db '                                   ', 0x00
.B3$											db '                                   ', 0x00
.B4$											db '                                   ', 0x00
.B5$											db '                                   ', 0x00
.B6$											db '                                   ', 0x00
.B7$											db '                                   ', 0x00
.B8$											db '                                   ', 0x00
.B9$											db '                                   ', 0x00
.BA$											db '                                   ', 0x00
.BB$											db '                                   ', 0x00
.BC$											db '                                   ', 0x00
.BD$											db '                                   ', 0x00
.BE$											db '                                   ', 0x00
.BF$											db '                                   ', 0x00
.C0$											db '                                   ', 0x00
.C1$											db '                                   ', 0x00
.C2$											db '                                   ', 0x00
.C3$											db '                                   ', 0x00
.C4$											db '                                   ', 0x00
.C5$											db '                                   ', 0x00
.C6$											db '                                   ', 0x00
.C7$											db '                                   ', 0x00
.C8$											db '                                   ', 0x00
.C9$											db '                                   ', 0x00
.CA$											db '                                   ', 0x00
.CB$											db '                                   ', 0x00
.CC$											db '                                   ', 0x00
.CD$											db '                                   ', 0x00
.CE$											db '                                   ', 0x00
.CF$											db '                                   ', 0x00
.D0$											db '                                   ', 0x00
.D1$											db '                                   ', 0x00
.D2$											db '                                   ', 0x00
.D3$											db '                                   ', 0x00
.D4$											db '                                   ', 0x00
.D5$											db '                                   ', 0x00
.D6$											db '                                   ', 0x00
.D7$											db '                                   ', 0x00
.D8$											db '                                   ', 0x00
.D9$											db '                                   ', 0x00
.DA$											db '                                   ', 0x00
.DB$											db '                                   ', 0x00
.DC$											db '                                   ', 0x00
.DD$											db '                                   ', 0x00
.DE$											db '                                   ', 0x00
.DF$											db '                                   ', 0x00
.E0$											db '                                   ', 0x00
.E1$											db '                                   ', 0x00
.E2$											db '                                   ', 0x00
.E3$											db '                                   ', 0x00
.E4$											db '                                   ', 0x00
.E5$											db '                                   ', 0x00
.E6$											db '                                   ', 0x00
.E7$											db '                                   ', 0x00
.E8$											db '                                   ', 0x00
.E9$											db '                                   ', 0x00
.EA$											db '                                   ', 0x00
.EB$											db '                                   ', 0x00
.EC$											db '                                   ', 0x00
.ED$											db '                                   ', 0x00
.EE$											db '                                   ', 0x00
.EF$											db '                                   ', 0x00
.F0$											db '                                   ', 0x00
.F1$											db '                                   ', 0x00
.F2$											db '                                   ', 0x00
.F3$											db '                                   ', 0x00
.F4$											db '                                   ', 0x00
.F5$											db '                                   ', 0x00
.F6$											db '                                   ', 0x00
.F7$											db '                                   ', 0x00
.F8$											db '                                   ', 0x00
.F9$											db '                                   ', 0x00
.FA$											db '                                   ', 0x00
.FB$											db '                                   ', 0x00
.FC$											db '                                   ', 0x00
.FD$											db '                                   ', 0x00
.FE$											db '                                   ', 0x00
.FF$											db 'Unassigned class                   ', 0x00
