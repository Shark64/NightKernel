; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; hardware.asm is a part of the Night Kernel

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



A20Enable:
	; Enables the A20 line of the processor's address bus using the "Fast A20 enable" method
	; Since A20 support is critical, this code will print an error then intentionally hang if unsuccessful
	;  input:
	;   n/a
	;
	;  output:
	;   n/a

	in al, 0x92
	or al, 0x02
	out 0x92, al

	; verify it worked
	in al, 0x92
	and al, 0x02
	cmp al, 0
	jnz .success

	; it failed, so we have to say so
	push kFastA20Fail
	call PrintSimple16
	jmp $
	.success:
ret



CPUSpeedDetect:
	; Determines how many iterations of random activities the CPU is capable of in one second
	;  input:
	;   n/a
	;
	;  output:
	;   number of iterations
	;
	;  changes: ebx, ecx, edx

	mov ebx, 0x00000000
	mov ecx, 0x00000000
	mov edx, 0x00000000
	mov al, [tSystemInfo.ticks]
	mov ah, al
	dec ah
	.loop1:
		inc ebx
		push ebx
		inc ecx
		push ecx
		inc edx
		push edx
		pop edx
		pop ecx
		pop ebx
		mov al, [tSystemInfo.ticks]
		cmp al, ah
	jne .loop1
	pop ebx
	push ecx
	push ebx
ret



Random:
	; Returns a random number
	;  input:
	;   n/a
	;
	;  output:
	;   32-bit random number
	;
	;  changes: eax, ecx, edx

	mov ecx, [tSystemInfo.secondsSinceBoot]
	mov edx, [tSystemInfo.ticks]
	add ecx, edx
	mov edx, ecx
	shr edx, 12
	xor ecx, edx
	mov edx, ecx
	shl edx, 25
	xor ecx, edx
	mov edx, ecx
	shr edx, 27
	xor ecx, edx
	mov eax, [tSystemInfo.ticks]
	mul ecx
	mov ecx, [tSystemInfo.mouseX]
	add eax, ecx
	add ecx, [tSystemInfo.mouseY]
	add eax, ecx
	pop edx
	push eax
	push edx
ret



PITInit:
	; Init the PIT for our timing purposes
	;  input:
	;   n/a
	;
	;  output:
	;   n/a

	mov ax, 1193180 / 256

	mov al, 00110110b
	out 0x43, al

	out 0x40, al
	xchg ah, al
	out 0x40, al
ret



Reboot:
	; Performs a warm reboot of the PC
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: al, dx

	mov dx, 0x92
	in al, dx
	or al, 00000001b
	out dx, al

	; and now, for the return we'll never reach...
ret
