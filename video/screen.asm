; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; screen.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



bits 16



ClearScreen16:
	; Clears the text mode screen
	; Note: For use in Protected Mode only
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: cx, gx, si

	mov cx, 0xB800
	mov gs, cx
	mov si, 0
	mov cx, 0x4000
	.aloop:
		mov byte [gs:si], 0
		inc si
	loop .aloop

	; reset the cursor position
	mov byte [cursorX], 1
	mov byte [cursorY], 1
ret



Print16:
	; Prints an ASCIIZ failure message directly to the screen.
	; Note: Uses text mode (assumed already set) not VESA.
	; Note: For use in Real Mode only.
	;
	;  input:
	;   address of string to print
	;
	;  output:
	;   n/a
	;
	;  changes: ax, bx, cx, es, gs, di, si

	pop ax
	pop si
	push ax
	
	; preserve es
	push es

	; set up the foreground and background colors
	mov bl, [backColor]
	mov cl, [textColor]
	and bx, 0x0F
	and cx, 0x0F

	rol bl, 4
	or cl, bl
	mov [.color], cl

	; set up the segment
	mov ax, 0xB800
	mov es, ax
	mov di, 0x0000
	mov ax, 0x0000

	; adjust di for horizontal position
	mov ax, 0x0000
	mov al, [cursorX]
	dec ax
	shl ax, 1
	mov bx, di
	add bx, ax
	mov di, bx

	; adjust di for vertical position
	mov ax, 0x0000
	mov al, [cursorY]
	dec ax

	; use a pair of shifts to multiply by 80
	mov bx, ax
	shl ax, 6
	shl bx, 4
	add ax, bx

	; use a shift to multiply by 2 to allow for the fact that it takes 2 bytes to render a single character to the screen
	shl ax, 1

	mov bx, di
	add bx, ax
	mov di, bx

	; load the color attribute to bl
	mov bl, [.color]

	.loopBegin:
		lodsb
		; have we reached the string end? if yes, exit the loop
		cmp al, 0x00
		je .end

		mov byte[es:di], al
		inc di
		mov byte[es:di], bl
		inc di
	jmp .loopBegin
	.end:

	; update cursor X position
	mov byte [cursorX], 1

	; update cursor Y position
	mov al, [cursorY]
	inc al
	mov [cursorY], al

	; see if we need to scroll the output
	mov bl, byte [kMaxLines]
	inc bl
	cmp al, bl
	jne .SkipScroll

		; if we get here, we need to scroll the display
		mov cx, word [kBytesPerScreen]

		; divide the counter by 16 since we're copying that many bytes at a time
		shr cx, 4

		mov ax, 0xB800
		mov si, 160
		mov di, 0
		mov gs, ax
		.copyLoop:
			; read data in
			mov eax, [gs:si]
			add si, 4
			mov ebx, [gs:si]
			add si, 4
			mov ebp, [gs:si]
			add si, 4
			mov edx, [gs:si]
			add si, 4
			
			; write data out
			mov [gs:di], eax
			add di, 4
			mov [gs:di], ebx
			add di, 4
			mov [gs:di], ebp
			add di, 4
			mov [gs:di], edx
			add di, 4
		loop .copyLoop

		; update the cursor Y position
		mov al, byte [kMaxLines]
		mov byte [cursorY], al

	.SkipScroll:
	; restore es
	pop es
ret
.color											db 0x00



PrintRegs16:
	; Quick register dump routine for real mode
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	; changes:

	; push all once to save the registers
	pusha

	; pusha once more for printing
	pusha

	; get di
	pop ax

	; convert it to a string
	mov bx, .output2$
	add bx, 15
	push bx
	push ax
	call ConvertWordToHexString16


	; get si
	pop ax

	; convert it to a string
	mov bx, .output2$
	add bx, 4
	push bx
	push ax
	call ConvertWordToHexString16


	; get bp
	pop ax

	; convert it to a string
	mov bx, .output2$
	add bx, 37
	push bx
	push ax
	call ConvertWordToHexString16


	; get sp
	pop ax

	; convert it to a string
	mov bx, .output2$
	add bx, 26
	push bx
	push ax
	call ConvertWordToHexString16


	; get bx
	pop ax

	; convert it to a string
	mov bx, .output1$
	add bx, 15
	push bx
	push ax
	call ConvertWordToHexString16


	; get dx
	pop ax

	; convert it to a string
	mov bx, .output1$
	add bx, 37
	push bx
	push ax
	call ConvertWordToHexString16


	; get cx
	pop ax

	; convert it to a string
	mov bx, .output1$
	add bx, 26
	push bx
	push ax
	call ConvertWordToHexString16


	; get ax
	pop ax

	; convert it to a string
	mov bx, .output1$
	add bx, 4
	push bx
	push ax
	call ConvertWordToHexString16

	push .output1$
	call Print16

	push .output2$
	call Print16

	popa
ret
.output1$										db ' AX 0000    BX 0000    CX 0000    DX 0000 ', 0x00
.output2$										db ' SI 0000    DI 0000    SP 0000    BP 0000 ', 0x00
; EDI ESI EBP ESP EBX EDX ECX EAX



bits 32



ClearScreen32:
	; Clears the text mode screen
	; Note: For use in Protected Mode only
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: cx, si

	mov cx, 0x4000
	mov esi, 0xB8000
	.aloop:
		mov byte [esi], 0
		inc esi
	loop .aloop

	; reset the cursor position
	call HomeCursor
ret



HomeCursor:
	; Returns the text mode cursor to the "home" (upper left) position
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, cx, esi, edi

	mov byte [cursorX], 1
	mov byte [cursorY], 1
ret



Print32:
	; Prints an ASCIIZ failure message directly to the screen.
	; Note: Uses text mode (assumed already set) not VESA.
	; Note: For use in Real Mode only.
	;
	;  input:
	;   address of string to print
	;
	;  output:
	;   n/a
	;
	;  changes: eax, bx, cx, esi, edi

	pop eax
	pop esi
	push eax
	
	; set up the foreground and background colors
	mov bl, [backColor]
	mov cl, [textColor]
	and bx, 0x0F
	and cx, 0x0F

	rol bl, 4
	or cl, bl
	mov [.color], cl

	; set up the pointer
	mov edi, 0xB8000

	; adjust di for horizontal position
	mov ax, 0x0000
	mov al, [cursorX]
	dec ax
	shl ax, 1
	mov bx, di
	add bx, ax
	mov di, bx

	; adjust di for vertical position
	mov ax, 0x0000
	mov al, [cursorY]
	dec ax

	; use a pair of shifts to multiply by 80
	mov bx, ax
	shl ax, 6
	shl bx, 4
	add ax, bx

	; use a shift to multiply by 2 to allow for the fact that it takes 2 bytes to render a single character to the screen
	shl ax, 1

	mov bx, di
	add bx, ax
	mov di, bx

	; load the color attribute to bl
	mov bl, [.color]

	.loopBegin:
		lodsb
		; have we reached the string end? if yes, exit the loop
		cmp al, 0x00
		je .end

		mov byte[edi], al
		inc edi
		mov byte[edi], bl
		inc edi
	jmp .loopBegin
	.end:

	; update cursor X position
	mov byte [cursorX], 1

	; update cursor Y position
	mov al, [cursorY]
	inc al
	mov [cursorY], al

	; see if we need to scroll the output
	mov bl, byte [kMaxLines]
	inc bl
	cmp al, bl
	jne .SkipScroll

		; if we get here, we need to scroll the display
		mov eax, 0x00000000
		mov ax, word [kBytesPerScreen]
		mov ecx, eax

		; divide the counter by 16 since we're copying that many bytes at a time
		shr ecx, 4

		mov esi, 0xB80A0
		mov edi, 0xB8000
		.copyLoop:
			; read data in
			mov eax, [esi]
			add esi, 4
			mov ebx, [esi]
			add esi, 4
			mov ebp, [esi]
			add esi, 4
			mov edx, [esi]
			add esi, 4
			
			; write data out
			mov [edi], eax
			add edi, 4
			mov [edi], ebx
			add edi, 4
			mov [edi], ebp
			add edi, 4
			mov [edi], edx
			add edi, 4
		loop .copyLoop

		; update the cursor Y position
		mov al, byte [kMaxLines]
		mov byte [cursorY], al

	.SkipScroll:
ret
.color											db 0x00



PrintRAM32:
	; Prints a range of RAM bytes to the screen
	;
	;  input:
	;   starting address
	;	number of lines
	;
	;  output:
	;   n/a
	;
	; changes:

	pop edx
	pop edi
	pop ecx
	push edx

	.LineLoop:
		; save the line counter and address pointer
		push ecx
		push edi

		; set up some variables for the future
		mov esi, edi
		mov ebx, .ascii$

		; load the address of the ASCII text string to the stack for StringBuild()
		push .ascii$

		; load 16 bytes to the stack
		mov eax, 0x00000000
		mov ecx, 16
		add edi, 15
		.BytesLoad:
			; load a byte to the stack for the hex sequence section...
			mov al, [edi]
			dec edi
			push eax

			; ...and load a byte to the ASCII section
			lodsb

			; add that byte to the ASCII string if it's in printable range
			cmp al, 32
			jb .NotInRange
			
			cmp al, 127
			ja .NotInRange

			.IsInRange:
			mov [ebx], al

			.NotInRange:
			inc ebx
		loop .BytesLoad

		; set up the rest of the StringBuild() call
		inc edi
		push edi
		push .output$
		push .format$
		call StringBuild

		; print the string we just built
		push .output$
		call Print32

		; clear the output string, otherwise StringBuild() will throw a fit. Possible bug?
		push 0
		push 80
		push .output$
		call MemFill

		; clear the ASCII string too
		push 46
		push 16
		push .ascii$
		call MemFill

		; restore our values
		pop edi
		pop ecx
		add edi, 16
	loop .LineLoop
ret
.format$										db '^p8 ^h  ^p2 ^h ^h ^h ^h ^h ^h ^h ^h ^h ^h ^h ^h ^h ^h ^h ^h   ^s ', 0x00
.output$										times 81 db 0x00
.ascii$											db '................', 0x00



PrintRegs32:
	; Quick register dump routine for real mode
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	; changes:

	; push all once to save the registers
	pusha

	; pusha once more for printing
	pusha

	; get di
	pop eax

	; convert it to a string
	mov ebx, .output2$
	add ebx, 21
	push ebx
	push eax
	call ConvertToHexString


	; get si
	pop eax

	; convert it to a string
	mov ebx, .output2$
	add ebx, 5
	push ebx
	push eax
	call ConvertToHexString


	; get bp
	pop eax

	; convert it to a string
	mov ebx, .output2$
	add ebx, 53
	push ebx
	push eax
	call ConvertToHexString


	; get sp
	pop eax

	; convert it to a string
	mov ebx, .output2$
	add ebx, 37
	push ebx
	push eax
	call ConvertToHexString


	; get bx
	pop eax

	; convert it to a string
	mov ebx, .output1$
	add ebx, 21
	push ebx
	push eax
	call ConvertToHexString


	; get dx
	pop eax

	; convert it to a string
	mov ebx, .output1$
	add ebx, 53
	push ebx
	push eax
	call ConvertToHexString


	; get cx
	pop eax

	; convert it to a string
	mov ebx, .output1$
	add ebx, 37
	push ebx
	push eax
	call ConvertToHexString


	; get ax
	pop eax

	; convert it to a string
	mov bx, .output1$
	add bx, 5
	push ebx
	push eax
	call ConvertToHexString

	push .output1$
	call Print32

	push .output2$
	call Print32

	popa
ret
.output1$										db ' EAX 00000000    EBX 00000000    ECX 00000000    EDX 00000000 ', 0x00
.output2$										db ' ESI 00000000    EDI 00000000    ESP 00000000    EBP 00000000 ', 0x00
cursorX											db 0x01
cursorY											db 0x01
textColor										db 0x07
backColor										db 0x00
kMaxLines										db 25
kBytesPerScreen									dw 4000