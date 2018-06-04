; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; debug.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



bits 32



DebugMenu:
	; Implements the in-kernel debugging menu
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a

	; create a new list to hold the PCI device labels if necessary
	cmp byte [.flag], 1
	je .DrawMenu

		push dword 36								; size of each element
		push dword 256								; number of elements
		call LMListNew
		pop edx
		mov dword [PCITable.PCIClassTable], edx

		; write all the strings to the list area
		push dword 36
		push PCITable.PCI00$
		push dword 0
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI01$
		push dword 1
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI02$
		push dword 2
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI03$
		push dword 3
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI04$
		push dword 4
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI05$
		push dword 5
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI06$
		push dword 6
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI07$
		push dword 7
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI08$
		push dword 8
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI09$
		push dword 9
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI0A$
		push dword 10
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI0B$
		push dword 11
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI0C$
		push dword 12
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI0D$
		push dword 13
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI0E$
		push dword 14
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI0F$
		push dword 15
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI10$
		push dword 16
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI11$
		push dword 17
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI12$
		push dword 18
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI13$
		push dword 19
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI40$
		push dword 64
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCIFF$
		push dword 255
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot
		mov byte [.flag], 1

	.DrawMenu:
	mov byte [textColor], 7
	mov byte [backColor], 0

	mov byte [cursorX], 1
	mov byte [cursorY], 1
	push .kDebugMenu$
	call Print32

	mov byte [cursorY], 3
	push .kDebugText1$
	call Print32

	push .kDebugText2$
	call Print32

	push .kDebugText3$
	call Print32

	push .kDebugText4$
	call Print32

	push .kDebugText5$
	call Print32

	push .kDebugText6$
	call Print32

	push .kDebugText7$
	call Print32

	push .kDebugText8$
	call Print32

	push .kDebugText9$
	call Print32

	push .kDebugText0$
	call Print32

	.DebugLoop:
		call KeyGet
		pop eax

		cmp al, 0x30							; choice 0
		jne .TestFor1
		jmp .Exit

		.TestFor1:
		cmp al, 0x31							; choice 1
		jne .TestFor2
		call .SystemInfo
		jmp .DrawMenu

		.TestFor2:
		cmp al, 0x32							; choice 2
		jne .TestFor3
		call .PCIDevices
		jmp .DrawMenu

		.TestFor3:
		cmp al, 0x33							; choice 3
		jne .TestFor4
		call .Exit
		jmp .DrawMenu

		.TestFor4:
		cmp al, 0x34							; choice 4
		jne .TestFor5
		call .Exit
		jmp .DrawMenu

		.TestFor5:
		cmp al, 0x35							; choice 5
		jne .TestFor6
		call .Exit
		jmp .DrawMenu

		.TestFor6:
		cmp al, 0x36							; choice 6
		jne .TestFor7
		jmp .Exit
		jmp .DrawMenu

		.TestFor7:
		cmp al, 0x37							; choice 7
		jne .TestFor8
		jmp .Exit
		jmp .DrawMenu

		.TestFor8:
		cmp al, 0x38							; choice 8
		jne .TestFor9
		jmp .Exit
		jmp .DrawMenu

		.TestFor9:
		cmp al, 0x39							; choice 9
		jne .DebugLoop
		jmp .Exit
		jmp .DrawMenu

	jmp .DebugLoop
	.Exit:
ret
.flag											db 0x00
.kDebugMenu$									db 'Kernel Debug Menu', 0x00
.kDebugText1$									db '1 - System Info', 0x00
.kDebugText2$									db '2 - PCI Devices', 0x00
.kDebugText3$									db '3 - ', 0x00
.kDebugText4$									db '4 - ', 0x00
.kDebugText5$									db '5 - ', 0x00
.kDebugText6$									db '6 - ', 0x00
.kDebugText7$									db '7 - ', 0x00
.kDebugText8$									db '8 - ', 0x00
.kDebugText9$									db '9 - ', 0x00
.kDebugText0$									db '0 - ', 0x00



.SystemInfo:
	; clear the screen first
	call ClearScreen32

	; print the description of this page
	mov byte [textColor], 7
	mov byte [backColor], 0
	push .systemInfoText$
	call Print32

	; print the kernel string
	mov byte [cursorY], 3
	push tSystem.copyright$
	call Print32

	; build the version string
	push dword [tSystem.versionMinor]
	push dword [tSystem.versionMajor]
	push kPrintText$
	push .versionFormat$
	call StringBuild

	; print the version string
	push kPrintText$
	call Print32

	; print the CPU string
	push tSystem.CPUIDBrand$
	call Print32

	; wait for a keypress before leaving
	call KeyWait
	pop eax

	; clear the screen and exit!
	call ClearScreen32
ret
.systemInfoText$								db 'System Information', 0x00
.versionFormat$									db 'Version ^p2^h.^h', 0x00



.PCIDevices:
	call ClearScreen32

	mov byte [textColor], 7
	mov byte [backColor], 0
	push .PCIInfoText$
	call Print32

	; see if we have to print data on all devices of on a specific device
	cmp dword [.currentDevice], 0
	jne .PrintSpecificDevice
	
		; if we get here, the counter is 0 so we print all devices
	
		; build and print the device count string
		push dword [tSystem.PCIDeviceCount]
		push kPrintText$
		push .PCIDeviceCountText$
		call StringBuild
	
		push kPrintText$
		call Print32
		
		; print the device description header
		push .PCIDeviceDescriptionText1$
		call Print32
	
		mov ecx, 1
		.PCIListAllLoop:
			pusha

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
							push dword [.PCIFunction]
							push dword [.PCIDevice]
							push dword [.PCIBus]
							call PCIReadDWord
							pop dword [.temp]
							popa

							; if the vendor ID is 0xFFFF, it's invalid
							cmp word [.temp], 0xFFFF
							je .InfoSkip
								; if we get here, the device is valid, so we print the data for it

								pusha

								; get info on the first device
								push PCIDeviceInfo
								push dword [.PCIFunction]
								push dword [.PCIDevice]
								push dword [.PCIBus]
								call PCIReadAll

								; first calculate the address of the string which describes this device
								mov edx, 0x00000000
								mov eax, 36
								mul byte [PCIDeviceInfo.PCIClass]
								mov ebx, PCITable.PCI00$
								add eax, ebx
								push eax

								; build the rest of the PCI data into line 1 for this device
								mov eax, 0x00000000
								mov al, [PCIDeviceInfo.PCIRevision]
								push eax

								mov eax, 0x00000000
								mov al, [PCIDeviceInfo.PCIProgIf]
								push eax

								mov eax, 0x00000000
								mov al, [PCIDeviceInfo.PCISubclass]
								push eax

								mov eax, 0x00000000
								mov al, [PCIDeviceInfo.PCIClass]
								push eax

								mov eax, 0x00000000
								mov ax, [PCIDeviceInfo.PCIDeviceID]
								push eax

								mov eax, 0x00000000
								mov ax, [PCIDeviceInfo.PCIVendorID]
								push eax
								push dword [.PCIFunction]
								push dword [.PCIDevice]
								push dword [.PCIBus]
								push kPrintText$
								push .format1$
								call StringBuild

								; print the string we just built
								push kPrintText$
								call Print32

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


			popa
			inc ecx
		jmp .GetInputLoop

		; here we print info for just one specific device
		.PrintSpecificDevice:
			call ClearScreen32

			; build and print the device count string
			push dword [tSystem.PCIDeviceCount]
			push dword [.currentDevice]
			push kPrintText$
			push .PCIDeviceListingText$
			call StringBuild

			push kPrintText$
			call Print32

			inc byte [cursorY]

			; print the device description header
			push .PCIDeviceDescriptionText1$
			call Print32

			mov ecx, dword [.currentDevice]
			pusha

			; get info on the first device
			push PCIDeviceInfo
			push ecx
			call PCIReadDeviceNumber
			pop dword [.PCIFunction]
			pop dword [.PCIDevice]
			pop dword [.PCIBus]

			; now we print line 1 of the data for this device

			; first calculate the address of the string which describes this device
			mov edx, 0x00000000
			mov eax, 36
			mul byte [PCIDeviceInfo.PCIClass]
			mov ecx, PCITable.PCI00$
			add eax, ecx
			push eax
			; build the rest of the PCI data into line 1 for this device
			mov eax, 0x00000000
			mov al, [PCIDeviceInfo.PCIRevision]
			push eax
			
			mov eax, 0x00000000
			mov al, [PCIDeviceInfo.PCIProgIf]
			push eax
			
			mov eax, 0x00000000
			mov al, [PCIDeviceInfo.PCISubclass]
			push eax
			
			mov eax, 0x00000000
			mov al, [PCIDeviceInfo.PCIClass]
			push eax
			
			mov eax, 0x00000000
			mov ax, [PCIDeviceInfo.PCIDeviceID]
			push eax
			
			mov eax, 0x00000000
			mov ax, [PCIDeviceInfo.PCIVendorID]
			push eax
			push dword [.PCIFunction]
			push dword [.PCIDevice]
			push dword [.PCIBus]
			push kPrintText$
			push .format1$
			call StringBuild
		
			; print the string we just built
			push kPrintText$
			call Print32
	
			inc byte [cursorY]
	
			; print the first three BARs
			push dword [PCIDeviceInfo.PCIBAR2]
			push dword [PCIDeviceInfo.PCIBAR1]
			push dword [PCIDeviceInfo.PCIBAR0]
			push kPrintText$
			push .format2$
			call StringBuild
		
			; print the string we just built
			push kPrintText$
			call Print32
	
			; print the other three BARs
			push dword [PCIDeviceInfo.PCIBAR5]
			push dword [PCIDeviceInfo.PCIBAR4]
			push dword [PCIDeviceInfo.PCIBAR3]
			push kPrintText$
			push .format3$
			call StringBuild
		
			; print the string we just built
			push kPrintText$
			call Print32

			inc byte [cursorY]

			; process the miscellaneous PCI infos, starting with the device description header
			mov eax, 0x00000000
			mov al, [PCIDeviceInfo.PCIBIST]
			push eax
			
			mov eax, 0x00000000
			mov al, [PCIDeviceInfo.PCIHeaderType]
			push eax
			
			mov eax, 0x00000000
			mov al, [PCIDeviceInfo.PCILatencyTimer]
			push eax
			
			mov eax, 0x00000000
			mov al, [PCIDeviceInfo.PCICacheLineSize]
			push eax
			
			push kPrintText$
			push .format4$
			call StringBuild
		
			; print the string we just built
			push kPrintText$
			call Print32

			inc byte [cursorY]

			; more data and stuffs
			mov eax, 0x00000000
			mov ax, [PCIDeviceInfo.PCISubsystemID]
			push eax
			
			mov eax, 0x00000000
			mov ax, [PCIDeviceInfo.PCISubsystemVendorID]
			push eax
			
			push dword [PCIDeviceInfo.PCICardbusCISPointer]
			
			push kPrintText$
			push .format5$
			call StringBuild
		
			; print the string we just built
			push kPrintText$
			call Print32
	
			inc byte [cursorY]

			; even moar data and thingz
			push dword [PCIDeviceInfo.PCIExpansionROMBaseAddress]
			
			mov eax, 0x00000000
			mov al, [PCIDeviceInfo.PCICapabilitiesPointer]
			push eax
			
			push kPrintText$
			push .format6$
			call StringBuild
		
			; print the string we just built
			push kPrintText$
			call Print32
	
			inc byte [cursorY]

			; SO. MUCH. DATA.
			mov eax, 0x00000000
			mov al, [PCIDeviceInfo.PCIMaxLatency]
			push eax
			
			mov eax, 0x00000000
			mov al, [PCIDeviceInfo.PCIMaxGrant]
			push eax
			
			mov eax, 0x00000000
			mov al, [PCIDeviceInfo.PCIInterruptPin]
			push eax
			
			mov eax, 0x00000000
			mov al, [PCIDeviceInfo.PCIInterruptLine]
			push eax
			
			push kPrintText$
			push .format7$
			call StringBuild
		
			; print the string we just built
			push kPrintText$
			call Print32

			popa
			
		.GetInputLoop:
		call KeyWait
		pop eax
	
		; see what was pressed
		cmp eax, 0x39
		je .PageUp
	
		cmp eax, 0x33
		je .PageDown
	
		cmp eax, 0x31
		je .End

jmp .GetInputLoop

.PageUp:
	dec dword [.currentDevice]
	cmp dword [.currentDevice], 0xFFFFFFFF
	jne .PCIDevices
	inc dword [.currentDevice]
jmp .GetInputLoop

.PageDown:
	inc dword [.currentDevice]
	mov eax, dword [tSystem.PCIDeviceCount]
	cmp dword [.currentDevice], eax
	jbe .PCIDevices
	dec dword [.currentDevice]
jmp .GetInputLoop

.End:
	; set this for next time
	mov dword [.currentDevice], 0

	; clear the screen and exit
	call ClearScreen32
ret



.PCIInfoText$									db 'PCI Devices', 0x00
.PCIDeviceCountText$							db '^d PCI devices found', 0x00
.PCIDeviceListingText$							db 'Device ^d of ^d', 0x00
.PCIDeviceDescriptionText1$						db 'Bus Dev  Fn  Vend  Dev   Cl  Sc  PI  Rv  Description', 0x00
.format1$										db '^p2^h  ^p2^h   ^p1^h   ^p4^h  ^h  ^p2^h  ^h  ^h  ^h  ^s', 0x00
.format2$										db '^p8BAR0 ^h        BAR1 ^h        BAR2 ^h', 0x00
.format3$										db '^p8BAR3 ^h        BAR4 ^h        BAR5 ^h', 0x00
.format4$										db '^p2Cache Line Size ^h    Latency Timer ^h    Header Type ^h    BIST ^h', 0x00
.format5$										db '^p8Cardbus CIS Pointer ^h    ^p4Subsystem Vendor ^h    Subsystem ^h', 0x00
.format6$										db '^p8Expansion ROM Base Address ^h    Capabilities Pointer ^p2^h', 0x00
.format7$										db '^p2Interrupt Line ^h    Interrupt Pin ^h    Max Grant ^h    Max Latency ^h', 0x00
.PCIBus											dd 0x00000000
.PCIDevice										dd 0x00000000
.PCIFunction									dd 0x00000000
.currentDevice									dd 0x00000000
.temp											dd 0x00000000



.TimeInfo:
;	mov eax, 0x00000000
;	mov al, [tSystem.hours]
;	push kPrintText$
;	push eax
;	call ConvertToHexString
;	push kPrintText$
;	push 0xFF000000
;	push 0xFF777777
;	push 180
;	push 20
;	call [VESAPrint]
;
;	mov eax, 0x00000000
;	mov al, [tSystem.minutes]
;	push kPrintText$
;	push eax
;	call ConvertToHexString
;	push kPrintText$
;	push 0xFF000000
;	push 0xFF777777
;	push 180
;	push 120
;	call [VESAPrint]
;
;	mov eax, 0x00000000
;	mov al, [tSystem.seconds]
;	push kPrintText$
;	push eax
;	call ConvertToHexString
;	push kPrintText$
;	push 0xFF000000
;	push 0xFF777777
;	push 180
;	push 220
;	call [VESAPrint]
;
;	mov eax, 0x00000000
;	mov al, [tSystem.ticks]
;	push kPrintText$
;	push eax
;	call ConvertToHexString
;	push kPrintText$
;	push 0xFF000000
;	push 0xFF777777
;	push 180
;	push 320
;	call [VESAPrint]
;
;	mov eax, 0x00000000
;	mov al, [tSystem.month]
;	push kPrintText$
;	push eax
;	call ConvertToHexString
;	push kPrintText$
;	push 0xFF000000
;	push 0xFF777777
;	push 200
;	push 20
;	call [VESAPrint]
;
;	mov eax, 0x00000000
;	mov al, [tSystem.day]
;	push kPrintText$
;	push eax
;	call ConvertToHexString
;	push kPrintText$
;	push 0xFF000000
;	push 0xFF777777
;	push 200
;	push 120
;	call [VESAPrint]
;
;	mov eax, 0x00000000
;	mov al, [tSystem.century]
;	push kPrintText$
;	push eax
;	call ConvertToHexString
;	push kPrintText$
;	push 0xFF000000
;	push 0xFF777777
;	push 200
;	push 220
;	call [VESAPrint]
;
;	mov eax, 0x00000000
;	mov al, [tSystem.year]
;	push kPrintText$
;	push eax
;	call ConvertToHexString
;	push kPrintText$
;	push 0xFF000000
;	push 0xFF777777
;	push 200
;	push 320
;	call [VESAPrint]
;
;	; print seconds since boot just for the heck of it
;	push kPrintText$
;	push dword [tSystem.secondsSinceBoot]
;	call ConvertToHexString
;	push kPrintText$
;	push 0xFF000000
;	push 0xFF777777
;	push 34
;	push 2
;	call [VESAPrint]
ret



PCIReadDeviceNumber:
	; Returns data for the PCI devices specified
	;
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



kDebugger$										db 'What a horrible Night to have a bug.', 0x00
kSadThing$										db 0x27, 'Tis a sad thing that your process has ended here!', 0x00



; struct to hold all data about a single PCI device for the system menu
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
PCITable:
.PCIClassTable									dd 0x00000000
.PCI00$											db 'Unclassified device                ', 0x00
.PCI01$											db 'Mass Storage Controller            ', 0x00
.PCI02$											db 'Network Controller                 ', 0x00
.PCI03$											db 'Display Controller                 ', 0x00
.PCI04$											db 'Multimedia Controller              ', 0x00
.PCI05$											db 'Memory Controller                  ', 0x00
.PCI06$											db 'Bridge Device                      ', 0x00
.PCI07$											db 'Simple Communication Controller    ', 0x00
.PCI08$											db 'Generic System Peripheral          ', 0x00
.PCI09$											db 'Input Device                       ', 0x00
.PCI0A$											db 'Docking Station                    ', 0x00
.PCI0B$											db 'Processor                          ', 0x00
.PCI0C$											db 'USB Controller                     ', 0x00
.PCI0D$											db 'Wireless Controller                ', 0x00
.PCI0E$											db 'Intelligent I/O Controller         ', 0x00
.PCI0F$											db 'Satellite Communications Controller', 0x00
.PCI10$											db 'Encryption Controller              ', 0x00
.PCI11$											db 'Signal Processing Controller       ', 0x00
.PCI12$											db 'Processing Accelerator             ', 0x00
.PCI13$											db 'Non-Essential Instrumentation      ', 0x00
.PCI40$											db 'Coprocessor                        ', 0x00
.PCIFF$											db 'Unassigned class                   ', 0x00
