; Night Kernel
; Copyright 2015 - 2016 by mercury0x000d
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
 jmp $ ; for debugging, makes sure the system hangs upon exception
 pusha
 push kUnsupportedInt
 push 0xff777777
 push 2
 push 2
 call [VESAPrint]
 call PICIntComplete
 popa
iretd



ISR00:
 ; Divide by Zero Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR01:
 ; Debug Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR02:
 ; Nonmaskable Interrupt Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR03:
 ; Breakpoint Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR04:
 ; Overflow Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR05:
 ; Bound Range Exceeded Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR06:
 ; Invalid Opcode Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR07:
 ; Device Not Available Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR08:
 ; Double Fault Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR09:
 ; Former Coprocessor Segment Overrun Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR0A:
 ; Invalid TSS Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR0B:
 ; Segment Not Present Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR0C:
 ; Stack Segment Fault Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR0D:
 ; General Protection Fault
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR0E:
 ; Page Fault Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR0F:
 ; Reserved
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR10:
 ; x86 Floating Point Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR11:
 ; Alignment Check Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR12:
 ; Machine Check Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR13:
 ; SIMD Floating Point Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR14:
 ; Virtualization Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR15:
 ; Reserved
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR16:
 ; Reserved
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR17:
 ; Reserved
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR18:
 ; Reserved
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR19:
 ; Reserved
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR1A:
 ; Reserved
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR1B:
 ; Reserved
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR1C:
 ; Reserved
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR1D:
 ; Reserved
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd

ISR1E:
 ; Security Exception
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR1F:
 ; Reserved
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR20:
 ; Programmable Interrupt Timer (PIT)
 pushad
 inc byte [tSystemInfo.tickCounter]
 cmp byte [tSystemInfo.tickCounter], 0x00
 jne .noIncrement
 inc dword [tSystemInfo.secondsSinceBoot]
 .noIncrement:
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
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR23:
 ; Serial port 2
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR24:
 ; Serial port 1
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR25:
 ; Parallel port 2
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR26:
 ; Floppy disk
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR27:
 ; Parallel port 1 - prone to misfire
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR28:
 ; CMOS real time clock
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR29:
 ; Free for peripherals / legacy SCSI / NIC
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR2A:
 ; Free for peripherals / SCSI / NIC
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR2B:
 ; Free for peripherals / SCSI / NIC
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
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
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR2E:
 ; Primary ATA Hard Disk
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd



ISR2F:
 ; Secondary ATA Hard Disk
 jmp $ ; for debugging, makes sure the system hangs upon exception
 call PICIntComplete
iretd


