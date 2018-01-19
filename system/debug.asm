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
		call .DiskInfo
		jmp .DrawMenu

		.TestFor3:
		cmp al, 0x33							; choice 3
		jne .TestFor4
		call .PCIDevices
		jmp .DrawMenu

		.TestFor4:
		cmp al, 0x34							; choice 4
		jne .TestFor5
		call .RAMBrowser
		jmp .DrawMenu

		.TestFor5:
		cmp al, 0x35							; choice 5
		jne .TestFor6
		call .MouseTest
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
		;call DebugFeatureDemo
		jmp .DrawMenu

	jmp .DebugLoop
	.Exit:
ret
.kDebugMenu$									db 'Kernel Debug Menu', 0x00
.kDebugText1$									db '1 - System Info', 0x00
.kDebugText2$									db '2 - Disk Info', 0x00
.kDebugText3$									db '3 - PCI Devices', 0x00
.kDebugText4$									db '4 - RAM Browser', 0x00
.kDebugText5$									db '5 - Mouse Tracking Test', 0x00
.kDebugText6$									db '6 - Serial Test', 0x00
.kDebugText7$									db '7 - Time Info', 0x00
.kDebugText8$									db '8 - Video Info', 0x00
.kDebugText9$									db '9 - Feature Demo', 0x00
.kDebugText0$									db '0 - Exit', 0x00



.DiskInfo:
	
ret



.MouseTest:
;	; print mouse position
;	push .mouseValue
;	mov eax, 0x00000000
;	mov byte al, [tSystem.mouseButtons]
;	push eax
;	call ConvertToHexString
;	push .mouseValue
;	push 0xFF000000
;	push 0xFF777777
;	push 2
;	push 2
;	call [VESAPrint]
;
;	push .mouseValue
;	mov eax, 0x00000000
;	mov word ax, [tSystem.mouseX]
;	push eax
;	call ConvertToHexString
;	push .mouseValue
;	push 0xFF000000
;	push 0xFF777777
;	push 2
;	push 102
;	call [VESAPrint]
;
;	push .mouseValue
;	mov eax, 0x00000000
;	mov word ax, [tSystem.mouseY]
;	push eax
;	call ConvertToHexString
;	push .mouseValue
;	push 0xFF000000
;	push 0xFF777777
;	push 2
;	push 202
;	call [VESAPrint]
; 
;	push .mouseValue
;	mov eax, 0x00000000
;	mov word ax, [tSystem.mouseZ]
;	push eax
;	call ConvertToHexString
;	push .mouseValue
;	push 0xFF000000
;	push 0xFF777777
;	push 2
;	push 302
;	call [VESAPrint]
;	
;	; see if the mouse moved
;	mov eax, 0x00000000
;	mov ebx, 0x00000000
;	mov ax, [tSystem.mouseX]
;	mov bx, [tSystem.mouseY]
;	mov ecx, [.oldMouseX]
;	mov edx, [.oldMouseY]
;	cmp ax, cx
;	jne .DrawMouse
;	cmp bx, dx
;	jne .DrawMouse
;
;	call KeyGet
;	pop eax
;	cmp al, 0x00
;	je .MouseTest
ret
;.mouseValue										times 16 db 0x00
;
.DrawMouse:
;	mov al, [tSystem.mouseButtons]
;	cmp al, 0x00
;	jne .DrawNewCursor
;	.EraseOldCursor:
;	mov eax, [.oldMouseX]
;	mov ebx, [.oldMouseY]
;	dec eax
;	pusha
;	push 0x00000000
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	dec eax
;	pusha
;	push 0x00000000
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	dec eax
;	pusha
;	push 0x00000000
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	dec eax
;	push 0x00000000
;	push ebx
;	push eax
;	call [VESAPlot]
;
;	mov eax, [.oldMouseX]
;	mov ebx, [.oldMouseY]
;	dec ebx
;	pusha
;	push 0x00000000
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	dec ebx
;	pusha
;	push 0x00000000
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	dec ebx
;	pusha
;	push 0x00000000
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	dec ebx
;	push 0x00000000
;	push ebx
;	push eax
;	call [VESAPlot]
;
;	mov eax, [.oldMouseX]
;	mov ebx, [.oldMouseY]
;	inc eax
;	pusha
;	push 0x00000000
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	inc eax
;	pusha
;	push 0x00000000
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	inc eax
;	pusha
;	push 0x00000000
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	inc eax
;	push 0x00000000
;	push ebx
;	push eax
;	call [VESAPlot]
;
;	mov eax, [.oldMouseX]
;	mov ebx, [.oldMouseY]
;	inc ebx
;	pusha
;	push 0x00000000
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	inc ebx
;	pusha
;	push 0x00000000
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	inc ebx
;	pusha
;	push 0x00000000
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	inc ebx
;	push 0x00000000
;	push ebx
;	push eax
;	call [VESAPlot]
;
;	.DrawNewCursor:
;	mov ah, [tSystem.mouseButtons]
;	mov ebx, 0x00000000
;	.RedTest:
;	mov al, ah
;	and al, 0x01
;	cmp al, 0x01
;	jne .GreenTest
;	or ebx, 0x00FF0000
;
;	.GreenTest:
;	mov al, ah
;	and al, 0x04
;	cmp al, 0x04
;	jne .BlueTest
;	or ebx, 0x0000FF00
;
;	.BlueTest:
;	mov al, ah
;	and al, 0x02
;	cmp al, 0x02
;	jne .DoneTest
;	or ebx, 0x000000FF
;
;	.DoneTest:
;	cmp ebx, 0x00000000
;	jne .DrawCursor
;	mov ebx, 0x00777777
;	.DrawCursor:
;	mov dword [.color], ebx
;
;	; draw the cursor
;	mov eax, 0x00000000
;	mov ebx, 0x00000000
;	mov ax, [tSystem.mouseX]
;	mov bx, [tSystem.mouseY]
;	dec eax
;	pusha
;	push dword [.color]
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	dec eax
;	pusha
;	push dword [.color]
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	dec eax
;	pusha
;	push dword [.color]
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	dec eax
;	push dword [.color]
;	push ebx
;	push eax
;	call [VESAPlot]
;
;	mov eax, 0x00000000
;	mov ebx, 0x00000000
;	mov ax, [tSystem.mouseX]
;	mov bx, [tSystem.mouseY]
;	dec ebx
;	pusha
;	push dword [.color]
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	dec ebx
;	pusha
;	push dword [.color]
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	dec ebx
;	pusha
;	push dword [.color]
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	dec ebx
;	push dword [.color]
;	push ebx
;	push eax
;	call [VESAPlot]
;
;	mov eax, 0x00000000
;	mov ebx, 0x00000000
;	mov ax, [tSystem.mouseX]
;	mov bx, [tSystem.mouseY]
;	inc eax
;	pusha
;	push dword [.color]
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	inc eax
;	pusha
;	push dword [.color]
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	inc eax
;	pusha
;	push dword [.color]
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	inc eax
;	push dword [.color]
;	push ebx
;	push eax
;	call [VESAPlot]
;
;	mov eax, 0x00000000
;	mov ebx, 0x00000000
;	mov ax, [tSystem.mouseX]
;	mov bx, [tSystem.mouseY]
;	inc ebx
;	pusha
;	push dword [.color]
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	inc ebx
;	pusha
;	push dword [.color]
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	inc ebx
;	pusha
;	push dword [.color]
;	push ebx
;	push eax
;	call [VESAPlot]
;	popa
;	inc ebx
;	push dword [.color]
;	push ebx
;	push eax
;	call [VESAPlot]
;
;	; update mouse tracking locals
;	mov eax, 0x00000000
;	mov ebx, 0x00000000
;	mov ax, [tSystem.mouseX]
;	mov bx, [tSystem.mouseY]
;	mov [.oldMouseX], eax
;	mov [.oldMouseY], ebx
jmp .MouseTest
;.oldMouseX										dd 0x00000000
;.oldMouseY										dd 0x00000000
;.color											dd 0x00000000



.RAMBrowser:
	call KeyWait
	pop eax
ret



.SerialTest:
	push 115200
	push 1
	call SerialSetBaud
	pop edx

	push 8
	push 1
	call SerialSetWordSize
	pop edx

	push 1
	push 1
	call SerialSetStopBits
	pop edx

	push 0
	push 1
	call SerialSetParity
	pop edx


	push tSystem.copyright$
	call PrintSerial

	push kCRLF
	call PrintSerial

	; display any received serial data
	mov eax, 0x00000000
	mov dx, 0x03F8
	in al, dx
	push kPrintText$
	push eax
	call ConvertToHexString
	mov byte [cursorX], 1
	mov byte [cursorY], 5
	mov byte [textColor], 7
	mov byte [backColor], 0
	push kPrintText$
	call Print32
ret



.SystemInfo:
	call ClearScreen32

	mov byte [textColor], 7
	mov byte [backColor], 0
	push .systemInfoText$
	call Print32

	mov byte [cursorY], 3
	push tSystem.CPUIDBrand$
	call Print32

	push tSystem.copyright$
	call Print32

	call KeyWait
	pop eax
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
		
			; get info on the first device
			push PCIDeviceInfo
			push ecx
			call PCIReadDeviceNumber
			pop dword [.PCIFunction]
			pop dword [.PCIDevice]
			pop dword [.PCIBus]
		
			; now we print the data for this device
		
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
		
			popa
			inc ecx
			
		cmp ecx, dword [tSystem.PCIDeviceCount]
		jbe .PCIListAllLoop
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



VideoInfo:
	; testing DebugPrint - print the address in memory of the VESA OEM String and the string itself
	push dword [tSystem.VESAOEMVendorNamePointer]
	push tSystem.VESAOEMVendorNamePointer
	push 64
	push 2
	call PrintSimple32
ret



kDebugger$										db 'What a horrible Night to have a bug.', 0x00
