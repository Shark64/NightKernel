; Night Kernel
; Copyright 1995 - 2018 by mercury0x0d
; hardware.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



; 32-bit function listing:
; A20Enable						Enables the A20 line of the processor's address bus using the "Fast A20 enable" method
; CPUSpeedDetect				Determines how many iterations of random activities the CPU is capable of in one second
; PITInit						Init the PIT for our timing purposes
; Random						Returns a random number using the XORShift method
; Reboot						Performs a warm reboot of the PC



bits 32



A20Enable:
	; Enables the A20 line of the processor's address bus using the "Fast A20 enable" method
	; Since A20 support is critical, this code will print an error then intentionally hang if unsuccessful
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a

	push ebp
	mov ebp, esp

	in al, 0x92
	or al, 00000010b
	out 0x92, al

	; verify it worked
	mov al, 0x00
	in al, 0x92
	and al, 0x02
	cmp al, 0
	jnz .success

	; it failed, so we have to say so
	push 4
	push 0
	push fastA20Fail$
	call Print32
	call PrintRegs32

	.success:

	mov esp, ebp
	pop ebp
ret



CPUSpeedDetect:
	; Determines how many iterations of random activities the CPU is capable of in one second
	;
	;  input:
	;   dummy value
	;
	;  output:
	;   number of iterations

	push ebp
	mov ebp, esp

	mov ebx, 0x00000000
	mov ecx, 0x00000000
	mov edx, 0x00000000
	mov al, [tSystem.ticks]
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
		mov al, [tSystem.ticks]
		cmp al, ah
	jne .loop1

	mov dword [ebp + 8], ecx

	mov esp, ebp
	pop ebp
ret



PITInit:
	; Init the PIT for our timing purposes (256 ticks per second)
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a

	push ebp
	mov ebp, esp

	mov ax, 1193180 / 256

	mov al, 00110110b
	out 0x43, al

	out 0x40, al
	xchg ah, al
	out 0x40, al

	mov esp, ebp
	pop ebp
ret



Random:
	; Returns a random number using the XORShift method
	;
	;  input:
	;   number limit
	;
	;  output:
	;   32-bit random number between 0 and the number limit

	push ebp
	mov ebp, esp

	mov ebx, [ebp + 8]

	; use good ol' XORShift to get a random
	mov eax, [.randomSeed]
	mov edx, eax
	shl eax, 13
	xor eax, edx
	mov edx, eax
	shr eax, 17
	xor eax, edx
	mov edx, eax
	shl eax, 5
	xor eax, edx
	mov [.randomSeed], eax

	; use some modulo to make sure the random is below the requested number
	mov edx, 0x00000000
	div ebx
	mov eax, edx

	; throw the numbers on the stack and get going!
	mov dword [ebp + 8], eax

	mov esp, ebp
	pop ebp
ret
.randomSeed										dd 0x92D68CA2



Reboot:
	; Performs a warm reboot of the PC
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a

	push ebp
	mov ebp, esp

	mov dx, 0x92
	in al, dx
	or al, 00000001b
	out dx, al

	; and now, for the return we'll never reach...

	mov esp, ebp
	pop ebp
ret



fastA20Fail$									db 'Cannot start. Attempt to use Fast A20 Enable failed.', 0x00
