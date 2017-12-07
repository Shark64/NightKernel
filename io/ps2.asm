; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; ps2.asm is a part of the Night Kernel

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



KeyboardInit:
	; Initializes the PS/2 keyboard
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: al, bx, ecx, edx

	call PS2ControllerWaitDataWrite
	mov al, 0xFF
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60
	; if not 0xFA, then the keyboard is missing or not responding

	; wait 5 seconds-ish for the keyboard to say the reset is done
	mov bl, 5
	mov bh, 0x00
	.loop:
		; check the keyboard status
		pushad
		call PS2ControllerWaitDataRead
		popad
		in al, 0x60
		cmp al, 0xAA
		je .resetDone
		inc bh
		cmp bl, bh
	jne .loop
	.resetDone:

	; now we set the custom stuff
	mov ebx, [tSystemInfo.delayValue]
	shr ebx, 2
	push ebx

	; illuminate scroll lock
	call PS2ControllerWaitDataWrite
	mov al, 0xED
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60
	call PS2ControllerWaitDataWrite
	mov al, 00000001b
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60
	pop ebx
	push ebx
	mov ecx, 0x00000000
	.loopA:
		inc ecx
		cmp ebx, ecx
	jne .loopA

	; set autorepeat delay and rate to fastest available
	call PS2ControllerWaitDataWrite
	mov al, 0xF3
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60
	call PS2ControllerWaitDataWrite
	mov al, 00000000b
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60

	; illuminate caps lock
	call PS2ControllerWaitDataWrite
	mov al, 0xED
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60
	call PS2ControllerWaitDataWrite
	mov al, 00000100b
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60
	pop ebx
	push ebx
	mov ecx, 0x00000000
	.loopB:
		inc ecx
		cmp ebx, ecx
	jne .loopB

	; set scan code set to 2
	call PS2ControllerWaitDataWrite
	mov al, 0xF0
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60
	call PS2ControllerWaitDataWrite
	mov al, 00000010b
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60

	; illuminate num lock
	call PS2ControllerWaitDataWrite
	mov al, 0xED
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60
	call PS2ControllerWaitDataWrite
	mov al, 00000010b
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60
	pop ebx
	mov ecx, 0x00000000
	.loopC:
		inc ecx
		cmp ebx, ecx
	jne .loopC

	; get ID bytes
	call PS2ControllerWaitDataWrite
	mov al, 0xF2
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60
	call PS2ControllerWaitDataRead
	in al, 0x60
	mov edx, tSystemInfo.keyboardType
	inc edx
	mov [edx] ,al
	call PS2ControllerWaitDataRead
	in al, 0x60
	dec edx
	mov [edx] ,al

	; enable num lock
	call KeyboardNumLockSet
ret



KeyboardNumLockSet:
	; Handles the internals of turning on Num Lock - sets the flag and turns on the LED
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: al

	; right now we just illuminate num lock
	; once we figure out how the kernel keeps track of lock modifiers, that will get added in too
	call PS2ControllerWaitDataWrite
	mov al, 0xED
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60
	call PS2ControllerWaitDataWrite
	mov al, 00000010b
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60
ret



KeyGet:
	; Returns the oldest key in the key buffer, or null if it's empty
	;  input:
	;   n/a
	;
	;  output:
	;   key pressed in lowest byte of 32-bit value
	;
	;  changes: eax, ecx, edx, esi

	mov eax, 0x00000000
	mov ecx, 0x00000000
	mov edx, 0x00000000

	; load the buffer positions
	mov cl, [kKeyBufferRead]
	mov dl, [kKeyBufferWrite]

	; if the read position is the same as the write position, the buffer is empty and we can exit
	cmp dl, cl
	je .done

	; calculate the read address into esi
	mov esi, kKeyBuffer
	add esi, ecx

	; get the byte to return into al
	mov byte al, [esi]

	; update the read position
	inc cl
	mov byte [kKeyBufferRead], cl

	.done:
	; push the data we got onto the stack and exit
	pop edx
	push eax
	push edx
ret



KeyWait:
	; Waits until a key is pressed
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ecx, edx
	
	mov ebx, 0x00000000

	.KeyLoop:
		call KeyGet
		pop eax
		cmp al, 0x00
	je .KeyLoop
ret



MouseInit:
	; Initializes the PS/2 mouse
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: ax, bx

	; disable keyboard temporarily

	call PS2ControllerWaitDataWrite
	mov al, 0xAD
	out 0x64, al

	; enable mouse
	call PS2ControllerWaitDataWrite
	mov al, 0xA8
	out 0x64, al

	; select PS/2 device 2 to send next data byte to mouse
	call PS2ControllerWaitDataWrite
	mov al, 0xD4
	out 0x64, al

	; reset command
	call PS2ControllerWaitDataWrite
	mov al, 0xFF
	out 0x60, al

	call PS2ControllerWaitDataRead
	in al, 0x60

	; wait 5 seconds-ish for the mouse to say the reset is done
	mov bl, 5
	mov bh, 0x00
	.loop:
		; check the mouse status
		pusha
		call PS2ControllerWaitDataRead
		popa
		in al, 0x60
		cmp al, 0xAA
		je .resetDone
		inc bh
		cmp bl, bh
	jne .loop
	.resetDone:
	; read mouse ID byte
	call PS2ControllerWaitDataRead
	in al, 0x60

	; get controller configuration byte
	call PS2ControllerWaitDataWrite
	mov al, 0x20
	out 0x64, al
	call PS2ControllerWaitDataRead
	in al, 0x60

	; modify the proper bits to enable IRQ and mouse clock
	or al, 00000010b
	and al, 11011111b
	push eax

	; write controller configuration byte
	call PS2ControllerWaitDataWrite
	mov al, 0x60
	out 0x64, al
	call PS2ControllerWaitDataWrite
	pop eax
	out 0x60, al

	; select PS/2 device 2 to send next data byte to mouse
	call PS2ControllerWaitDataWrite
	mov al, 0xD4
	out 0x64, al
	; begin wheel mode init by setting sample rate to 200
	call PS2ControllerWaitDataWrite
	mov al, 0xF3
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60
	call PS2ControllerWaitDataWrite
	mov al, 0xD4
	out 0x64, al
	call PS2ControllerWaitDataWrite
	mov al, 0xC8
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60

	; select PS/2 device 2 to send next data byte to mouse
	call PS2ControllerWaitDataWrite
	mov al, 0xD4
	out 0x64, al
	; begin wheel mode init by setting sample rate to 200
	call PS2ControllerWaitDataWrite
	mov al, 0xF3
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60
	call PS2ControllerWaitDataWrite
	mov al, 0xD4
	out 0x64, al
	; begin wheel mode init by setting sample rate to 200
	call PS2ControllerWaitDataWrite
	mov al, 0x64
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60

	; select PS/2 device 2 to send next data byte to mouse
	call PS2ControllerWaitDataWrite
	mov al, 0xD4
	out 0x64, al
	; begin wheel mode init by setting sample rate to 200
	call PS2ControllerWaitDataWrite
	mov al, 0xF3
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60
	call PS2ControllerWaitDataWrite
	mov al, 0xD4
	out 0x64, al
	; begin wheel mode init by setting sample rate to 200
	call PS2ControllerWaitDataWrite
	mov al, 0x50
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60

	; select PS/2 device 2 to send next data byte to mouse
	call PS2ControllerWaitDataWrite
	mov al, 0xD4
	out 0x64, al
	; begin wheel mode init by setting sample rate to 200
	call PS2ControllerWaitDataWrite
	mov al, 0xF2
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60
	call PS2ControllerWaitDataRead
	in al, 0x60

	mov byte [tSystemInfo.mouseID], al

	; see if this is one of those newfangled wheel mice
	; if it is, we skip the next section where we reapply default settings
	cmp al, 0x03
	je .skipDefaultSettings

	; select PS/2 device 2 to send next data byte to mouse
	call PS2ControllerWaitDataWrite
	mov al, 0xD4
	out 0x64, al
	; use default settings
	call PS2ControllerWaitDataWrite
	mov al, 0xF6
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60

	.skipDefaultSettings:
	; here we set the packet size
	mov byte al, [tSystemInfo.mouseID]
	cmp al, 0x03
	je .fancyMouse
	mov byte [tSystemInfo.mousePacketByteSize], 0x03
	jmp .donePacketSetting
	.fancyMouse:
	mov byte [tSystemInfo.mousePacketByteSize], 0x04
	.donePacketSetting:

	; select PS/2 device 2 to send next data byte to mouse
	call PS2ControllerWaitDataWrite
	mov al, 0xD4
	out 0x64, al
	; begin packet transmission
	call PS2ControllerWaitDataWrite
	mov al, 0xF4
	out 0x60, al
	call PS2ControllerWaitDataRead
	in al, 0x60

	; enable keyboard
	call PS2ControllerWaitDataWrite
	mov al, 0xAE
	out 0x64, al

	; limit mouse horizontally
	mov ax, [tSystemInfo.VESAWidth]
	shr ax, 1
	mov word [tSystemInfo.mouseX], ax

	; limit mouse vertically
	mov ax, [tSystemInfo.VESAHeight]
	shr ax, 1
	mov word [tSystemInfo.mouseY], ax

	; init mouse wheel index
	mov word [tSystemInfo.mouseZ], 0x7777
ret



PS2ControllerWaitDataRead:
	; Reads data from the PS/2 controller
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: al, ebx, ecx

	mov dword [tSystemInfo.lastError], 0x00000000

	; set timeout value for roughly a couple seconds
	mov ebx, [tSystemInfo.delayValue]
	shr ebx, 8
	mov ecx, 0x00000000

	.waitLoop:
		; wait until the controller is ready
		in al, 0x64
		and al, 00000001b
		cmp al, 0x01
		je .done
		; if we get here, the controller isn't ready, so see if we've timed out
		inc ecx
		cmp ebx, ecx
	jne .waitLoop
	; if we get here, we've timed out
	mov dword [tSystemInfo.lastError], 0x0000FF00
	.done:
ret



PS2ControllerWaitDataWrite:
	; Waits with timeout until the PS/2 controller is ready to accept data, then returns
	; Note: Uses the system delay value for timeout since interrupts may be disabled upon calling
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: ax, ebx, ecx

	mov dword [tSystemInfo.lastError], 0x00000000

	; set timeout value for roughly a couple seconds
	mov ebx, [tSystemInfo.delayValue]
	shr ebx, 8
	mov ecx, 0x00000000

	.waitLoop:
		; wait until the controller is ready
		in al, 0x64
		and al, 00000010b
		cmp al, 0x00
		je .done
		; if we get here, the controller isn't ready, so see if we've timed out
		inc ecx
		cmp ebx, ecx
	jne .waitLoop
	; if we get here, we've timed out
	mov ax, 0xFF01
	jmp .done
	.done:
ret
