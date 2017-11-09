; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; screen.asm is a part of the Night Kernel

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

; Thanks to Tom Ehlert for optimizations used in the VESA text printing code which resulted in a 30% speedup




bits 16



VESAInit:
	; Determines the highest resolution VESA screen mode avaialable and sets it,
	; copies some pertinent info into the system structures
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	; changes: 

	; get video controller info
	mov ax, 0x4F00
	mov di, tVESAInfoBlock
	sti
	int 0x10
	cli
	cmp ax, 0x004F
	je .GetModes
	; if we get here, the call the the VBE BIOS failed, so we print a message and hang
	push kVESAUnsupported
	call PrintSimple16
	jmp $

	.GetModes:
	; step through the VESA modes available and find the best one available
	mov ds, [tVESAInfoBlock.VideoModeListSegment]
	mov si, [tVESAInfoBlock.VideoModeListOffset]
	mov edi, 0x00000000
	mov edx, 0x00000000
	.ReadLoop:
		mov cx, [si]

		;see if the mode = 0xffff so we know if we're all done
		cmp cx, 0xFFFF
		je .DoneLoop

		; get info on that mode
		mov ax, 0x4F01
		mov di, tVESAModeInfo
		sti
		int 0x10
		cli

		; skip this mode if it doesn't support a linear frame buffer
		cmp dword [tVESAModeInfo.PhysBasePtr], 0x00000000
		je .doNextIteration

		push edx
		mov eax, 0x00000000
		mov ebx, 0x00000000
		mov word ax, [tVESAModeInfo.YResolution]
		mov word bx, [tVESAModeInfo.BytesPerScanline]
		mul ebx
		pop edx

		; loop again if this mode doesn't score higher than our current record holder
		cmp eax, edx
		jna .doNextIteration
		; it did score higher, so let's make note of it
		mov gs, cx
		mov edx, eax

		.doNextIteration:
		add si, 2
	jmp .ReadLoop
	.DoneLoop:
	mov ax, 0xbeef

	; get info on the final mode
	mov ax, 0x4F01
	mov cx, gs
	mov di, tVESAModeInfo
	sti
	int 0x10
	cli

	; set that mode
	mov ax, 0x4F02
	mov bx, cx
	sti
	int 0x10
	cli
ret



bits 32



VESAClearScreen:
	; Erases the VESAS screen to black
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	; changes: eax, ebx, ecx, edx

	; calculate how many pixels are on the screen
	mov eax, 0x00000000
	mov ebx, 0x00000000
	mov ax, [tSystemInfo.VESAWidth]
	mov bx, [tSystemInfo.VESAHeight]
	mul ebx

	; multiply by color depth to find how many bytes we need to write
	mov ebx, 0x00000000
	mov bl, [tSystemInfo.VESAColorDepth]
	shr bl, 3
	mul ebx

	; determine the address of the LFB and the last byte to write
	mov ebx, [tSystemInfo.VESALFBAddress]
	add eax, ebx
	
	.Loop:
		mov byte [ebx], 0x00
		cmp eax, ebx
		je .LoopDone
		inc ebx
	jmp .Loop
	.LoopDone:
ret



VESAPlot24:
	; Draws a pixel directly to the VESA linear framebuffer
	;  input:
	;   horizontal position
	;   vertical position
	;   color attribute
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, ecx, esi

	pop esi									; get return address for end ret
	pop ebx									; get horizontal position
	pop eax									; get vertical position
	pop ecx									; get color attribute
	push esi								; push return address back on the stack

	; exit if we're writing outside the screen
	mov edx, 0x00000000
	mov dx, [tSystemInfo.VESAWidth]
	cmp bx, dx
	jae .done
	mov dx, [tSystemInfo.VESAHeight]
	cmp ax, dx
	jae .done

	; calculate write position
	mov dx, [tVESAModeInfo.XResolution]
	mul edx
	add eax, ebx
	mov edx, 3
	mul edx
	add eax, [tVESAModeInfo.PhysBasePtr]

	; do the write
	mov byte [eax], cl
	inc eax
	ror ecx, 8
	mov byte [eax], cl
	inc eax
	ror ecx, 8
	mov byte [eax], cl
	ror ecx, 16
.done:
ret



VESAPlot32:
	; Draws a pixel directly to the VESA linear framebuffer
	;  input:
	;   horizontal position
	;   vertical position
	;   color attribute
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, ecx, esi

	pop esi									; get return address for end ret
	pop ebx									; get horizontal position
	pop eax									; get vertical position
	pop ecx									; get color attribute
	push esi								; push return address back on the stack

	; exit if we're writing outside the screen
	mov edx, 0x00000000
	mov dx, [tSystemInfo.VESAWidth]
	cmp bx, dx
	jae .done
	mov dx, [tSystemInfo.VESAHeight]
	cmp ax, dx
	jae .done

	; calculate write position
	mov edx, 0x00000000
	mov dx, [tVESAModeInfo.XResolution]
	mul edx
	add eax, ebx
	mov edx, 4
	mul edx
	add eax, [tVESAModeInfo.PhysBasePtr]

	; do the write
	mov dword [eax], ecx
.done:
ret



VESAPrint24:
	; Prints an ASCIIZ string directly to the VESA framebuffer in 24 bit color modes
	;  input:
	;   horizontal position
	;   vertical position
	;   color attribute
	;   address of string to print
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, ecx, edx, ebp, edi, esi

	pop edx									; get return address for end ret
	pop ebx									; get horizontal position
	pop eax									; get vertical position
	pop ecx									; get text color
	pop ebp									; get background color
	pop esi									; get string address
	push edx								; push return address back on the stack

	; calculate write position into edi and save to the stack
	mov edx, 0
	mov dx, [tVESAModeInfo.XResolution]		; can probably be optimized to use bytes per scanline field to eliminate doing multiply
	mul edx
	add ax, bx
	mov edx, 3
	mul edx
	add eax, [tVESAModeInfo.PhysBasePtr]
	mov edi, eax
	push edi

	; keep the number of bytes in a scanline handy in edx for later
	mov edx, 0
	mov dx, [tVESAModeInfo.BytesPerScanline]

	; time to step through the string and draw it
	.StringDrawLoop:
		; put the first character of the string into bl
		mov byte bl, [esi]

		; see if the char we just got is null - if so, we exit
		cmp bl, 0x00
		jz .End

		; it wasn't, so we need to calculate the beginning of the data for this char in the font table into eax
		mov eax, 0
		mov al, bl
		mov bh, 16
		mul bh
		add eax, kKernelFont

		.FontBytesLoop:
			; save the contents of edx and move font byte 1 into dl, making a backup copy in dh
			push edx
			mov byte dl, [eax]
			mov byte dh, dl

			; plot accordingly
			and dl, 10000000b
			cmp dl, 0
			jz .PointSkipA
			.PointPlotA:
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 16
			jmp .PointDoneA
			.PointSkipA:
			push ecx
			mov ecx, ebp
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 16
			pop ecx
			.PointDoneA:
			mov byte dl, dh

			; plot accordingly
			and dl, 01000000b
			cmp dl, 0
			jz .PointSkipB
			.PointPlotB:
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 16
			jmp .PointDoneB
			.PointSkipB:
			push ecx
			mov ecx, ebp
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 16
			pop ecx
			.PointDoneB:
			mov byte dl, dh

			; plot accordingly
			and dl, 00100000b
			cmp dl, 0
			jz .PointSkipC
			.PointPlotC:
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 16
			jmp .PointDoneC
			.PointSkipC:
			push ecx
			mov ecx, ebp
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 16
			pop ecx
			.PointDoneC:
			mov byte dl, dh

			; plot accordingly
			and dl, 00010000b
			cmp dl, 0
			jz .PointSkipD
			.PointPlotD:
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 16
			jmp .PointDoneD
			.PointSkipD:
			push ecx
			mov ecx, ebp
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 16
			pop ecx
			.PointDoneD:
			mov byte dl, dh

			; plot accordingly
			and dl, 00001000b
			cmp dl, 0
			jz .PointSkipE
			.PointPlotE:
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 16
			jmp .PointDoneE
			.PointSkipE:
			push ecx
			mov ecx, ebp
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 16
			pop ecx
			.PointDoneE:
			mov byte dl, dh

			; plot accordingly
			and dl, 00000100b
			cmp dl, 0
			jz .PointSkipF
			.PointPlotF:
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 16
			jmp .PointDoneF
			.PointSkipF:
			push ecx
			mov ecx, ebp
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 16
			pop ecx
			.PointDoneF:
			mov byte dl, dh

			; plot accordingly
			and dl, 00000010b
			cmp dl, 0
			jz .PointSkipG
			.PointPlotG:
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 16
			jmp .PointDoneG
			.PointSkipG:
			push ecx
			mov ecx, ebp
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 16
			pop ecx
			.PointDoneG:
			mov byte dl, dh

			; plot accordingly
			and dl, 00000001b
			cmp dl, 0
			jz .PointSkipH
			.PointPlotH:
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 16
			jmp .PointDoneH
			.PointSkipH:
			push ecx
			mov ecx, ebp
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 8
			mov byte [edi], cl
			inc edi
			ror ecx, 16
			pop ecx
			.PointDoneH:
			mov byte dl, dh

			; increment the font pointer
			inc eax

			; set the framebuffer pointer to the next line
			sub edi, 24
			pop edx
			add edi, edx

			dec bh
			cmp bh, 0
		jne .FontBytesLoop


		; increment the string pointer
		inc esi

		;restore the framebuffer pointer to its original value, save a copy adjusted for the next loop
		pop edi
		add edi, 24
		push edi
		jmp .StringDrawLoop

	.End:

	;get rid of that extra saved value
	pop edi
ret



VESAPrint32:
	; Prints an ASCIIZ string directly to the VESA framebuffer in 32 bit color modes
	;  input:
	;   horizontal position
	;   vertical position
	;   color
	;   background color
	;   address of string to print
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, ecx, edx, ebp, edi, esi

	pop edx							; get return address for end ret
	pop ebx							; get horizontal position
	pop eax							; get vertical position
	pop ecx							; get text color
	pop ebp							; get background color
	pop esi							; get string address
	push edx							; push return address back on the stack

	; calculate write position into edi and save to the stack
	mov edx, 0
	mov dx, [tVESAModeInfo.XResolution] ; can probably be optimized to use bytes per scanline field to eliminate doing multiply
	mul edx
	add ax, bx
	mov edx, 4
	mul edx
	add eax, [tVESAModeInfo.PhysBasePtr]
	mov edi, eax
	push edi

	; keep the number of bytes in a scanline handy in edx for later
	mov edx, 0
	mov dx, [tVESAModeInfo.BytesPerScanline]

	; time to step through the string and draw it
	.StringDrawLoop:
		; put the first character of the string into bl
		mov byte bl, [esi]

		; see if the char we just got is null - if so, we exit
		cmp bl, 0x00
		jz .End

		; it wasn't, so we need to calculate the beginning of the data for this char in the font table into eax
		mov eax, 0
		mov al, bl
		mov bh, 16
		mul bh
		add eax, kKernelFont

		.FontBytesLoop:
			; save the contents of edx and move font byte 1 into dl, making a backup copy in dh
			push edx
			mov byte dl, [eax]
			mov byte dh, dl

			; plot accordingly
			push eax

			test dl, 10000000b
			cmovnz eax, ecx
			cmovz  eax, ebp
			mov [edi], eax

			test dl, 1000000b
			cmovnz eax, ecx
			cmovz  eax, ebp
			mov [edi+4], eax

			test dl, 100000b
			cmovnz eax, ecx
			cmovz  eax, ebp
			mov [edi+8], eax

			test dl, 10000b
			cmovnz eax, ecx
			cmovz  eax, ebp
			mov [edi+12], eax

			test dl, 1000b
			cmovnz eax, ecx
			cmovz  eax, ebp
			mov [edi+16], eax

			test dl, 100b
			cmovnz eax, ecx
			cmovz  eax, ebp
			mov [edi+20], eax

			test dl, 10b
			cmovnz eax, ecx
			cmovz  eax, ebp
			mov [edi+24], eax

			test dl, 1b
			cmovnz eax, ecx
			cmovz  eax, ebp
			mov [edi+28], eax

			add edi,32

			pop eax

			; increment the font pointer
			inc eax

			; set the framebuffer pointer to the next line
			sub edi, 32
			pop edx
			add edi, edx

			dec bh
			cmp bh, 0
		jne .FontBytesLoop


		; increment the string pointer
		inc esi

		;restore the framebuffer pointer to its original value, save a copy adjusted for the next loop
		pop edi
		add edi, 32
		push edi
	jmp .StringDrawLoop

	.End:

	;get rid of that extra saved value
	pop edi
ret
