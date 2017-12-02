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



DiskATALBARead:
	; from osdev
	; ATA read sectors (LBA mode) 
	;
	; param EAX Logical Block Address of sector
	; param CL  Number of sectors to read
	; param EDI The address of buffer to put data obtained from disk
	;
	; return None


	mov eax, 0x00000000
	mov cl, 0x01
	mov edi, 0x00010000

	pushfd
	and eax, 0x0FFFFFFF
	push eax
	push ebx
	push ecx
	push edx
	push edi

	mov ebx, eax								; Save LBA in RBX

	mov edx, 0x01F6								; Port to send drive and bit 24 - 27 of LBA
	shr eax, 24									; Get bit 24 - 27 in al
	or al, 11100000b							; Set bit 6 in al for LBA mode
	out dx, al

	mov edx, 0x01F2								; Port to send number of sectors
	mov al, cl									; Get number of sectors from CL
	out dx, al

	mov edx, 0x1F3								; Port to send bit 0 - 7 of LBA
	mov eax, ebx								; Get LBA from EBX
	out dx, al

	mov edx, 0x1F4								; Port to send bit 8 - 15 of LBA
	mov eax, ebx								; Get LBA from EBX
	shr eax, 8									; Get bit 8 - 15 in AL
	out dx, al

	mov edx, 0x1F5								; Port to send bit 16 - 23 of LBA
	mov eax, ebx								; Get LBA from EBX
	shr eax, 16									; Get bit 16 - 23 in AL
	out dx, al

	mov edx, 0x1F7								; Command port
	mov al, 0x20								; Read with retry.
	out dx, al

	.still_going:
		in al, dx
		test al, 8								; the sector buffer requires servicing.
	jz .still_going								; until the sector buffer is ready.

	mov eax, 256								; to read 256 words = 1 sector
	xor bx, bx
	mov bl, cl									; read CL sectors
	mul bx
	mov ecx, eax								; ECX is counter for INSW
	mov edx, 0x1F0								; Data port, in and out
	rep insw									; in to [RDI]

	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	popfd
ret



DiskATALBAWrite:
	; from osdev
	; ATA write sectors (LBA mode) 
	;
	; param EAX Logical Block Address of sector
	; param CL  Number of sectors to write
	; param EDI The address of data to write to the disk
	;
	; return None

	pushfd
	and eax, 0x0FFFFFFF
	push eax
	push ebx
	push ecx
	push edx
	push edi

	mov ebx, eax								; Save LBA in RBX

	mov edx, 0x01F6								; Port to send drive and bit 24 - 27 of LBA
	shr eax, 24									; Get bit 24 - 27 in al
	or al, 11100000b							; Set bit 6 in al for LBA mode
	out dx, al

	mov edx, 0x01F2								; Port to send number of sectors
	mov al, cl									; Get number of sectors from CL
	out dx, al

	mov edx, 0x1F3								; Port to send bit 0 - 7 of LBA
	mov eax, ebx								; Get LBA from EBX
	out dx, al

	mov edx, 0x1F4								; Port to send bit 8 - 15 of LBA
	mov eax, ebx								; Get LBA from EBX
	shr eax, 8									; Get bit 8 - 15 in AL
	out dx, al

	mov edx, 0x1F5								; Port to send bit 16 - 23 of LBA
	mov eax, ebx								; Get LBA from EBX
	shr eax, 16									; Get bit 16 - 23 in AL
	out dx, al

	mov edx, 0x1F7								; Command port
	mov al, 0x30								; Write with retry.
	out dx, al

	.still_going:  in al, dx
		test al, 8								; the sector buffer requires servicing.
	jz .still_going								; until the sector buffer is ready.

	mov eax, 256								; to read 256 words = 1 sector
	xor bx, bx
	mov bl, cl									; write CL sectors
	mul bx
	mov ecx, eax								; ECX is counter for OUTSW
	mov edx, 0x1F0								; Data port, in and out
	mov esi, edi
	rep outsw									; out

	pop edi
	pop edx
	pop ecx
	pop ebx
	pop eax
	popfd
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



Random:
	; Returns a random number using the XORShift method
	;  input:
	;   number limit
	;
	;  output:
	;   32-bit random number between 0 and the number limit
	;
	;  changes: eax, ebx, ecx, edx

	pop ecx
	pop ebx

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
	push eax
	push ecx
ret
.randomSeed										dd 0x92D68CA2



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
