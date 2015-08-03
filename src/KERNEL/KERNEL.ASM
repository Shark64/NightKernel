; Night DOS Kernel (kernel.asm) version 0.03
; Copyright 1995-2015 by mercury0x000d

; Kernel.asm is a part of the Night DOS Kernel

; The Night DOS Kernel is free software: you can redistribute it and/or
; modify it under the terms of the GNU General Public License as published
; by the Free Software Foundation, either version 3 of the License, or (at
; your option) any later version.

; The Night DOS Kernel is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
; or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
; for more details.

; You should have received a copy of the GNU General Public License along
; with the Night DOS Kernel. If not, see <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the
; GPL License by which this program is covered.



; here's where all the magic happens :)

; Note: Any call to a kernel (or system library) function may destroy the
; contents of eax, ebx, ecx, edx, edi and esi.


[map all kernel.map]

bits 16

org 0x0600                        ; set origin point to where the
                                  ; FreeDOS bootloader loads this code
jmp main

;----------------------------------------------------------------------------
;  Include files
;----------------------------------------------------------------------------

%include "gdt.inc"

main:
cli
mov ax, 0x0000                    ; init the stack segment 
mov ss, ax
mov sp, 0xffff

mov ax, 0x0000
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax

call load_GDT

mov eax, cr0                      ; enter protected mode. YAY!
or eax, 00000001b
mov cr0, eax

jmp 0x08:kernel_start



bits 32


idtStructure:
.limit  dw 2047
.base   dd 0x18000


kernel_start:
mov ax, 0x0010
mov ds, ax
mov es, ax
mov ss, ax
mov esp, 0x00090000



mov eax, 0                        ; loop to init IDT
setupOneVector:
push eax
push 0x8e
push ISR
push 0x08
push eax
call IDTWrite
pop eax
inc eax
cmp eax, 0x00000100
jz endIDTSetupLoop
jmp setupOneVector
endIDTSetupLoop:
lidt [idtStructure]



push 0x8e
push ISR00
push 0x08
push 0x00
call IDTWrite

push 0x8e
push ISR01
push 0x08
push 0x01
call IDTWrite

push 0x8e
push ISR02
push 0x08
push 0x02
call IDTWrite

push 0x8e
push ISR03
push 0x08
push 0x03
call IDTWrite

push 0x8e
push ISR04
push 0x08
push 0x04
call IDTWrite

push 0x8e
push ISR05
push 0x08
push 0x05
call IDTWrite

push 0x8e
push ISR06
push 0x08
push 0x06
call IDTWrite

push 0x8e
push ISR07
push 0x08
push 0x07
call IDTWrite

push 0x8e
push ISR08
push 0x08
push 0x08
call IDTWrite

push 0x8e
push ISR09
push 0x08
push 0x09
call IDTWrite

push 0x8e
push ISR0A
push 0x08
push 0x0A
call IDTWrite

push 0x8e
push ISR0B
push 0x08
push 0x0B
call IDTWrite

push 0x8e
push ISR0C
push 0x08
push 0x0C
call IDTWrite

push 0x8e
push ISR0D
push 0x08
push 0x0D
call IDTWrite

push 0x8e
push ISR0E
push 0x08
push 0x0E
call IDTWrite

push 0x8e
push ISR0F
push 0x08
push 0x0F
call IDTWrite

push 0x8e
push ISR10
push 0x08
push 0x10
call IDTWrite

push 0x8e
push ISR11
push 0x08
push 0x11
call IDTWrite

push 0x8e
push ISR12
push 0x08
push 0x12
call IDTWrite

push 0x8e
push ISR13
push 0x08
push 0x13
call IDTWrite

push 0x8e
push ISR14
push 0x08
push 0x14
call IDTWrite

push 0x8e
push ISR15
push 0x08
push 0x15
call IDTWrite

push 0x8e
push ISR16
push 0x08
push 0x16
call IDTWrite

push 0x8e
push ISR17
push 0x08
push 0x17
call IDTWrite

push 0x8e
push ISR18
push 0x08
push 0x18
call IDTWrite

push 0x8e
push ISR19
push 0x08
push 0x19
call IDTWrite

push 0x8e
push ISR1A
push 0x08
push 0x1A
call IDTWrite

push 0x8e
push ISR1B
push 0x08
push 0x1B
call IDTWrite

push 0x8e
push ISR1C
push 0x08
push 0x1C
call IDTWrite

push 0x8e
push ISR1D
push 0x08
push 0x1D
call IDTWrite

push 0x8e
push ISR1E
push 0x08
push 0x1E
call IDTWrite

push 0x8e
push ISR1F
push 0x08
push 0x1F
call IDTWrite

push 0x8e
push ISR20
push 0x08
push 0x20
call IDTWrite

push 0x8e
push ISR21
push 0x08
push 0x21
call IDTWrite

push 0x8e
push ISR22
push 0x08
push 0x22
call IDTWrite

push 0x8e
push ISR23
push 0x08
push 0x23
call IDTWrite

push 0x8e
push ISR24
push 0x08
push 0x24
call IDTWrite

push 0x8e
push ISR25
push 0x08
push 0x25
call IDTWrite

push 0x8e
push ISR26
push 0x08
push 0x26
call IDTWrite

push 0x8e
push ISR27
push 0x08
push 0x27
call IDTWrite

push 0x8e
push ISR28
push 0x08
push 0x28
call IDTWrite

push 0x8e
push ISR29
push 0x08
push 0x29
call IDTWrite

push 0x8e
push ISR2A
push 0x08
push 0x2A
call IDTWrite

push 0x8e
push ISR2B
push 0x08
push 0x2B
call IDTWrite

push 0x8e
push ISR2C
push 0x08
push 0x2C
call IDTWrite

push 0x8e
push ISR2D
push 0x08
push 0x2D
call IDTWrite

push 0x8e
push ISR2E
push 0x08
push 0x2E
call IDTWrite

push 0x8e
push ISR2F
push 0x08
push 0x2F
call IDTWrite














push 0x07                         ; print splash message
push 1
push 1
push kCopyright1
call Print

push 0x07
push 2
push 1
push kCopyright2
call Print

call PICInit                      ; remap both PICs
call PICUnmaskAll

sti

infiniteLoop:
jmp infiniteLoop



ISR:
;cli
inc dword [0x00000550]
call PICIntComplete
;sti
iret

ISR00:
;cli
inc byte [0x00000500]
call PICIntComplete
;sti
iret

ISR01:
;cli
inc byte [0x00000501]
call PICIntComplete
;sti
iret

ISR02:
;cli
inc byte [0x00000502]
call PICIntComplete
;sti
iret

ISR03:
;cli
inc byte [0x00000503]
call PICIntComplete
;sti
iret

ISR04:
;cli
inc byte [0x00000504]
call PICIntComplete
;sti
iret

ISR05:
;cli
inc byte [0x00000505]
call PICIntComplete
;sti
iret

ISR06:
;cli
inc byte [0x00000506]
call PICIntComplete
;sti
iret

ISR07:
;cli
inc byte [0x00000507]
call PICIntComplete
;sti
iret

ISR08:
;cli
inc byte [0x00000508]
call PICIntComplete
;sti
iret

ISR09:
;cli
inc byte [0x00000509]
call PICIntComplete
;sti
iret

ISR0A:
;cli
inc byte [0x0000050A]
call PICIntComplete
;sti
iret

ISR0B:
;cli
inc byte [0x0000050B]
call PICIntComplete
;sti
iret

ISR0C:
;cli
inc byte [0x0000050C]
call PICIntComplete
;sti
iret

ISR0D:
;cli
inc byte [0x0000050D]
call PICIntComplete
;sti
iret

ISR0E:
;cli
inc byte [0x0000050E]
call PICIntComplete
;sti
iret

ISR0F:
;cli
inc byte [0x0000050F]
call PICIntComplete
;sti
iret

ISR10:
;cli
inc byte [0x00000510]
call PICIntComplete
;sti
iret

ISR11:
;cli
inc byte [0x00000511]
call PICIntComplete
;sti
iret

ISR12:
;cli
inc byte [0x00000512]
call PICIntComplete
;sti
iret

ISR13:
;cli
inc byte [0x00000513]
call PICIntComplete
;sti
iret

ISR14:
;cli
inc byte [0x00000514]
call PICIntComplete
;sti
iret

ISR15:
;cli
inc byte [0x00000515]
call PICIntComplete
;sti
iret

ISR16:
;cli
inc byte [0x00000516]
call PICIntComplete
;sti
iret

ISR17:
;cli
inc byte [0x00000517]
call PICIntComplete
;sti
iret

ISR18:
;cli
inc byte [0x00000518]
call PICIntComplete
;sti
iret

ISR19:
;cli
inc byte [0x00000519]
call PICIntComplete
;sti
iret

ISR1A:
;cli
inc byte [0x0000051A]
call PICIntComplete
;sti
iret

ISR1B:
;cli
inc byte [0x0000051B]
call PICIntComplete
;sti
iret

ISR1C:
;cli
inc byte [0x0000051C]
call PICIntComplete
;sti
iret

ISR1D:
;cli
inc byte [0x0000051D]
call PICIntComplete
;sti
iret

ISR1E:
;cli
inc byte [0x0000051E]
call PICIntComplete
;sti
iret

ISR1F:
;cli
inc byte [0x0000051F]
call PICIntComplete
;sti
iret

ISR20:
;cli
inc byte [0x00000520]
call PICIntComplete
;sti
iret

ISR21:
;cli
inc byte [0x00000521]
call PICIntComplete
;sti
iret

ISR22:
;cli
inc byte [0x00000522]
call PICIntComplete
;sti
iret

ISR23:
;cli
inc byte [0x00000523]
call PICIntComplete
;sti
iret

ISR24:
;cli
inc byte [0x00000524]
call PICIntComplete
;sti
iret

ISR25:
;cli
inc byte [0x00000525]
call PICIntComplete
;sti
iret

ISR26:
;cli
inc byte [0x00000526]
call PICIntComplete
;sti
iret

ISR27:
;cli
inc byte [0x00000527]
call PICIntComplete
;sti
iret

ISR28:
;cli
inc byte [0x00000528]
call PICIntComplete
;sti
iret

ISR29:
;cli
inc byte [0x00000529]
call PICIntComplete
;sti
iret

ISR2A:
;cli
inc byte [0x0000052A]
call PICIntComplete
;sti
iret

ISR2B:
;cli
inc byte [0x0000052B]
call PICIntComplete
;sti
iret

ISR2C:
;cli
inc byte [0x0000052C]
call PICIntComplete
;sti
iret

ISR2D:
;cli
inc byte [0x0000052D]
call PICIntComplete
;sti
iret

ISR2E:
;cli
inc byte [0x0000052E]
call PICIntComplete
;sti
iret

ISR2F:
;cli
inc byte [0x0000052F]
call PICIntComplete
;sti
iret



; There are functions in the basement, Arthur O.O

IDTWrite:
 ; Formats the passed data and writes it to the IDT in the slot specified
 ;  input:
 ;   IDT index 
 ;   ISR selector
 ;   ISR base address
 ;   flags
 ;
 ;  output:
 ;   n/a

 pop esi                          ; save ret address
 pop ebx                          ; get destination IDT index
 mov eax, 8                       ; calc the destination offset into the IDT
 mul ebx
 mov edi, [kIDTPtr]               ; get IDT's base address
 add edi, eax                     ; calc the actual write address

 pop ebx                          ; get ISR selector
 
 pop ecx                          ; get ISR base address
 
 mov eax, 0x0000ffff
 and eax, ecx                     ; get low word of base address in eax
 mov word [edi], ax               ; write low word
 add edi, 2                       ; adjust the destination pointer
 
 mov word [edi], bx               ; write selector
 add edi, 2                       ; adjust the destination pointer again

 mov al, 0x00
 mov byte [edi], al               ; write null (reserved byte)
 inc edi                          ; adjust the destination pointer again
 
 pop edx                          ; get the flags
 mov byte [edi], dl               ; and write those flags!
 inc edi                          ; guess what we're doing here :D
 
 shr ecx, 16                      ; shift base address right 16 bits to
                                  ; get high word in position
 mov eax, 0x0000ffff
 and eax, ecx                     ; get high word of base address in eax
 mov word [edi], ax               ; write high word

 push esi                         ; restore ret address
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
 
 mov al, 0x01                     ; set PIC 1 to x86 mode with ICW4
 mov dx, [kPIC1DataPort]
 out dx, al
 mov dx, [kPIC2DataPort]
 out dx, al
 
 mov al, 0                        ; zero the data register
 mov dx, [kPIC1DataPort]
 out dx, al
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
 ;mov dx, [kPIC2CmdPort]           ; write bit to PIC 2
 ;out dx, al
 
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
 ; Masks all interrupts
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   n/a

 mov dx, [kPIC1DataPort]
 in al, dx
 and al, 0x00
 out dx, al

 mov dx, [kPIC2DataPort]
 in al, dx
 and al, 0x00
 out dx, al

ret



Print:
 ; Prints an ASCIIZ string to the screen. Assumes text mode already set.
 ;  input:
 ;   address of string to print
 ;   horizontal position
 ;   vertical position
 ;   color attribute
 ;
 ;  output:
 ;   n/a

 pop eax                          ; get return address for end ret
 pop esi                          ; get string address
 pop ecx                          ; get horizontal position
 pop edx                          ; get vertical position
 pop ebx                          ; get color attribute
 push eax                         ; push return address back on the stack

 mov edi, [kVideoMem]             ; load edi with video memory address

 dec edx                          ; calculate text position offset
 mov eax, 160
 mul edx
 add edi, eax                     ; alter edi for vertical text position

 dec ecx
 mov eax, 2
 mul ecx
 add edi, eax                     ; alter edi for horizontal text position

 .loopBegin:
 mov al, [esi]
 inc esi

 cmp al, [kNull]                  ; have we reached the string end?
 jz .end                          ; if yes, jump to end of routine

 mov byte[edi], al
 inc edi
 mov byte[edi], bl
 inc edi
 jmp .loopBegin
 .end:
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



; vars 'n' such
kCopyright1          db     'Night DOS Kernel     A 32-bit protected mode replacement for the FreeDOS kernel', 0x00
kCopyright2          db     'version 0.03         2015 by Mercury0x000d, Antony Gordon, Maarten Vermeulen', 0x00
kCRLF                db     0x0d, 0x0a, 0x00
kNull                db     0
kGDTDS               dd     0x00000500
kGDTPtr              dd     0x00008000
kIDTPtr              dd     0x00018000
kVideoMem            dd     0x000b8000
kPIC1CmdPort         db     0x20
kPIC1DataPort        db     0x21
kPIC2CmdPort         db     0xa0
kPIC2DataPort        db     0xa1


