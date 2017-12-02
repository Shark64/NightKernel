; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; debug.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or
; modify it under the terms of the GNU General Public License as published
; by the Free Software Foundation, either version 3 of the License, or (at
; your option) any later version.

; The Night Kernel is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
; or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
; for more details.

; You should have received a copy of the GNU General Public License along
; with the Night Kernel. If not, see <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the
; GPL License by which this program is covered.



bits 32



DebugMenu:
	; Implements the in-kernel debugging menu
	;  input:
	;   n/a
	;
	;  output:
	;   n/a

	.DrawMenu:
	push .kDebugMenu
	push 0xFF000000
	push 0xFF7777FF
	push 2
	push 2
	call [VESAPrint]

	push .kDebugText1
	push 0xFF000000
	push 0xFF777777
	push 34
	push 2
	call [VESAPrint]

	push .kDebugText2
	push 0xFF000000
	push 0xFF777777
	push 50
	push 2
	call [VESAPrint]

	push .kDebugText3
	push 0xFF000000
	push 0xFF777777
	push 66
	push 2
	call [VESAPrint]

	push .kDebugText4
	push 0xFF000000
	push 0xFF777777
	push 82
	push 2
	call [VESAPrint]

	push .kDebugText5
	push 0xFF000000
	push 0xFF777777
	push 98
	push 2
	call [VESAPrint]

	push .kDebugText6
	push 0xFF000000
	push 0xFF777777
	push 114
	push 2
	call [VESAPrint]

	push .kDebugText7
	push 0xFF000000
	push 0xFF777777
	push 130
	push 2
	call [VESAPrint]

	push .kDebugText8
	push 0xFF000000
	push 0xFF777777
	push 146
	push 2
	call [VESAPrint]

	push .kDebugText9
	push 0xFF000000
	push 0xFF777777
	push 162
	push 2
	call [VESAPrint]

	push .kDebugText0
	push 0xFF000000
	push 0xFF777777
	push 178
	push 2
	call [VESAPrint]

	.DebugLoop:
		call KeyGet
		pop eax

		cmp al, 0x30							; choice 0
		jne .TestFor1
		call VESAClearScreen
		jmp .Exit

		.TestFor1:
		cmp al, 0x31							; choice 1
		jne .TestFor2
		call VESAClearScreen
		call .SystemInfo
		call VESAClearScreen
		jmp .DrawMenu

		.TestFor2:
		cmp al, 0x32							; choice 2
		jne .TestFor3
		call VESAClearScreen
		call .DiskInfo
		call VESAClearScreen
		jmp .DrawMenu

		.TestFor3:
		cmp al, 0x33							; choice 3
		jne .TestFor4
		call VESAClearScreen
		call .KernelInfo
		call VESAClearScreen
		jmp .DrawMenu

		.TestFor4:
		cmp al, 0x34							; choice 4
		jne .TestFor5
		call VESAClearScreen
		call .RAMBrowser
		call VESAClearScreen
		jmp .DrawMenu

		.TestFor5:
		cmp al, 0x35							; choice 5
		jne .TestFor6
		call VESAClearScreen
		call .MouseTest
		call VESAClearScreen
		jmp .DrawMenu

		.TestFor6:
		cmp al, 0x36							; choice 6
		jne .TestFor7
		call VESAClearScreen
		jmp .Exit
		call VESAClearScreen
		jmp .DrawMenu

		.TestFor7:
		cmp al, 0x37							; choice 7
		jne .TestFor8
		call VESAClearScreen
		jmp .Exit
		call VESAClearScreen
		jmp .DrawMenu

		.TestFor8:
		cmp al, 0x38							; choice 8
		jne .TestFor9
		call VESAClearScreen
		jmp .Exit
		call VESAClearScreen
		jmp .DrawMenu

		.TestFor9:
		cmp al, 0x39							; choice 9
		jne .DebugLoop
		call VESAClearScreen
		jmp .Exit
		call VESAClearScreen
		jmp .DrawMenu

	jmp .DebugLoop
	.Exit:
ret
.kDebugMenu										db 'Kernel Debug Menu', 0x00
.kDebugText1									db '1 - System Info', 0x00
.kDebugText2									db '2 - Disk Info', 0x00
.kDebugText3									db '3 - Kernel Info', 0x00
.kDebugText4									db '4 - RAM Browser', 0x00
.kDebugText5									db '5 - Mouse Tracking Test', 0x00
.kDebugText6									db '6 - Serial Test', 0x00
.kDebugText7									db '7 - Time Info', 0x00
.kDebugText8									db '8 - Video Info', 0x00
.kDebugText9									db '9 - ', 0x00
.kDebugText0									db '0 - Exit', 0x00



.DiskInfo:
	
ret



.KernelInfo:
	push tSystemInfo.kernelCopyright
	push 0xFF000000
	push 0xFF777777
	push 2
	push 2
	call [VESAPrint]
ret



.MouseTest:
	; print mouse position
	push .mouseValue
	mov eax, 0x00000000
	mov byte al, [tSystemInfo.mouseButtons]
	push eax
	call ConvertToHexString
	push .mouseValue
	push 0xFF000000
	push 0xFF777777
	push 2
	push 2
	call [VESAPrint]

	push .mouseValue
	mov eax, 0x00000000
	mov word ax, [tSystemInfo.mouseX]
	push eax
	call ConvertToHexString
	push .mouseValue
	push 0xFF000000
	push 0xFF777777
	push 2
	push 102
	call [VESAPrint]

	push .mouseValue
	mov eax, 0x00000000
	mov word ax, [tSystemInfo.mouseY]
	push eax
	call ConvertToHexString
	push .mouseValue
	push 0xFF000000
	push 0xFF777777
	push 2
	push 202
	call [VESAPrint]
 
	push .mouseValue
	mov eax, 0x00000000
	mov word ax, [tSystemInfo.mouseZ]
	push eax
	call ConvertToHexString
	push .mouseValue
	push 0xFF000000
	push 0xFF777777
	push 2
	push 302
	call [VESAPrint]
	
	; see if the mouse moved
	mov eax, 0x00000000
	mov ebx, 0x00000000
	mov ax, [tSystemInfo.mouseX]
	mov bx, [tSystemInfo.mouseY]
	mov ecx, [.oldMouseX]
	mov edx, [.oldMouseY]
	cmp ax, cx
	jne .DrawMouse
	cmp bx, dx
	jne .DrawMouse

	call KeyGet
	pop eax
	cmp al, 0x00
	je .MouseTest
ret
.mouseValue										times 16 db 0x00

.DrawMouse:
	mov al, [tSystemInfo.mouseButtons]
	cmp al, 0x00
	jne .DrawNewCursor
	.EraseOldCursor:
	mov eax, [.oldMouseX]
	mov ebx, [.oldMouseY]
	dec eax
	pushad
	push 0x00000000
	push ebx
	push eax
	call [VESAPlot]
	popad
	dec eax
	pushad
	push 0x00000000
	push ebx
	push eax
	call [VESAPlot]
	popad
	dec eax
	pushad
	push 0x00000000
	push ebx
	push eax
	call [VESAPlot]
	popad
	dec eax
	push 0x00000000
	push ebx
	push eax
	call [VESAPlot]

	mov eax, [.oldMouseX]
	mov ebx, [.oldMouseY]
	dec ebx
	pushad
	push 0x00000000
	push ebx
	push eax
	call [VESAPlot]
	popad
	dec ebx
	pushad
	push 0x00000000
	push ebx
	push eax
	call [VESAPlot]
	popad
	dec ebx
	pushad
	push 0x00000000
	push ebx
	push eax
	call [VESAPlot]
	popad
	dec ebx
	push 0x00000000
	push ebx
	push eax
	call [VESAPlot]

	mov eax, [.oldMouseX]
	mov ebx, [.oldMouseY]
	inc eax
	pushad
	push 0x00000000
	push ebx
	push eax
	call [VESAPlot]
	popad
	inc eax
	pushad
	push 0x00000000
	push ebx
	push eax
	call [VESAPlot]
	popad
	inc eax
	pushad
	push 0x00000000
	push ebx
	push eax
	call [VESAPlot]
	popad
	inc eax
	push 0x00000000
	push ebx
	push eax
	call [VESAPlot]

	mov eax, [.oldMouseX]
	mov ebx, [.oldMouseY]
	inc ebx
	pushad
	push 0x00000000
	push ebx
	push eax
	call [VESAPlot]
	popad
	inc ebx
	pushad
	push 0x00000000
	push ebx
	push eax
	call [VESAPlot]
	popad
	inc ebx
	pushad
	push 0x00000000
	push ebx
	push eax
	call [VESAPlot]
	popad
	inc ebx
	push 0x00000000
	push ebx
	push eax
	call [VESAPlot]

	.DrawNewCursor:
	mov ah, [tSystemInfo.mouseButtons]
	mov ebx, 0x00000000
	.RedTest:
	mov al, ah
	and al, 0x01
	cmp al, 0x01
	jne .GreenTest
	or ebx, 0x00FF0000

	.GreenTest:
	mov al, ah
	and al, 0x04
	cmp al, 0x04
	jne .BlueTest
	or ebx, 0x0000FF00

	.BlueTest:
	mov al, ah
	and al, 0x02
	cmp al, 0x02
	jne .DoneTest
	or ebx, 0x000000FF

	.DoneTest:
	cmp ebx, 0x00000000
	jne .DrawCursor
	mov ebx, 0x00777777
	.DrawCursor:
	mov dword [.color], ebx

	; draw the cursor
	mov eax, 0x00000000
	mov ebx, 0x00000000
	mov ax, [tSystemInfo.mouseX]
	mov bx, [tSystemInfo.mouseY]
	dec eax
	pushad
	push dword [.color]
	push ebx
	push eax
	call [VESAPlot]
	popad
	dec eax
	pushad
	push dword [.color]
	push ebx
	push eax
	call [VESAPlot]
	popad
	dec eax
	pushad
	push dword [.color]
	push ebx
	push eax
	call [VESAPlot]
	popad
	dec eax
	push dword [.color]
	push ebx
	push eax
	call [VESAPlot]

	mov eax, 0x00000000
	mov ebx, 0x00000000
	mov ax, [tSystemInfo.mouseX]
	mov bx, [tSystemInfo.mouseY]
	dec ebx
	pushad
	push dword [.color]
	push ebx
	push eax
	call [VESAPlot]
	popad
	dec ebx
	pushad
	push dword [.color]
	push ebx
	push eax
	call [VESAPlot]
	popad
	dec ebx
	pushad
	push dword [.color]
	push ebx
	push eax
	call [VESAPlot]
	popad
	dec ebx
	push dword [.color]
	push ebx
	push eax
	call [VESAPlot]

	mov eax, 0x00000000
	mov ebx, 0x00000000
	mov ax, [tSystemInfo.mouseX]
	mov bx, [tSystemInfo.mouseY]
	inc eax
	pushad
	push dword [.color]
	push ebx
	push eax
	call [VESAPlot]
	popad
	inc eax
	pushad
	push dword [.color]
	push ebx
	push eax
	call [VESAPlot]
	popad
	inc eax
	pushad
	push dword [.color]
	push ebx
	push eax
	call [VESAPlot]
	popad
	inc eax
	push dword [.color]
	push ebx
	push eax
	call [VESAPlot]

	mov eax, 0x00000000
	mov ebx, 0x00000000
	mov ax, [tSystemInfo.mouseX]
	mov bx, [tSystemInfo.mouseY]
	inc ebx
	pushad
	push dword [.color]
	push ebx
	push eax
	call [VESAPlot]
	popad
	inc ebx
	pushad
	push dword [.color]
	push ebx
	push eax
	call [VESAPlot]
	popad
	inc ebx
	pushad
	push dword [.color]
	push ebx
	push eax
	call [VESAPlot]
	popad
	inc ebx
	push dword [.color]
	push ebx
	push eax
	call [VESAPlot]

	; update mouse tracking locals
	mov eax, 0x00000000
	mov ebx, 0x00000000
	mov ax, [tSystemInfo.mouseX]
	mov bx, [tSystemInfo.mouseY]
	mov [.oldMouseX], eax
	mov [.oldMouseY], ebx
jmp .MouseTest
.oldMouseX										dd 0x00000000
.oldMouseY										dd 0x00000000
.color											dd 0x00000000



.RAMBrowser:
	; init locals
	mov byte [.linesCompleted], 0x00
	
	; draw RAM editor grid
	mov byte [.linesCompleted], 0x00
	.LineLoop:
		; calculate starting positions for this line
		mov eax, 0x00000000
		mov ebx, 0x00000000
		mov ax, 16
		mov bl, [.linesCompleted]
		mul bx
		mov [.currentY], eax

		; print starting address for this line
		push kPrintString
		push dword [.startingAddress]
		call ConvertToHexString
		push kPrintString
		push 0xFF000000
		push 0xFF777777
		mov eax, [.currentY]
		push eax
		push 2
		call [VESAPrint]

		; clear the ASCII equivalent string to all periods
		mov ecx, 0x00000000
		mov cl, byte [.hexBytesPerLine]
		.ClearString:
			mov eax, .ASCIIString
			add eax, ecx
			dec eax
			mov byte [eax], 46			
		loop .ClearString

		mov ecx, 0x00000000
		mov cl, byte [.hexBytesPerLine]
		.PrintBytes:
			; calculate byte position for line
			mov eax, 0x00000000
			mov ax, 24
			mul cx
			add eax, 64
			mov [.currentX], eax

			; print individual bytes for this line
			; start by pushing the counter, 'cause these upcoming calls will definitely stomp all over it
			push ecx
			
			; push buffer string address
			push kPrintString
			
			; get the byte from the appropriate location in RAM
			mov eax, dword [.startingAddress]
			add eax, ecx
			dec eax
			mov ebx, dword [eax]
			
			; push that byte
			push ebx

			; add that byte to the ASCII string if it's in printable range
			cmp bl, 32
			jb .NotInRange
			
			cmp bl, 127
			ja .NotInRange

			.IsInRange:
			mov eax, .ASCIIString
			add eax, ecx
			dec eax
			mov [eax], bl

			.NotInRange:
			call ConvertToHexString
			mov eax, kPrintString
			add eax, 6
			push eax

			; push print colors
			push 0xFF000000
			push 0xFF777777
			
			; push Y value
			mov eax, [.currentY]
			push eax
			
			; push X value
			mov eax, [.currentX]
			push eax
			call [VESAPrint]

			; retrieve the saved counter
			pop ecx
		loop .PrintBytes

		; print the ASCII equivalent string
		push .ASCIIString
		push 0xFF000000
		push 0xFF7777FF
		mov eax, [.currentY]
		push eax



		mov eax, 0x00000000
		mov al, [.hexBytesPerLine]
		mov ebx, 24
		mul ebx
		
		add eax, [.currentX]
		add eax, 16
		push eax



		call [VESAPrint]

		; update starting address
		mov eax, 0x00000000
		mov al, [.hexBytesPerLine]
		add dword [.startingAddress], eax

		; see if we're done filling the screen with text yet
		inc byte [.linesCompleted]
		cmp byte [.linesCompleted], 48
		je .LineLoopDone
	jmp .LineLoop
	.LineLoopDone:
	call KeyWait
ret
.startingAddress								dd 0x00000600
.currentX										dd 0x00000018
.currentY										dd 0x00000002
.linesCompleted									db 0x00
.ASCIIString									times 33 db 0x00
.hexBytesPerLine								db 16



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


	push tSystemInfo.kernelCopyright
	call PrintSerial

	push kCRLF
	call PrintSerial

	; display any received serial data
	mov eax, 0x00000000
	mov dx, 0x03F8
	in al, dx
	push kPrintString
	push eax
	call ConvertToHexString
	push kPrintString
	push 0xFF000000
	push 0xFF777777
	push 300
	push 20
	call [VESAPrint]
ret



.SystemInfo:
	push .systemInfoText
	push 0xFF000000
	push 0xFF7777FF
	push 2
	push 2
	call [VESAPrint]

	push tSystemInfo.CPUIDBrandString
	push 0xFF000000
	push 0xFF777777
	push 34
	push 2
	call [VESAPrint]
	call KeyWait
ret
.systemInfoText									db 'System Information', 0x00



.TimeInfo:
	mov eax, 0x00000000
	mov al, [tSystemInfo.hours]
	push kPrintString
	push eax
	call ConvertToHexString
	push kPrintString
	push 0xFF000000
	push 0xFF777777
	push 180
	push 20
	call [VESAPrint]

	mov eax, 0x00000000
	mov al, [tSystemInfo.minutes]
	push kPrintString
	push eax
	call ConvertToHexString
	push kPrintString
	push 0xFF000000
	push 0xFF777777
	push 180
	push 120
	call [VESAPrint]

	mov eax, 0x00000000
	mov al, [tSystemInfo.seconds]
	push kPrintString
	push eax
	call ConvertToHexString
	push kPrintString
	push 0xFF000000
	push 0xFF777777
	push 180
	push 220
	call [VESAPrint]

	mov eax, 0x00000000
	mov al, [tSystemInfo.ticks]
	push kPrintString
	push eax
	call ConvertToHexString
	push kPrintString
	push 0xFF000000
	push 0xFF777777
	push 180
	push 320
	call [VESAPrint]

	mov eax, 0x00000000
	mov al, [tSystemInfo.month]
	push kPrintString
	push eax
	call ConvertToHexString
	push kPrintString
	push 0xFF000000
	push 0xFF777777
	push 200
	push 20
	call [VESAPrint]

	mov eax, 0x00000000
	mov al, [tSystemInfo.day]
	push kPrintString
	push eax
	call ConvertToHexString
	push kPrintString
	push 0xFF000000
	push 0xFF777777
	push 200
	push 120
	call [VESAPrint]

	mov eax, 0x00000000
	mov al, [tSystemInfo.century]
	push kPrintString
	push eax
	call ConvertToHexString
	push kPrintString
	push 0xFF000000
	push 0xFF777777
	push 200
	push 220
	call [VESAPrint]

	mov eax, 0x00000000
	mov al, [tSystemInfo.year]
	push kPrintString
	push eax
	call ConvertToHexString
	push kPrintString
	push 0xFF000000
	push 0xFF777777
	push 200
	push 320
	call [VESAPrint]

	; print seconds since boot just for the heck of it
	push kPrintString
	push dword [tSystemInfo.secondsSinceBoot]
	call ConvertToHexString
	push kPrintString
	push 0xFF000000
	push 0xFF777777
	push 34
	push 2
	call [VESAPrint]
ret



RegDump:
	; Quick register dump routine for debugging
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	; changes:

	pushad
	push edi
	push esi
	push edx
	push ecx
	push ebx
	push eax
	push kPrintString
	push kRegDumpStr
	call StringBuild
	
	push kPrintString
	push 0xFF000000
	push 0xFF777777
	push 300
	push 2
	call [VESAPrint]

	call KeyWait
	popad
ret



VideoInfo:
	; testing DebugPrint - print the address in memory of the VESA OEM String and the string itself
	push dword [tSystemInfo.VESAOEMVendorNamePointer]
	push tSystemInfo.VESAOEMVendorNamePointer
	push 64
	push 2
	call PrintSimple32
ret