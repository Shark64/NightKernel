; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; inthandl.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



IntUnsupported:
	pusha
	jmp $ ; for debugging, makes sure the system hangs upon exception
	push kUnsupportedInt$
	call PrintSimple32
	call PICIntComplete
	popa
iretd



ISR00:
	; Divide by Zero Exception
	pusha
	mov edx, 0x00000000
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR01:
	; Debug Exception
	pusha
	mov edx, 0x00000001
	pop esi
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR02:
	; Nonmaskable Interrupt Exception
	pusha
	mov edx, 0x00000002
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR03:
	; Breakpoint Exception
	; get the location of the bad instruction off the stack
	pop dword [exceptionAddress]
	pop dword [exceptionSelector]
	dec dword [exceptionAddress]
	pusha
	push dword [exceptionAddress]
	push dword [exceptionSelector]
	push kPrintText$
	push .format$
	call StringBuild

	; print the string we just built
	mov byte [textColor], 14
	mov byte [backColor], 7
	push kPrintText$
	call Print32

	push 1
	push dword [exceptionAddress]
	call PrintRAM32

	; print the error message
	call PICIntComplete

	; restore the registers and dump thm to screen
	popa
	call PrintRegs32

	; restore the return address
	inc dword [exceptionAddress]
	push dword [exceptionSelector]
	push dword [exceptionAddress]	
iretd
.format$										db ' Breakpoint at ^p4^h:^p8^h ', 0x00



ISR04:
	; Overflow Exception
	pusha
	mov edx, 0x00000004
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR05:
	; Bound Range Exceeded Exception
	pusha
	mov edx, 0x00000005
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR06:											; Invalid Opcode Exception
	; get the location of the bad instruction off the stack
	pop dword [exceptionAddress]
	pop dword [exceptionSelector]
	pusha
	push dword [exceptionAddress]
	push dword [exceptionSelector]
	push kPrintText$
	push .format$
	call StringBuild

	; print the string we just built
	mov byte [textColor], 4
	mov byte [backColor], 7
	push kPrintText$
	call Print32

	push 1
	push dword [exceptionAddress]
	call PrintRAM32

	; print the error message
	call PICIntComplete

	; dump the registers
	popa
	call PrintRegs32

	jmp $ ; for debugging, makes sure the system hangs upon exception
iretd
.format$										db ' Invalid Opcode at ^p4^h:^p8^h ', 0x00



ISR07:
	; Device Not Available Exception
	pusha
	mov edx, 0x00000007
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR08:
	; Double Fault Exception
	pusha
	mov edx, 0x00000008
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR09:
	; Former Coprocessor Segment Overrun Exception
	pusha
	mov edx, 0x00000009
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR0A:
	; Invalid TSS Exception
	pusha
	mov edx, 0x0000000A
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR0B:
	; Segment Not Present Exception
	pusha
	mov edx, 0x0000000B
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR0C:
	; Stack Segment Fault Exception
	pusha
	mov edx, 0x0000000C
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR0D:
	; General Protection Fault
	; get the location of the bad instruction off the stack
	pop dword [exceptionAddress]
	pusha
	push dword [exceptionAddress]
	push kPrintText$
	push .format$
	call StringBuild

	; print the string we just built
	mov byte [textColor], 4
	mov byte [backColor], 7
	push kPrintText$
	call Print32

	push 1
	push dword [exceptionAddress]
	call PrintRAM32

	; print the error message
	call PICIntComplete

	; dump the registers
	popa
	call PrintRegs32

	jmp $ ; for debugging, makes sure the system hangs upon exception
iretd
.format$										db ' General protection fault at ^p8^h ', 0x00



ISR0E:
	; Page Fault Exception
	pusha
	mov edx, 0x0000000E
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR0F:
	; Reserved
	pusha
	mov edx, 0x0000000F
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR10:
	; x86 Floating Point Exception
	pusha
	mov edx, 0x00000010
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR11:
	; Alignment Check Exception
	pusha
	mov edx, 0x00000011
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR12:
	; Machine Check Exception
	pusha
	mov edx, 0x00000012
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR13:
	; SIMD Floating Point Exception
	pusha
	mov edx, 0x00000013
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR14:
	; Virtualization Exception
	pusha
	mov edx, 0x00000014
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR15:
	; Reserved
	pusha
	mov edx, 0x00000015
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR16:
	; Reserved
	pusha
	mov edx, 0x00000016
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR17:
	; Reserved
	pusha
	mov edx, 0x00000017
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR18:
	; Reserved
	pusha
	mov edx, 0x00000018
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR19:
	; Reserved
	pusha
	mov edx, 0x00000019
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR1A:
	; Reserved
	pusha
	mov edx, 0x0000001A
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR1B:
	; Reserved
	pusha
	mov edx, 0x0000001B
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR1C:
	; Reserved
	pusha
	mov edx, 0x0000001C
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR1D:
	; Reserved
	pusha
	mov edx, 0x0000001D
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR1E:
	; Security Exception
	pusha
	mov edx, 0x0000001E
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR1F:
	; Reserved
	pusha
	mov edx, 0x0000001F
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR20:
	; Programmable Interrupt Timer (PIT)
	pusha
	inc dword [tSystem.ticksSinceBoot]
	inc byte [tSystem.ticks]
	cmp byte [tSystem.ticks], 0
	jne .done
	inc dword [tSystem.secondsSinceBoot]
	inc byte [tSystem.seconds]
	cmp byte [tSystem.seconds], 60
	jne .done
	mov byte [tSystem.seconds], 0
	inc byte [tSystem.minutes]
	cmp byte [tSystem.minutes], 60
	jne .done
	mov byte [tSystem.minutes], 0
	inc byte [tSystem.hours]
	cmp byte [tSystem.hours], 24
	jne .done
	mov byte [tSystem.hours], 0
	inc byte [tSystem.day]
	cmp byte [tSystem.day], 30				; this will need modified to account for the different number of days in the months
	jne .done
	mov byte [tSystem.day], 0
	inc byte [tSystem.month]
	cmp byte [tSystem.month], 13
	jne .done
	mov byte [tSystem.month], 1
	inc byte [tSystem.year]
	cmp byte [tSystem.year], 100
	jne .done
	mov byte [tSystem.year], 0
	inc byte [tSystem.century]
	.done:
	call PICIntComplete
	popa
iretd



ISR21:
	; Keyboard
	pusha
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
	popa
iretd
.incrementCounter:
 mov [kKeyBufferWrite], dl
jmp .done



ISR22:
	; Cascade - used internally by the PICs, should never fire
	pusha
	mov edx, 0x00000022
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR23:
	; Serial port 2
	pusha
	mov edx, 0x00000023
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR24:
	; Serial port 1
	pusha
	;push 1
	;call SerialGetIIR
	;pop edx
	;pop ecx
	call PICIntComplete
	popa
iretd



ISR25:
	; Parallel port 2
	pusha
	mov edx, 0x00000025
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR26:
	; Floppy disk
	pusha
	mov edx, 0x00000026
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR27:
	; Parallel port 1 - prone to misfire
	pusha
	mov edx, 0x00000027
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR28:
	; CMOS real time clock
	pusha
	mov edx, 0x00000028
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR29:
	; Free for peripherals / legacy SCSI / NIC
	pusha
	mov edx, 0x00000029
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR2A:
	; Free for peripherals / SCSI / NIC
	pusha
	mov edx, 0x0000002A
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR2B:
	; Free for peripherals / SCSI / NIC
	pusha
	mov edx, 0x0000002B
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR2C:
	; PS/2 Mouse
	pusha

	mov eax, 0x00000000
	in al, 0x60

	; add this byte to the mouse packet
	mov ebx, tSystem.mousePacketByte1
	mov ecx, 0x00000000
	mov cl, [tSystem.mousePacketByteCount]
	mov dl, [tSystem.mousePacketByteSize]
	add ebx, ecx
	mov byte [ebx], al

	; see if we have a full set of bytes, skip to the end if not
	inc cl
	cmp cl, dl
	jne .done

	; if we get here, we have a whole packet
	mov byte [tSystem.mousePacketByteCount], 0xFF

	mov edx, 0x00000000
	mov byte dl, [tSystem.mousePacketByte1]

	; save edx, mask off the three main mouse buttons, restore edx
	push edx
	and dl, 00000111b
	mov byte [tSystem.mouseButtons], dl
	pop edx

	; process the X axis
	mov eax, 0x00000000
	mov ebx, 0x00000000
	mov byte al, [tSystem.mousePacketByte2]
	mov word bx, [tSystem.mouseX]
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
	mov ax, [tSystem.VESAWidth]
	cmp ebx, eax
	jae .mouseXPositiveAdjust
	.mouseXDone:
	mov word [tSystem.mouseX], bx

	; process the Y axis
	mov eax, 0x00000000
	mov ebx, 0x00000000
	mov byte al, [tSystem.mousePacketByte3]
	mov word bx, [tSystem.mouseY]
	and dl, 00100000b
	cmp dl, 00100000b
	jne .mouseYPositive
	; movement was negative (but we add to counteract the mouse's cartesian coordinate system)
	neg al
	add ebx, eax
	; see if the mouse position would be beyond the bottom of the screen, correct if necessary
	mov ax, [tSystem.VESAHeight]
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
	mov word [tSystem.mouseY], bx

	; see if we're using a FancyMouse(TM) and act accordingly
	mov byte al, [tSystem.mouseID]
	cmp al, 0x03
	jne .done
	; if we get here, we need have a wheel and need to process the Z axis
	mov eax, 0x00000000
	mov byte al, [tSystem.mousePacketByte4]
	mov word bx, [tSystem.mouseZ]
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
	mov word [tSystem.mouseZ], bx

	.done:
	inc byte [tSystem.mousePacketByteCount]
	call PICIntComplete
	popa
iretd

.mouseXNegativeAdjust:
	mov bx, 0x00000000
jmp .mouseXDone

.mouseXPositiveAdjust:
	mov word bx, [tSystem.VESAWidth]
	dec bx
jmp .mouseXDone

.mouseYNegativeAdjust:
	mov bx, 0x00000000
jmp .mouseYDone

.mouseYPositiveAdjust:
	mov word bx, [tSystem.VESAHeight]
	dec bx
jmp .mouseYDone



ISR2D:
	; FPU / Coprocessor / Inter-processor
	pusha
	mov edx, 0x0000002D
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR2E:
	; Primary ATA Hard Disk
	pusha
	mov edx, 0x0000002E
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



ISR2F:
	; Secondary ATA Hard Disk
	pusha
	mov edx, 0x0000002F
	jmp $ ; for debugging, makes sure the system hangs upon exception
	call PICIntComplete
	popa
iretd



kUnsupportedInt$								db 'An unsupported interrupt has been called', 0x00
exceptionSelector								dd 0x00000000
exceptionAddress								dd 0x00000000
