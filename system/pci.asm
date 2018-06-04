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



PCIDetect:
	; Pokes the 32-bit I/O register at 0x0CF8 to see if there's a PCI controller there
	;
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



PCIDriverSearch:
	; Scans all the drivers in the kernel to see if any match the class/subclass/progif given
	;
	;  input:
	;   PCI Class value
	;   PCI Subclass value
	;   PCI ProgIf value
	;
	;  output:
	;   Match code
	;
	;  changes: eax, ebx, ecx, edx

	pop eax
	pop dword [.PCIBus]
	pop dword [.PCIDevice]
	pop dword [.PCIFunction]
	push eax

jmp $
	; push the return value on the stack and exit
	pop eax
	push ebx
	push eax
ret
.PCIBus											dd 0x00000000
.PCIDevice										dd 0x00000000
.PCIFunction									dd 0x00000000



PCIGetDeviceCount:
	; Returns the total number of devices (functions) across all PCI busses in the system
	;
	;  input:
	;   n/a
	;
	;  output:
	;   PCI device count
	;
	;  changes: eax, ebx, ecx, edx

ret



PCILoadDrivers:
	; Loads drivers for all PCI devices
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: 

	; cycle through all busses and load drivers for all device functions found
	mov ecx, 0
	.ProbeBusLoop:
		mov [.PCIBus], ecx
		mov ecx, 0
		.ProbeDeviceLoop:
			mov [.PCIDevice], ecx
			mov ecx, 0
			.ProbeFunctionLoop:
				mov [.PCIFunction], ecx

				; load the first register (vendor and device IDs) for this device
				pusha
				push 0
				push ecx
				push dword [.PCIDevice]
				push dword [.PCIBus]
				call PCILiveRead
				pop dword [.temp]
				popa

				; if the vendor ID is 0xFFFF, it's invalid
				cmp word [.temp], 0xFFFF
				je .InfoSkip
					; if we get here, the device is valid
					; save all values
					pusha

					; maybe make these three separate routines in the future for handiness?
					; get the class, subclass, and progif values for this device so we can search for a suitable driver
					push dword 0x00000002
					push dword [.PCIFunction]
					push dword [.PCIDevice]
					push dword [.PCIBus]
					call PCIReadDWord
					pop eax

					; juggle the bytes here to transfer the proper data into our variables
					shr eax, 8
					mov ebx, eax
					and ebx, 0x000000FF
					mov dword [.PCIProgIf], ebx

					shr eax, 8
					mov ebx, eax
					and ebx, 0x000000FF
					mov dword [.PCISubclass], ebx

					shr eax, 8
					mov ebx, eax
					and ebx, 0x000000FF
					mov dword [.PCIClass], ebx



					; search for precise driver first for this exact class/subclass/prog if 
					push dword [.PCIFunction]
					push dword [.PCIDevice]
					push dword [.PCIBus]
					call PCIDriverSearch
					pop eax
					; test the result of the search

					; didn't find one, so search for a driver that handles the entire subclass (all prog if values)
					push dword [.PCIFunction]
					push dword [.PCIDevice]
					push dword [.PCIBus]
					call PCIDriverSearch
					pop eax
					; test the result of the search

					; still nothing?!? ok, search for a driver for the entire class (all subclasses and prog if values)
					push dword [.PCIFunction]
					push dword [.PCIDevice]
					push dword [.PCIBus]
					call PCIDriverSearch
					pop eax
					; test the result of the search

					; what?? ok, fine. there's just no driver in the kernel for this device

					; restore the previous values
					popa

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

	jmp $

ret
.PCIBus											dd 0x00000000
.PCIDevice										dd 0x00000000
.PCIFunction									dd 0x00000000
.writeAddress									dd 0x00000000
.temp											dd 0x00000000
.PCIClass										dd 0x00000000
.PCISubclass									dd 0x00000000
.PCIProgIf										dd 0x00000000



PCIInitBus:
	; Scans all PCI busses and shadows all data to RAM
	;
	;  input:
	;   n/a
	;
	;  output:
	;   address in RAM of shadowed data table
	;
	;  changes: 

	; allocate 16.5 MB - the largest possible number if all device slots would ever happen to be filled
	push dword 17301504
	call MemAllocate
	pop eax

	; save that address to the system struct for later use by the rest of the system
	mov [tSystem.PCITableAddress], eax

	; make a copy of that address for our use here
	mov [.writeAddress], eax

	; add a check here to make sure we didn't get a null address

	; cycle through all busses and devices on those busses, copying all registers into RAM
	mov ecx, 0
	.ProbeBusLoop:
		mov [.PCIBus], ecx
		mov ecx, 0
		.ProbeDeviceLoop:
			mov [.PCIDevice], ecx
			mov ecx, 0
			.ProbeFunctionLoop:
				mov [.PCIFunction], ecx

				; load the first register (vendor and device IDs) for this device
				pusha
				push 0
				push ecx
				push dword [.PCIDevice]
				push dword [.PCIBus]
				call PCILiveRead
				pop dword [.temp]
				popa

				; if the vendor ID is 0xFFFF, it's invalid
				cmp word [.temp], 0xFFFF
				je .InfoSkip
					; if we get here, the device is valid, so let's copy all the registers
					mov eax, [.temp]

					; preserve our loop counter
					push ecx

					; set the number of reads we need to do
					mov ecx, 64

					; set up the target address
					mov dword esi, [.writeAddress]

					; copy PCI bus location info to the table
					mov eax, [.PCIBus]
					mov [esi], eax
					add esi, 4

					mov eax, [.PCIDevice]
					mov [esi], eax
					add esi, 4

					mov eax, [.PCIFunction]
					mov [esi], eax
					add esi, 4

					; start the loop to copy all the info
					.ReadLoop:
						; adjust ecx to point to the correct PCI register
						dec ecx

						pusha

						; get the register
						push ecx
						push dword [.PCIFunction]
						push dword [.PCIDevice]
						push dword [.PCIBus]
						call PCILiveRead
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

						; write the register to the struct and increment destination
						mov [edi], eax

						; increment our destination address
						add dword [.writeAddress], 4

					loop .ReadLoop

					; increment our destination address again to set up for the next device
					add dword [.writeAddress], 12

					; increment global device counter
					inc dword [tSystem.PCIDeviceCount]

					; restore the previous loop counter value
					pop ecx

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

	add esi, 256

	; lay down some 0xFF to mark the end of the PCI table
	mov eax, 0xFFFFFFFF
	mov [esi], eax
	add esi, 4
	mov [esi], eax
	add esi, 4
	mov [esi], eax

	add esi, 4
	mov ecx, 256
	mov bl, 0xFF

	.FinalFillLoop:
		mov byte [esi], bl
		inc esi
	loop .FinalFillLoop

	; all done now, so we can shrink the table's RAM block down to only the size we actually needed, and then exit
	call MemResize
ret
.PCIBus											dd 0x00000000
.PCIDevice										dd 0x00000000
.PCIFunction									dd 0x00000000
.writeAddress									dd 0x00000000
.temp											dd 0x00000000



PCILiveRead:
	; Reads a 32-bit register value from the PCI target specified
	;
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



PCILiveWrite:
	; Writes a 32-bit value to the target PCI register specified
	;
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



PCIReadAll:
	; Gets all info for the specified PCI device and fills it into the struct at the given address
	;
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



PCIReadByte:
	; Reads a byte register from the PCI target specified
	;
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;
	;  output:
	;   Register value
	;
	;  changes: 

	; scan the list for the proper device

ret



PCIReadWord:
	; Reads a word register from the PCI target specified
	;
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;
	;  output:
	;   Register value
	;
	;  changes: 

	; scan the list for the proper device

ret



PCIReadDWord:
	; Reads a dword register from the PCI target specified
	;
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;
	;  output:
	;   Register value
	;
	;  changes: 

	; get the data for what we're supposed to search for
	pop edx
	pop dword [.PCIBus]
	pop dword [.PCIDevice]
	pop dword [.PCIFunction]
	pop dword [.PCIRegister]
	push edx

	; scan the list for the proper device
	mov ecx, dword [tSystem.PCITableAddress]

	.RegisterSearchLoop:
		; set the check flag for the following tests
		mov eax, 0x00000000

		; read the next dword from the table
		mov edx, [ecx]

		; see if it's an invalid bus
		cmp edx, 0xFFFFFFFF
		je .PCISearchExit

		; see if we have a match
		cmp edx, [.PCIBus]
		je .PCISearchSkip1

		; if we get here, it wasn't a match, so we adjust the flag register
		or eax, 00000000000000000000000000000001b
		.PCISearchSkip1:



		; increment ecx to check the next number
		add ecx, 4

		; read the next dword from the table
		mov edx, [ecx]

		; see if it's an invalid device
		cmp edx, 0xFFFFFFFF
		je .PCISearchExit

		; see if we have a match
		cmp edx, [.PCIDevice]
		je .PCISearchSkip2

		; if we get here, it wasn't a match, so we adjust the flag register
		or eax, 00000000000000000000000000000010b
		.PCISearchSkip2:



		; increment ecx to check the next number
		add ecx, 4

		; read the next dword from the table
		mov edx, [ecx]

		; see if it's an invalid function
		cmp edx, 0xFFFFFFFF
		je .PCISearchExit

		; see if we have a match
		cmp edx, [.PCIFunction]
		je .PCISearchSkip3

		; if we get here, it wasn't a match, so we adjust the flag register
		or eax, 00000000000000000000000000000100b
		.PCISearchSkip3:



		; check the result of the previous tests
		cmp eax, 0x00000000
		jne .PCISearchNoMatch


		; if we get here, it's a match
		; adjust ecx to point to first register
		add ecx, 4

		; adjust ecx to point to the specific register requested
		mov edx, dword [.PCIRegister]

		; multiply the register by 4 to mimic how the real PCI system handles register numbers
		rol edx, 2

		; truncate edx for safety
		and edx, 0xFF

		; add the register offset to the table address to pinpoint the register we need
		add ecx, edx

		; load the register data
		mov edx, [ecx]

		; we got the register value in edx, so we can exit
		jmp .PCISearchExit



		.PCISearchNoMatch:
		; adjust the ecx pointer to the next device in the table
		add ecx, 260

	jmp .RegisterSearchLoop

	.PCISearchExit:

	; fixup the return value and exit
	pop ecx
	push edx
	push ecx
ret
.PCIBus											dd 0x00000000
.PCIDevice										dd 0x00000000
.PCIFunction									dd 0x00000000
.PCIRegister									dd 0x00000000



PCIWriteByte:
	; Writes a byte value to the PCI target specified
	;
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;	Register value
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, dx, edi
ret



PCIWriteWord:
	; Writes a word value to the PCI target specified
	;
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;	Register value
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, dx, edi
ret



PCIWriteDword:
	; Writes a dword value to the PCI target specified
	;
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;	Register value
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, dx, edi
ret



; for PCI bus access
PCIAddressPort									dw 0x0CF8
PCIDataPort										dw 0x0CFC
