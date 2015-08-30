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
cli
jmp main

;----------------------------------------------------------------------------
;  Include files
;----------------------------------------------------------------------------

%include "gdt.inc"

main:
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
push IntUnsupported
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



%include "setints.inc"



push 0x07                         ; print splash message
push 1
push 1
push kCopyright1
call PrintString

push 0x07
push 2
push 1
push kCopyright2
call PrintString

push 0x07
push 5
push 1
push 0x13abcdef
call PrintHex

call PICInit                      ; setup and remap both PICs, enable ints
call PICDisableIRQs
call PICUnmaskAll

call PITInit

sti

infiniteLoop:
jmp infiniteLoop



%include "inthandl.inc"



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
 ; Masks all interrupts
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

 mov ax, 1193180 / 128

 mov al, 00110110b
 out 0x43, al

 out 0x40, al
 xchg ah,al
 out 0x40, al

ret



PrintHex:
 ; Prints a hex value to the screen. Assumes text mode already set.
 ;  input:
 ;   value to print
 ;   horizontal position
 ;   vertical position
 ;   color attribute
 ;
 ;  output:
 ;   n/a

 pop eax                          ; get return address for end ret
 pop esi                          ; get hex value
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

 mov ecx, 0xF0000000
 and ecx, esi
 shr ecx, 28
 add ecx, kHexDigits
 mov al, [ecx]
 mov byte[edi], al
 inc edi
 mov byte[edi], bl
 inc edi

 mov ecx, 0x0F000000
 and ecx, esi
 shr ecx, 24
 add ecx, kHexDigits
 mov al, [ecx]
 mov byte[edi], al
 inc edi
 mov byte[edi], bl
 inc edi

 mov ecx, 0x00F00000
 and ecx, esi
 shr ecx, 20
 add ecx, kHexDigits
 mov al, [ecx]
 mov byte[edi], al
 inc edi
 mov byte[edi], bl
 inc edi

 mov ecx, 0x000F0000
 and ecx, esi
 shr ecx, 16
 add ecx, kHexDigits
 mov al, [ecx]
 mov byte[edi], al
 inc edi
 mov byte[edi], bl
 inc edi

 mov ecx, 0x0000F000
 and ecx, esi
 shr ecx, 12
 add ecx, kHexDigits
 mov al, [ecx]
 mov byte[edi], al
 inc edi
 mov byte[edi], bl
 inc edi

 mov ecx, 0x00000F00
 and ecx, esi
 shr ecx, 8
 add ecx, kHexDigits
 mov al, [ecx]
 mov byte[edi], al
 inc edi
 mov byte[edi], bl
 inc edi

 mov ecx, 0x000000F0
 and ecx, esi
 shr ecx, 4
 add ecx, kHexDigits
 mov al, [ecx]
 mov byte[edi], al
 inc edi
 mov byte[edi], bl
 inc edi

 mov ecx, 0x0000000F
 and ecx, esi
 add ecx, kHexDigits
 mov al, [ecx]
 mov byte[edi], al
 inc edi
 mov byte[edi], bl
 inc edi

ret



PrintString:
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
 jz .end                          ; if yes, jump to the end

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
kPIC1CmdPort         dw     0x0020
kPIC1DataPort        dw     0x0021
kPIC2CmdPort         dw     0x00a0
kPIC2DataPort        dw     0x00a1
kPITPort             dw     0x0040
kHexDigits           db     '0123456789ABCDEF'
kUnsupportedInt      db     'An unsupported interrupt has been called'
