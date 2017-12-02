; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; inthandl.asm is a part of the Night Kernel

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



IntUnsupported:
	pushad
	jmp $ ; for debugging, makes sure the system hangs upon exception
	push kUnsupportedInt
	call PrintSimple32
	call PICIntComplete
	popad
iretd



ISR00:
	; Divide by Zero Exception
	pushad
	mov edx, 0x00000000
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR01:
	; Debug Exception
	pushad
	mov edx, 0x00000001
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR02:
	; Nonmaskable Interrupt Exception
	pushad
	mov edx, 0x00000002
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR03:
	; Breakpoint Exception
	pushad
	mov edx, 0x00000003
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR04:
	; Overflow Exception
	pushad
	mov edx, 0x00000004
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR05:
	; Bound Range Exceeded Exception
	pushad
	mov edx, 0x00000005
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR06:
	; Invalid Opcode Exception
	mov edx, 0x00000006
	jmp $ ; for debugging, makes sure the system hangs upon exception
	pushad
	call PICIntComplete
	popad
iretd



ISR07:
	; Device Not Available Exception
	pushad
	mov edx, 0x00000007
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR08:
	; Double Fault Exception
	pushad
	mov edx, 0x00000008
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR09:
	; Former Coprocessor Segment Overrun Exception
	pushad
	mov edx, 0x00000009
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR0A:
	; Invalid TSS Exception
	pushad
	mov edx, 0x0000000A
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR0B:
	; Segment Not Present Exception
	pushad
	mov edx, 0x0000000B
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR0C:
	; Stack Segment Fault Exception
	pushad
	mov edx, 0x0000000C
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR0D:
	; General Protection Fault
	pushad
	mov edx, 0x0000000D
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR0E:
	; Page Fault Exception
	pushad
	mov edx, 0x0000000E
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR0F:
	; Reserved
	pushad
	mov edx, 0x0000000F
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR10:
	; x86 Floating Point Exception
	pushad
	mov edx, 0x00000010
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR11:
	; Alignment Check Exception
	pushad
	mov edx, 0x00000011
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR12:
	; Machine Check Exception
	pushad
	mov edx, 0x00000012
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR13:
	; SIMD Floating Point Exception
	pushad
	mov edx, 0x00000013
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR14:
	; Virtualization Exception
	pushad
	mov edx, 0x00000014
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR15:
	; Reserved
	pushad
	mov edx, 0x00000015
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR16:
	; Reserved
	pushad
	mov edx, 0x00000016
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR17:
	; Reserved
	pushad
	mov edx, 0x00000017
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR18:
	; Reserved
	pushad
	mov edx, 0x00000018
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR19:
	; Reserved
	pushad
	mov edx, 0x00000019
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR1A:
	; Reserved
	pushad
	mov edx, 0x0000001A
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR1B:
	; Reserved
	pushad
	mov edx, 0x0000001B
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR1C:
	; Reserved
	pushad
	mov edx, 0x0000001C
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR1D:
	; Reserved
	pushad
	mov edx, 0x0000001D
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR1E:
	; Security Exception
	pushad
	mov edx, 0x0000001E
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR1F:
	; Reserved
	pushad
	mov edx, 0x0000001F
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR20:
	; Programmable Interrupt Timer (PIT)
	pushad
	inc dword [tSystemInfo.ticksSinceBoot]
	inc byte [tSystemInfo.ticks]
	cmp byte [tSystemInfo.ticks], 0
	jne .done
	inc dword [tSystemInfo.secondsSinceBoot]
	inc byte [tSystemInfo.seconds]
	cmp byte [tSystemInfo.seconds], 60
	jne .done
	mov byte [tSystemInfo.seconds], 0
	inc byte [tSystemInfo.minutes]
	cmp byte [tSystemInfo.minutes], 60
	jne .done
	mov byte [tSystemInfo.minutes], 0
	inc byte [tSystemInfo.hours]
	cmp byte [tSystemInfo.hours], 24
	jne .done
	mov byte [tSystemInfo.hours], 0
	inc byte [tSystemInfo.day]
	cmp byte [tSystemInfo.day], 30				; this will need modified to account for the different number of days in the months
	jne .done
	mov byte [tSystemInfo.day], 0
	inc byte [tSystemInfo.month]
	cmp byte [tSystemInfo.month], 13
	jne .done
	mov byte [tSystemInfo.month], 1
	inc byte [tSystemInfo.year]
	cmp byte [tSystemInfo.year], 100
	jne .done
	mov byte [tSystemInfo.year], 0
	inc byte [tSystemInfo.century]
	.done:
	call PICIntComplete
	popad
iretd



ISR21:
	; Keyboard
	pushad
	mov eax, 0x00000000
	in al, 0x60

	; skip if this isn't a key down event
	cmp al, 0x80
	ja .done

	; load the buffer position
	mov esi, kKeyBuffer
	mov edx, 0x00000000
	mov dl, [kKeyBufferWrite]
	add esi, edx

	; get the letter or symbol associated with this key code
	mov ebx, kKeyTable
	add ebx, eax
	mov cl, [ebx]

	; add the letter or symbol to the key buffer
	mov byte [esi], cl

	; if the buffer isn't full, adjust the buffer pointer
	mov dh, [kKeyBufferRead]
	inc dl
	cmp dl, dh
	jne .incrementCounter

	.done:
	call PICIntComplete
	popad
iretd
.incrementCounter:
 mov [kKeyBufferWrite], dl
jmp .done



ISR22:
	; Cascade - used internally by the PICs, should never fire
	pushad
	mov edx, 0x00000022
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR23:
	; Serial port 2
	pushad
	mov edx, 0x00000023
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR24:
	; Serial port 1
	pushad
	;push 1
	;call SerialGetIIR
	;pop edx
	;pop ecx
	call PICIntComplete
	popad
iretd



ISR25:
	; Parallel port 2
	pushad
	mov edx, 0x00000025
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR26:
	; Floppy disk
	pushad
	mov edx, 0x00000026
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR27:
	; Parallel port 1 - prone to misfire
	pushad
	mov edx, 0x00000027
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR28:
	; CMOS real time clock
	pushad
	mov edx, 0x00000028
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR29:
	; Free for peripherals / legacy SCSI / NIC
	pushad
	mov edx, 0x00000029
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR2A:
	; Free for peripherals / SCSI / NIC
	pushad
	mov edx, 0x0000002A
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR2B:
	; Free for peripherals / SCSI / NIC
	pushad
	mov edx, 0x0000002B
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR2C:
	; PS/2 Mouse
	pushad

	mov eax, 0x00000000
	in al, 0x60

	; add this byte to the mouse packet
	mov ebx, tSystemInfo.mousePacketByte1
	mov ecx, 0x00000000
	mov cl, [tSystemInfo.mousePacketByteCount]
	mov dl, [tSystemInfo.mousePacketByteSize]
	add ebx, ecx
	mov byte [ebx], al

	; see if we have a full set of bytes, skip to the end if not
	inc cl
	cmp cl, dl
	jne .done

	; if we get here, we have a whole packet
	mov byte [tSystemInfo.mousePacketByteCount], 0xFF

	mov edx, 0x00000000
	mov byte dl, [tSystemInfo.mousePacketByte1]

	; save edx, mask off the three main mouse buttons, restore edx
	push edx
	and dl, 00000111b
	mov byte [tSystemInfo.mouseButtons], dl
	pop edx

	; process the X axis
	mov eax, 0x00000000
	mov ebx, 0x00000000
	mov byte al, [tSystemInfo.mousePacketByte2]
	mov word bx, [tSystemInfo.mouseX]
	push edx
	and dl, 00010000b
	cmp dl, 00010000b
	pop edx
	jne .mouseXPositive
	; movement was negative
	neg al
	sub ebx, eax
	; see if the mouse position would be beyond the left side of the screen, correct if necessary
	cmp ebx, 0x0000FFFF
	ja .mouseXNegativeAdjust
	jmp .mouseXDone
	.mouseXPositive:
	; movement was positive
	add ebx, eax
	; see if the mouse position would be beyond the right side of the screen, correct if necessary
	mov ax, [tSystemInfo.VESAWidth]
	cmp ebx, eax
	jae .mouseXPositiveAdjust
	.mouseXDone:
	mov word [tSystemInfo.mouseX], bx

	; process the Y axis
	mov eax, 0x00000000
	mov ebx, 0x00000000
	mov byte al, [tSystemInfo.mousePacketByte3]
	mov word bx, [tSystemInfo.mouseY]
	and dl, 00100000b
	cmp dl, 00100000b
	jne .mouseYPositive
	; movement was negative (but we add to counteract the mouse's cartesian coordinate system)
	neg al
	add ebx, eax
	; see if the mouse position would be beyond the bottom of the screen, correct if necessary
	mov ax, [tSystemInfo.VESAHeight]
	cmp ebx, eax
	jae .mouseYPositiveAdjust
	jmp .mouseYDone
	.mouseYPositive:
	; movement was positive (but we subtract to counteract the mouse's cartesian coordinate system)
	sub ebx, eax
	; see if the mouse position would be beyond the top of the screen, correct if necessary
	cmp ebx, 0x0000FFFF
	ja .mouseYNegativeAdjust
	.mouseYDone:
	mov word [tSystemInfo.mouseY], bx

	; see if we're using a FancyMouse(TM) and act accordingly
	mov byte al, [tSystemInfo.mouseID]
	cmp al, 0x03
	jne .done
	; if we get here, we need have a wheel and need to process the Z axis
	mov eax, 0x00000000
	mov byte al, [tSystemInfo.mousePacketByte4]
	mov word bx, [tSystemInfo.mouseZ]
	mov cl, 0xF0
	and cl, al
	cmp cl, 0xF0
	jne .mouseZPositive
	; movement was negative
	neg al
	and al, 0x0F
	sub bx, ax
	jmp .mouseZDone
	.mouseZPositive:
	; movement was positive
	add bx, ax
	.mouseZDone:
	mov word [tSystemInfo.mouseZ], bx

	.done:
	inc byte [tSystemInfo.mousePacketByteCount]
	call PICIntComplete
	popad
iretd

.mouseXNegativeAdjust:
	mov bx, 0x00000000
jmp .mouseXDone

.mouseXPositiveAdjust:
	mov word bx, [tSystemInfo.VESAWidth]
	dec bx
jmp .mouseXDone

.mouseYNegativeAdjust:
	mov bx, 0x00000000
jmp .mouseYDone

.mouseYPositiveAdjust:
	mov word bx, [tSystemInfo.VESAHeight]
	dec bx
jmp .mouseYDone



ISR2D:
	; FPU / Coprocessor / Inter-processor
	pushad
	mov edx, 0x0000002D
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR2E:
	; Primary ATA Hard Disk
	pushad
	mov edx, 0x0000002E
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd



ISR2F:
	; Secondary ATA Hard Disk
	pushad
	mov edx, 0x0000002F
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popad
iretd
