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
	;  input:
	;   n/a
	;
	;  output:
	;   n/a

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
								mov ebx, PCIClass
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
			mov ecx, PCIClass
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



VideoInfo:
	; testing DebugPrint - print the address in memory of the VESA OEM String and the string itself
	push dword [tSystem.VESAOEMVendorNamePointer]
	push tSystem.VESAOEMVendorNamePointer
	push 64
	push 2
	call PrintSimple32
ret



kDebugger$										db 'What a horrible Night to have a bug.', 0x00

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
