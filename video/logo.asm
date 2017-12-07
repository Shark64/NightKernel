; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; logo.asm is a part of the Night Kernel

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



LogoSplash:
	; Sets up all data structures which will be used by the memory manager
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	; changes: eax, ebx, ecx, edx

	; draw a field of random stars
	mov dl, 0x00
	mov dh, 0xFF
	.StarLoop:
		; get a random number between 0 and the current VESA screen width
		mov ecx, 0x00000000
		mov cx, [tSystemInfo.VESAWidth]
		pushad
		push ecx
		call Random
		pop eax
		mov dword [.temp], eax
		popad
		mov dword eax, [.temp]

		; get a random number between 0 and the current VESA screen height
		mov ecx, 0x00000000
		mov cx, [tSystemInfo.VESAHeight]
		pushad
		push ecx
		call Random
		pop ebx
		mov dword [.temp], ebx
		popad
		mov dword ebx, [.temp]
		
		; draw that star!
		pushad
		push 0x00FFFFFF
		push ebx
		push eax
		call [VESAPlot]
		popad

		; see if we need to do another loop
		cmp dl, dh
		je .StarsDone
		inc dl
	jmp .StarLoop
	.StarsDone:

	; determine vertical placement
	mov ebx, 0x00000000
	mov bx, [tSystemInfo.VESAHeight]
	shr ebx, 1
	sub ebx, 34

	; determine horizonal placement
	mov eax, 0x00000000
	mov ax, [tSystemInfo.VESAWidth]
	shr eax, 1
	sub eax, 64

	; and call our handy-dandy icon drawing routine!
	push ebx
	push eax
	push dword mediaLogoEnd
	push dword mediaLogo
	call VESALoadIcon
ret
.temp											dd 0x00000000
