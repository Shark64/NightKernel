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



; 32-bit function listing:
; DebugMenu						Implements the in-kernel debugging menu



bits 32



DebugMenu:
	; Implements the in-kernel debugging menu
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a

	push ebp
	mov ebp, esp

	; create a new list to hold the PCI device labels if necessary
	cmp byte [.flag], 1
	je .DrawMenu

		push dword 36								; size of each element
		push dword 256								; number of elements
		call LMListNew
		pop edx
		mov dword [PCITable.PCIClassTable], edx

		; write all the strings to the list area
		push dword 20
		push PCITable.PCI00$
		push dword 0
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 24
		push PCITable.PCI01$
		push dword 1
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 19
		push PCITable.PCI02$
		push dword 2
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 19
		push PCITable.PCI03$
		push dword 3
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 22
		push PCITable.PCI04$
		push dword 4
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 18
		push PCITable.PCI05$
		push dword 5
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 14
		push PCITable.PCI06$
		push dword 6
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 32
		push PCITable.PCI07$
		push dword 7
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 26
		push PCITable.PCI08$
		push dword 8
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 13
		push PCITable.PCI09$
		push dword 9
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 16
		push PCITable.PCI0A$
		push dword 10
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 10
		push PCITable.PCI0B$
		push dword 11
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 15
		push PCITable.PCI0C$
		push dword 12
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 20
		push PCITable.PCI0D$
		push dword 13
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 27
		push PCITable.PCI0E$
		push dword 14
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 36
		push PCITable.PCI0F$
		push dword 15
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 22
		push PCITable.PCI10$
		push dword 16
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 29
		push PCITable.PCI11$
		push dword 17
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 23
		push PCITable.PCI12$
		push dword 18
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 30
		push PCITable.PCI13$
		push dword 19
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 12
		push PCITable.PCI40$
		push dword 64
		push dword [PCITable.PCIClassTable]
		call LMItemAddAtSlot

		push dword 17
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
		push 0
		call KeyGet



		mov byte [cursorY], 17


		; clear our print string
		push dword 0
		push dword 256
		push kPrintText$
		call MemFill

		; do the ticks/seconds since boot string
		push dword [tSystem.secondsSinceBoot]
		push dword [tSystem.ticksSinceBoot]

		push kPrintText$
		push .ticksFormat$
		call StringBuild

		push kPrintText$
		call Print32

		; clear our print string
		push dword 0
		push dword 256
		push kPrintText$
		call MemFill

		; do the date and time info string
		mov eax, 0x00000000
		mov al, byte [tSystem.year]
		push eax

		mov eax, 0x00000000
		mov al, byte [tSystem.century]
		push eax

		mov eax, 0x00000000
		mov al, byte [tSystem.day]
		push eax

		mov eax, 0x00000000
		mov al, byte [tSystem.month]
		push eax

		mov eax, 0x00000000
		mov al, byte [tSystem.ticks]
		push eax

		mov eax, 0x00000000
		mov al, byte [tSystem.seconds]
		push eax

		mov eax, 0x00000000
		mov al, byte [tSystem.minutes]
		push eax

		mov eax, 0x00000000
		mov al, byte [tSystem.hours]
		push eax

		push kPrintText$
		push .dateTimeFormat$
		call StringBuild

		push kPrintText$
		call Print32



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

	mov esp, ebp
	pop ebp
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
.ticksFormat$									db 'Ticks since boot: ^p10^d     Seconds since boot:^d', 0x00
.dateTimeFormat$								db '^p2^d:^d:^d.^p3^d     ^p2^d/^d/^h^d', 0x00



.SystemInfo:
	; clear the screen first
	call ScreenClear32

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
	mov eax, 0x00000000
	mov al, byte [tSystem.versionMinor]
	push eax

	mov al, byte [tSystem.versionMajor]
	push eax
	

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
	push 0
	call KeyWait
	pop eax

	; clear the screen and exit!
	call ScreenClear32
ret
.systemInfoText$								db 'System Information', 0x00
.versionFormat$									db 'Kernel version ^p2^h.^h', 0x00



.PCIDevices:
	call ScreenClear32

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
		inc byte [cursorY]
		push .PCIDeviceDescriptionText1$
		call Print32

		; init the values
		mov dword [.PCIBus], 0
		mov dword [.PCIDevice], 0
		mov dword [.PCIFunction], 0

		.PCIListAllLoop:
			push dword [.PCIFunction]
			push dword [.PCIDevice]
			push dword [.PCIBus]
			call PCIGetNextFunction
			pop dword [.PCIFunction]
			pop dword [.PCIDevice]
			pop dword [.PCIBus]

			; see if we're done yet
			mov eax, dword [.PCIBus]
			add eax, dword [.PCIDevice]
			add eax, dword [.PCIFunction]
			cmp eax, 0x0002FFFD
			je .GetInputLoop

			; get info on the first device
			push PCIDeviceInfo
			push dword [.PCIFunction]
			push dword [.PCIDevice]
			push dword [.PCIBus]
			call PCIReadAll

			; first calculate the address of the string which describes this device
			mov eax, 0x00000000
			mov al, byte [PCIDeviceInfo.PCIClass]
			push eax
			push dword [PCITable.PCIClassTable]
			call LMItemGetAddress
			; no need to pop the return value off the stack here from the above call since it needs to be there anyway

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
			push .format$
			call StringBuild

			; print the string we just built
			push kPrintText$
			call Print32

			; advance to the next slot
			push dword [.PCIFunction]
			push dword [.PCIDevice]
			push dword [.PCIBus]
			call PCICalculateNext
			pop dword [.PCIFunction]
			pop dword [.PCIDevice]
			pop dword [.PCIBus]

		jmp .PCIListAllLoop

	.PrintSpecificDevice:
	; here we print info for just one specific device
	; we start by building and printing the device count string
	push dword [tSystem.PCIDeviceCount]
	push dword [.currentDevice]
	push kPrintText$
	push .PCIDeviceListingText$
	call StringBuild

	push kPrintText$
	call Print32

	mov eax, dword [.currentDevice]
	dec eax
	push eax
	push dword [tSystem.PCITableAddress]
	call LMItemGetAddress
	pop eax

	; adjust the address to skip the pci bus/device/function data
	add eax, 12

	; dump the memory space
	inc byte [cursorY]		
	push dword 16
	push eax
	call PrintRAM32
			
	.GetInputLoop:
		push 0
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
	call ScreenClear32
ret
.PCIInfoText$									db 'PCI Devices', 0x00
.PCIDeviceCountText$							db '^d PCI devices found', 0x00
.PCIDeviceListingText$							db 'Shadowed register space for device ^d of ^d', 0x00
.PCIDeviceDescriptionText1$						db 'Bus Dev  Fn  Vend  Dev   Cl  Sc  PI  Rv  Description', 0x00
.format$										db '^p2^h  ^p2^h   ^p1^h   ^p4^h  ^h  ^p2^h  ^h  ^h  ^h  ^s', 0x00
.PCIBus											dd 0x00000000
.PCIDevice										dd 0x00000000
.PCIFunction									dd 0x00000000
.currentDevice									dd 0x00000000



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
.PCI00$											db 'Unclassified device', 0x00
.PCI01$											db 'Mass Storage Controller', 0x00
.PCI02$											db 'Network Controller', 0x00
.PCI03$											db 'Display Controller', 0x00
.PCI04$											db 'Multimedia Controller', 0x00
.PCI05$											db 'Memory Controller', 0x00
.PCI06$											db 'Bridge Device', 0x00
.PCI07$											db 'Simple Communication Controller', 0x00
.PCI08$											db 'Generic System Peripheral', 0x00
.PCI09$											db 'Input Device', 0x00
.PCI0A$											db 'Docking Station', 0x00
.PCI0B$											db 'Processor', 0x00
.PCI0C$											db 'USB Controller', 0x00
.PCI0D$											db 'Wireless Controller', 0x00
.PCI0E$											db 'Intelligent I/O Controller', 0x00
.PCI0F$											db 'Satellite Communications Controller', 0x00
.PCI10$											db 'Encryption Controller', 0x00
.PCI11$											db 'Signal Processing Controller', 0x00
.PCI12$											db 'Processing Accelerator', 0x00
.PCI13$											db 'Non-Essential Instrumentation', 0x00
.PCI40$											db 'Coprocessor', 0x00
.PCIFF$											db 'Unassigned class', 0x00
