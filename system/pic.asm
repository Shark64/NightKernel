; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; pic.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



bits 32



PICDisableIRQs:
	; Disables all IRQ lines across both PICs
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: al, dx

	mov al, 0xFF								; disable IRQs
	mov dx, [PIC1DataPort]						; set up PIC 1
	out dx, al
	mov dx, [PIC2DataPort]						; set up PIC 2
	out dx, al
ret



PICInit:
	; Init & remap both PICs to use int numbers 0x20 - 0x2f
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: al, dx

	mov al, 0x11								; set ICW1
	mov dx, [PIC1CmdPort]						; set up PIC 1
	out dx, al
	mov dx, [PIC2CmdPort]						; set up PIC 2
	out dx, al

	mov al, 0x20								; set base interrupt to 0x20 (ICW2)
	mov dx, [PIC1DataPort]
	out dx, al

	mov al, 0x28								; set base interrupt to 0x28 (ICW2)
	mov dx, [PIC2DataPort]
	out dx, al

	mov al, 0x04								; set ICW3 to cascade PICs together
	mov dx, [PIC1DataPort]
	out dx, al
	mov al, 0x02								; set ICW3 to cascade PICs together
	mov dx, [PIC2DataPort]
	out dx, al

	mov al, 0x05								; set PIC 1 to x86 mode with ICW4
	mov dx, [PIC1DataPort]
	out dx, al

	mov al, 0x01								; set PIC 2 to x86 mode with ICW4
	mov dx, [PIC2DataPort]
	out dx, al

	mov al, 0									; zero the data register
	mov dx, [PIC1DataPort]
	out dx, al
	mov dx, [PIC2DataPort]
	out dx, al

	mov al, 0xFD
	mov dx, [PIC1DataPort]
	out dx, al
	mov al, 0xFF
	mov dx, [PIC2DataPort]
	out dx, al
ret



PICIntComplete:
	; Tells both PICs the interrupt has been handled
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: al, dx

	mov al, 0x20								; sets the interrupt complete bit
	mov dx, [PIC1CmdPort]						; write bit to PIC 1
	out dx, al

	mov dx, [PIC2CmdPort]						; write bit to PIC 2
	out dx, al
ret



PICMaskAll:
	; Masks all interrupts
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: al, dx


	mov dx, [PIC1DataPort]
	in al, dx
	and al, 0xff
	out dx, al

	mov dx, [PIC2DataPort]
	in al, dx
	and al, 0xff
	out dx, al
ret



PICMaskSet:
	; Masks all interrupts
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: al, dx


	mov dx, [PIC1DataPort]
	in al, dx
	and al, 0xff
	out dx, al

	mov dx, [PIC2DataPort]
	in al, dx
	and al, 0xff
	out dx, al
ret



PICUnmaskAll:
	; Unmasks all interrupts
	;  input:
	;   n/a
	;
	;  output:
	;   n/a

	mov al, 0x00
	mov dx, [PIC1DataPort]
	out dx, al

	mov dx, [PIC2DataPort]
	out dx, al
ret



PIC1CmdPort										dw 0x0020
PIC1DataPort									dw 0x0021
PIC2CmdPort										dw 0x00a0
PIC2DataPort									dw 0x00a1
