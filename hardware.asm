; Night Kernel
; Copyright 2015 - 2016 by mercury0x000d
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



bits 16



PrintFail:
 ; Prints an ASCIIZ failure message directly to the screen.
 ; Note: Uses text mode (assumed already set) not VESA.
 ; Note: For use in Real Mode only.
 ;  input:
 ;   address of string to print
 ;
 ;  output:
 ;   n/a

 ; set the proper mode
 mov ah, 0x00
 mov al, 0x03
 sti
 int 0x10
 cli

 pop ax
 pop si
 push ax

 ; write the string
 mov bl, 0x04
 mov ax, 0xB800
 mov ds, ax
 mov di, 0x0000
 mov ax, 0x0000
 mov es, ax

 .loopBegin:
 mov al, [es:si]

 ; have we reached the string end? if yes, exit the loop
 cmp al, 0x00
 je .end

 mov byte[ds:di], al
 inc di
 mov byte[ds:di], bl
 inc di
 inc si
 jmp .loopBegin
 .end:

ret



bits 32



KeyGet:
 ; Returns the oldest key in the key buffer, or null if it's empty
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   key pressed in lowest byte of 32-bit value

 mov ecx, 0x00000000
 mov edx, 0x00000000

 ; load the buffer positions
 mov cl, [kKeyBufferRead]
 mov dl, [kKeyBufferWrite]

 ; if the read position is the same as the write position, the buffer is empty and we can exit
 cmp dl, cl
 je .done

 ; calculate the read address into esi
 mov esi, kKeyBuffer
 add esi, ecx

 ; get the byte to return into al
 mov eax, 0x00000000
 mov byte al, [esi]

 ; update the read position
 inc cl
 mov byte [kKeyBufferRead], cl

 .done:
 ; push the data we got onto the stack and exit
 pop ebx
 push eax
 push ebx
ret



MouseInit:
 ; Initializes the PS/2 mouse
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   n/a

 ; disable keyboard temporarily

 call PS2ControllerWaitWrite
 mov al, 0xAD
 out 0x64, al

 ; enable mouse
 call PS2ControllerWaitWrite
 mov al, 0xA8
 out 0x64, al

 ; select PS/2 device 2 to send next data byte to mouse
 call PS2ControllerWaitWrite
 mov al, 0xD4
 out 0x64, al

 ; reset command
 call PS2ControllerWaitWrite
 mov al, 0xFF
 out 0x60, al
 
 call PS2ControllerWaitRead
 in al, 0x60

 ; wait 5 seconds-ish for the mouse to say the reset is done
 mov bl, 5
 mov bh, 0x00
 .loop:
 ; check the mouse status
 pusha
 call PS2ControllerWaitRead
 popa
 in al, 0x60
 cmp al, 0xAA
 je .resetDone
 inc bh
 cmp bl, bh
 jne .loop
 .resetDone:
 ; read mouse ID byte
 call PS2ControllerWaitRead
 in al, 0x60

 ; get controller configuration byte
 call PS2ControllerWaitWrite
 mov al, 0x20
 out 0x64, al
 call PS2ControllerWaitRead
 in al, 0x60

 ; modify the proper bits to enable IRQ and mouse clock
 or al, 00000010b
 and al, 11011111b
 push eax

 ; write controller configuration byte
 call PS2ControllerWaitWrite
 mov al, 0x60
 out 0x64, al
 call PS2ControllerWaitWrite
 pop eax
 out 0x60, al

 ; select PS/2 device 2 to send next data byte to mouse
 call PS2ControllerWaitWrite
 mov al, 0xD4
 out 0x64, al
 ; begin wheel mode init by setting sample rate to 200
 call PS2ControllerWaitWrite
 mov al, 0xF3
 out 0x60, al
 call PS2ControllerWaitRead
 in al, 0x60
 call PS2ControllerWaitWrite
 mov al, 0xD4
 out 0x64, al
 call PS2ControllerWaitWrite
 mov al, 0xC8
 out 0x60, al
 call PS2ControllerWaitRead
 in al, 0x60

 ; select PS/2 device 2 to send next data byte to mouse
 call PS2ControllerWaitWrite
 mov al, 0xD4
 out 0x64, al
 ; begin wheel mode init by setting sample rate to 200
 call PS2ControllerWaitWrite
 mov al, 0xF3
 out 0x60, al
 call PS2ControllerWaitRead
 in al, 0x60
 call PS2ControllerWaitWrite
 mov al, 0xD4
 out 0x64, al
 ; begin wheel mode init by setting sample rate to 200
 call PS2ControllerWaitWrite
 mov al, 0x64
 out 0x60, al
 call PS2ControllerWaitRead
 in al, 0x60

 ; select PS/2 device 2 to send next data byte to mouse
 call PS2ControllerWaitWrite
 mov al, 0xD4
 out 0x64, al
 ; begin wheel mode init by setting sample rate to 200
 call PS2ControllerWaitWrite
 mov al, 0xF3
 out 0x60, al
 call PS2ControllerWaitRead
 in al, 0x60
 call PS2ControllerWaitWrite
 mov al, 0xD4
 out 0x64, al
 ; begin wheel mode init by setting sample rate to 200
 call PS2ControllerWaitWrite
 mov al, 0x50
 out 0x60, al
 call PS2ControllerWaitRead
 in al, 0x60
 
 ; select PS/2 device 2 to send next data byte to mouse
 call PS2ControllerWaitWrite
 mov al, 0xD4
 out 0x64, al
 ; begin wheel mode init by setting sample rate to 200
 call PS2ControllerWaitWrite
 mov al, 0xF2
 out 0x60, al
 call PS2ControllerWaitRead
 in al, 0x60
 call PS2ControllerWaitRead
 in al, 0x60

 mov byte [SystemInfo.mouseID], al

 ; see if this is one of those newfangled wheel mice
 ; if it is, we skip the next section where we reapply default settings
 cmp al, 0x03
 je .skipDefaultSettings

 ; select PS/2 device 2 to send next data byte to mouse
 call PS2ControllerWaitWrite
 mov al, 0xD4
 out 0x64, al
 ; use default settings
 call PS2ControllerWaitWrite
 mov al, 0xF6
 out 0x60, al
 call PS2ControllerWaitRead
 in al, 0x60

 .skipDefaultSettings:
 ; here we set the packet size
 mov byte al, [SystemInfo.mouseID]
 cmp al, 0x03
 je .fancyMouse
 mov byte [SystemInfo.mousePacketByteSize], 0x03
 jmp .donePacketSetting
 .fancyMouse:
 mov byte [SystemInfo.mousePacketByteSize], 0x04
 .donePacketSetting:
 
 ; select PS/2 device 2 to send next data byte to mouse
 call PS2ControllerWaitWrite
 mov al, 0xD4
 out 0x64, al
 ; begin packet transmission
 call PS2ControllerWaitWrite
 mov al, 0xF4
 out 0x60, al
 call PS2ControllerWaitRead
 in al, 0x60

 ; enable keyboard
 call PS2ControllerWaitWrite
 mov al, 0xAE
 out 0x64, al

 mov ax, [SystemInfo.VESAWidth]
 shr ax, 1
 mov word [SystemInfo.mouseX], ax

 mov ax, [SystemInfo.VESAHeight]
 shr ax, 1
 mov word [SystemInfo.mouseY], ax

 mov word [SystemInfo.mouseZ], 0x7777
  
ret



PICDisableIRQs:
 ; Disables all IRQ lines across both PICs
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   n/a

 mov al, 0xFF                     ; disable IRQs
 mov dx, [kPIC1DataPort]          ; set up PIC 1
 out dx, al
 mov dx, [kPIC2DataPort]          ; set up PIC 2
 out dx, al
ret



PICInit:
 ; Init & remap both PICs to use int numbers 0x20 - 0x2f
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   n/a

 mov al, 0x11                     ; set ICW1
 mov dx, [kPIC1CmdPort]           ; set up PIC 1
 out dx, al
 mov dx, [kPIC2CmdPort]           ; set up PIC 2
 out dx, al

 mov al, 0x20                     ; set base interrupt to 0x20 (ICW2)
 mov dx, [kPIC1DataPort]
 out dx, al

 mov al, 0x28                     ; set base interrupt to 0x28 (ICW2)
 mov dx, [kPIC2DataPort]
 out dx, al

 mov al, 0x04                     ; set ICW3 to cascade PICs together
 mov dx, [kPIC1DataPort]
 out dx, al
 mov al, 0x02                     ; set ICW3 to cascade PICs together
 mov dx, [kPIC2DataPort]
 out dx, al

 mov al, 0x05                     ; set PIC 1 to x86 mode with ICW4
 mov dx, [kPIC1DataPort]
 out dx, al

 mov al, 0x01                     ; set PIC 2 to x86 mode with ICW4
 mov dx, [kPIC2DataPort]
 out dx, al

 mov al, 0                        ; zero the data register
 mov dx, [kPIC1DataPort]
 out dx, al
 mov dx, [kPIC2DataPort]
 out dx, al

 mov al, 0xFD
 mov dx, [kPIC1DataPort]
 out dx, al
 mov al, 0xFF
 mov dx, [kPIC2DataPort]
 out dx, al
ret



PICIntComplete:
 ; Tells both PICs the interrupt has been handled
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   n/a

 mov al, 0x20                     ; sets the interrupt complete bit
 mov dx, [kPIC1CmdPort]           ; write bit to PIC 1
 out dx, al

 mov dx, [kPIC2CmdPort]           ; write bit to PIC 2
 out dx, al
ret



PICMaskAll:
 ; Masks all interrupts
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   n/a

 mov dx, [kPIC1DataPort]
 in al, dx
 and al, 0xff
 out dx, al

 mov dx, [kPIC2DataPort]
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

 mov dx, [kPIC1DataPort]
 in al, dx
 and al, 0xff
 out dx, al

 mov dx, [kPIC2DataPort]
 in al, dx
 and al, 0xff
 out dx, al
ret


PICUnmaskAll:
 ; unmasks all interrupts
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   n/a

 mov al, 0x00
 mov dx, [kPIC1DataPort]
 out dx, al

 mov dx, [kPIC2DataPort]
 out dx, al
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



PS2ControllerWaitRead:
 ; Reads data from the PS/2 controller
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   n/a

 mov dword [SystemInfo.lastError], 0x00000000

 ; set timeout value for roughly a couple seconds
 mov ebx, [SystemInfo.delayValue]
 shr ebx, 8
 mov ecx, 0x00000000

 .waitLoop:
 ; wait until the controller is ready
 in al, 0x64
 and al, 00000001b
 cmp al, 0x01
 je .done
 ; if we get here, the controller isn't ready, so see if we've timed out
 inc ecx
 cmp ebx, ecx
 jne .waitLoop
 ; if we get here, we've timed out
 mov dword [SystemInfo.lastError], 0x0000FF00
 .done:
ret



PS2ControllerWaitWrite:
 ; Waits with timeout until the PS/2 controller is ready to accept data, then returns
 ; Note: Uses the system delay value for timeout since interrupts may be disabled upon calling
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   n/a

  mov dword [SystemInfo.lastError], 0x00000000

 ; set timeout value for roughly a couple seconds
 mov ebx, [SystemInfo.delayValue]
 shr ebx, 8
 mov ecx, 0x00000000

 .waitLoop:
 ; wait until the controller is ready
 in al, 0x64
 and al, 00000010b
 cmp al, 0x00
 je .done
 ; if we get here, the controller isn't ready, so see if we've timed out
 inc ecx
 cmp ebx, ecx
 jne .waitLoop
 ; if we get here, we've timed out
 mov ax, 0xFF01
 jmp .done
 .done:
ret



Reboot:
 ; Performs a warm reboot of the PC
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   n/a

 mov dx, 0x92
 in al, dx
 or al, 00000001b
 out dx, al

 ; and now, for the return we'll never reach...
ret



SpeedDetect:
 ; Determines how many iterations of three increments the CPU is capable of in one second
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   number of iterations

 mov ebx, 0x00000000
 mov ecx, 0x00000000
 mov edx, 0x00000000
 mov al, [SystemInfo.tickCounter]
 mov ah, al
 dec ah
 .loop1:
 inc ebx
 inc ecx
 inc edx
 mov al, [SystemInfo.tickCounter]
 cmp al, ah
 jne .loop1
 pop eax
 push ecx
 push eax
ret
