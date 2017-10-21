; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; Kernel.asm is a part of the Night Kernel

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



; here's where all the magic happens :)

; Note: Any call to a kernel (or system library) function may destroy the
; contents of eax, ebx, ecx, edx, edi and esi.



[map all kernel.map]

bits 16

; set origin point to where the FreeDOS bootloader loads this code
org 0x0600

; turn off interrupts and skip the GDT in a jump to our main routine
cli	
jmp main

%include "gdt.asm"

main:
; init the stack segment
mov ax, 0x0000
mov ss, ax
mov sp, 0x05FF

mov ax, 0x0000
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax

; init and probe RAM
call MemoryInit

; init VESA
call VESAInit

; load that GDT
call load_GDT

; enter protected mode. YAY!
mov eax, cr0
or eax, 00000001b
mov cr0, eax

jmp 0x08:kernel_start



bits 32


idtStructure:
.limit  dw 2047
.base   dd 0x0008F800


kernel_start:
; init the registers
mov ax, 0x0010
mov ds, ax
mov es, ax
mov ss, ax
mov esp, 0x0009F800

; loop to init IDT
mov eax, 0
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

; set interrupt handler addresses
%include "setints.asm"

; now that we're in 32 bit mode, set the remaining important video stuff to the system struct
call SetSystemInfoVESA

; enable the A20 line - one of the things we require for operation
call A20Enable

; setup and remap both PICs
call PICInit
call PICDisableIRQs
call PICUnmaskAll
call PITInit

; set some info from the CPU into the system struct
call SetSystemInfoCPUID

; write the CPU speed info to the system struct
call SetSystemInfoCPUSpeed

; setup that mickey!
call MouseInit

; setup keyboard
call KeyboardInit

; print splash message - if we get here, we're all clear!
push tSystemInfo.kernelCopyright
push 0xFF000000
push 0xFF777777
push 2
push 2
call [VESAPrint]
sti

; debugging code follows

; print number of int 15h entries
; testing number to string code
push kPrintString
push dword [memmap_ent]
call ConvertHexToString
push kPrintString
push 0xFF000000
push 0xFF777777
push 18
push 2
call [VESAPrint]



; testing DebugPrint - print the address in memory of the VESA OEM String and the string itself
push dword [tSystemInfo.VESAOEMVendorNamePointer]
push tSystemInfo.VESAOEMVendorNamePointer
push 64
push 2
call DebugPrint



InfiniteLoop:
call KeyGet
pop eax
cmp al, 0x71 ; ascii code for "q"
je .showMessage
cmp al, 0x77 ; ascii code for "w"
je .hideMessage

; print seconds since boot just for the heck of it
push kPrintString
push dword [tSystemInfo.secondsSinceBoot]
call ConvertHexToString
push kPrintString
push 0xFF000000
push 0xFF777777
push 34
push 2
call [VESAPrint]

; print mouse position for testing
push kPrintString
mov eax, 0x00000000
mov byte al, [tSystemInfo.mouseButtons]
push eax
call ConvertHexToString
push kPrintString
push 0xFF000000
push 0xFF777777
push 50
push 2
call [VESAPrint]

push kPrintString
mov eax, 0x00000000
mov word ax, [tSystemInfo.mouseX]
push eax
call ConvertHexToString
push kPrintString
push 0xFF000000
push 0xFF777777
push 50
push 102
call [VESAPrint]

push kPrintString
mov eax, 0x00000000
mov word ax, [tSystemInfo.mouseY]
push eax
call ConvertHexToString
push kPrintString
push 0xFF000000
push 0xFF777777
push 50
push 202
call [VESAPrint]
 
push kPrintString
mov eax, 0x00000000
mov word ax, [tSystemInfo.mouseZ]
push eax
call ConvertHexToString
push kPrintString
push 0xFF000000
push 0xFF777777
push 50
push 302
call [VESAPrint]
 

jmp InfiniteLoop

.showMessage:
push tSystemInfo.CPUIDBrandString
push 0xFF0000FF
push 0xFF000000
push 80
push 100
call [VESAPrint]
jmp InfiniteLoop

.hideMessage:
push tSystemInfo.CPUIDBrandString
push 0xFF000000
push 0xFF000000
push 80
push 100
call [VESAPrint]
jmp InfiniteLoop



%include "api.asm"							; implements the kernel Application Programming Interface
%include "globals.asm"						; global variable setup
%include "hardware.asm"						; routines for other miscellaneous hardware
%include "idt.asm"							; Interrupt Descriptor Table
%include "inthandl.asm"						; interrupt handlers
%include "memory.asm"						; memory manager
%include "pic.asm"							; Programmable Interrupt Controller routines
%include "ps2.asm"							; PS/2 keyboard and mouse routines
%include "screen.asm"						; VESA and other screen routines
