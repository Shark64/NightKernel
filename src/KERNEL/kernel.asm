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

%include "gdt.asm"

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



%include "setints.asm"            ; set interrupt handler addresses



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



%include "inthandl.asm"           ; interrupt handlers
%include "idt.asm"                ; Interrupt Descriptor Table 
%include "pic.asm"                ; Programmable Interrupt Controller code
%include "console.asm"            ; text console printing
%include "hardware.asm"           ; hardware routines
%include "globals.asm"            ; global variable setup

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
