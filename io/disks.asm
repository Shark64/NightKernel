; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; disks.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



bits 32





IDECmd:
	; Reads sectors from disk using the CHS method
	;  input:
	;   CHS address of starting sector
	;		Cylinder is first two bytes of register, beginning with MSB (up to 65535)
	;		Head is next byte (0 - 15)
	;		Sector is LSB (0 is reserved; value is usually 1 - 63 for 31.5 GB disks, can be up to 255 for 127.5 GB disks)
	;	number of sectors to read
	;	Memory buffer address to which data will be written
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, ecx, edx, edi

	pop eax
	pop ebx

	mov word [ATARegData], ax
	add word [ATARegData], 0x00
	mov word [ATARegError], ax
	add word [ATARegError], 0x01
	mov word [ATARegFeatures], ax
	add word [ATARegFeatures], 0x01
	mov word [ATARegSecCount0], ax
	add word [ATARegSecCount0], 0x02
	mov word [ATARegLBA0], ax
	add word [ATARegLBA0], 0x03
	mov word [ATARegLBA1], ax
	add word [ATARegLBA1], 0x04
	mov word [ATARegLBA2], ax
	add word [ATARegLBA2], 0x05
	mov word [ATARegHDDevSel], ax
	add word [ATARegHDDevSel], 0x06
	mov word [ATARegCommand], ax
	add word [ATARegCommand], 0x07
	mov word [ATARegStatus], ax
	add word [ATARegStatus], 0x07
	mov word [ATARegSecCount1], ax
	add word [ATARegSecCount1], 0x08
	mov word [ATARegLBA3], ax
	add word [ATARegLBA3], 0x09
	mov word [ATARegLBA4], ax
	add word [ATARegLBA4], 0x0A
	mov word [ATARegLBA5], ax
	add word [ATARegLBA5], 0x0B
	mov word [ATARegControl], bx
	add word [ATARegControl], 0x02
	mov word [ATARegAltStatus], bx
	add word [ATARegAltStatus], 0x02
	mov word [ATARegDevAddress], bx
	add word [ATARegDevAddress], 0x03

ret
ATARegData										dw 0x0000
ATARegError										dw 0x0000
ATARegFeatures									dw 0x0000
ATARegSecCount0									dw 0x0000
ATARegLBA0										dw 0x0000
ATARegLBA1										dw 0x0000
ATARegLBA2										dw 0x0000
ATARegHDDevSel									dw 0x0000
ATARegCommand									dw 0x0000
ATARegStatus									dw 0x0000
ATARegSecCount1									dw 0x0000
ATARegLBA3										dw 0x0000
ATARegLBA4										dw 0x0000
ATARegLBA5										dw 0x0000
ATARegControl									dw 0x0000
ATARegAltStatus									dw 0x0000
ATARegDevAddress								dw 0x0000







































DiskATACHSRead:
	; Reads sectors from disk using the CHS method
	;  input:
	;   CHS address of starting sector
	;		Cylinder is first two bytes of register, beginning with MSB (up to 65535)
	;		Head is next byte (0 - 15)
	;		Sector is LSB (0 is reserved; value is usually 1 - 63 for 31.5 GB disks, can be up to 255 for 127.5 GB disks)
	;	number of sectors to read
	;	Memory buffer address to which data will be written
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, ecx, edx, edi

	pop edx
	pop ebx
	pop ecx
	pop edi
	push edx

	mov edx, 0x01F6								; port to send drive & head numbers
	mov al, bh									; head index in BH
	and al, 00001111b							; head is only 4 bits long
	or al, 10100000b							; default 1010b in high nibble
	out dx, al
 
	mov edx, 0x01F2								; Sector count port
	mov al, ch									; Read CH sectors
	out dx, al
 
	mov edx, 0x01F3								; Sector number port
	mov al, bl									; BL is sector index
	out dx, al
 
	mov edx, 0x01F4								; Cylinder low port
	mov eax, ebx								; byte 2 in ebx, just above BH
	mov cl, 16
	shr eax, cl									; shift down to AL
	out dx, al
 
	mov edx, 0x01F5								; Cylinder high port
	mov eax, ebx								; byte 3 in ebx, just above byte 2
	mov cl, 24
	shr eax, cl									; shift down to AL
	out dx, al
 
	mov edx, 0x01F7								; Command port
	mov al, 0x20								; Read with retry
	out dx, al
 
	.still_going:
		in al, dx
		test al, 8								; the sector buffer requires servicing.
	jz .still_going								; until the sector buffer is ready.

	mov eax, 256								; to read 256 words = 1 sector
	xor bx, bx
	mov bl, ch									; read CH sectors
	mul bx
	mov ecx, eax								; ECX is counter for INSW
	mov edx, 0x01F0								; Data port, in and out
	rep insw									; in to [EDI]
ret



DiskATALBARead:
	; Reads sectors from disk using the LBA method
	;  input:
	;   LBA address of starting sector
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



DiskATALBAWrite:
	; Writes sectors to disk using the LBA method
	;  input:
	;   LBA address of starting sector
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
