; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; IDE Controller.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



bits 32



DriverHeader:
.signature$										db 'N', 0x01, 'g', 0x09, 'h', 0x09, 't', 0x05, 'D', 0x02, 'r', 0x00, 'v', 0x01, 'r', 0x05
.classMatch										dd 0x00000001
.subclassMatch									dd 0x00000001
.progIfMatch									dd 0x0000FFFF



IDEControllerDriverInit:
	; Performs any necessary setup of the driver
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: 

ret



IDEControllerDriverReadSector:
	; Reads sectors from disk using the LBA method
	;
	;  input:
	;   LBA-28 address of starting sector
	;	number of sectors to read
	;	Memory buffer address to which data will be written
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, ecx, edx, edi

	pop edx
	pop eax
	pop ecx
	pop edi
	push edx

	; mask off starting sector to give us 28 bits
	and eax, 0x0FFFFFFF

	mov ebx, eax								; Save LBA in EBX

	mov edx, 0x01F6								; Port to send drive and bit 24 - 27 of LBA
	shr eax, 24									; Get bit 24 - 27 in al
	or al, 11100000b							; Set bit 6 in al for LBA mode
	out dx, al

	mov edx, 0x01F2								; Port to send number of sectors
	mov al, cl									; Get number of sectors from CL
	out dx, al

	mov edx, 0x01F3								; Port to send bit 0 - 7 of LBA
	mov eax, ebx								; Get LBA from EBX
	out dx, al

	mov edx, 0x01F4								; Port to send bit 8 - 15 of LBA
	mov eax, ebx								; Get LBA from EBX
	shr eax, 8									; Get bit 8 - 15 in AL
	out dx, al

	mov edx, 0x01F5								; Port to send bit 16 - 23 of LBA
	mov eax, ebx								; Get LBA from EBX
	shr eax, 16									; Get bit 16 - 23 in AL
	out dx, al

	mov edx, 0x01F7								; Command port
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
	mov edx, 0x01F0								; Data port, in and out
	rep insw									; in to [EDI]
ret



IDEControllerDriverWriteSector:
	; Writes sectors to disk using the LBA method
	;
	;  input:
	;   LBA-28 address of starting sector
	;	number of sectors to write
	;	Memory buffer address from which data will be read
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, ecx, edx, edi

	pop edx
	pop eax
	pop ecx
	pop edi
	push edx

	; mask off starting sector to give us 28 bits
	and eax, 0x0FFFFFFF

	mov ebx, eax								; Save LBA in EBX

	mov edx, 0x01F6								; Port to send drive and bit 24 - 27 of LBA
	shr eax, 24									; Get bit 24 - 27 in al
	or al, 11100000b							; Set bit 6 in al for LBA mode
	out dx, al

	mov edx, 0x01F2								; Port to send number of sectors
	mov al, cl									; Get number of sectors from CL
	out dx, al

	mov edx, 0x01F3								; Port to send bit 0 - 7 of LBA
	mov eax, ebx								; Get LBA from EBX
	out dx, al

	mov edx, 0x01F4								; Port to send bit 8 - 15 of LBA
	mov eax, ebx								; Get LBA from EBX
	shr eax, 8									; Get bit 8 - 15 in AL
	out dx, al

	mov edx, 0x01F5								; Port to send bit 16 - 23 of LBA
	mov eax, ebx								; Get LBA from EBX
	shr eax, 16									; Get bit 16 - 23 in AL
	out dx, al

	mov edx, 0x01F7								; Command port
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
	mov edx, 0x01F0								; Data port, in and out
	mov esi, edi
	rep outsw									; out
ret
