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

; get that good ol' APM info and enable the interface
call SetSystemInfoAPM
call APMEnable

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

; load the RTC values into the system struct
call SetSystemInfoRTC

; set some info from the CPU into the system struct
call SetSystemInfoCPUID

; write the CPU speed info to the system struct
call SetSystemInfoCPUSpeed

; setup that mickey!
call MouseInit

; setup keyboard
call KeyboardInit

; let's get some interrupts firing!
sti

; draw our lovely logo
call DrawLogo

; set up a short delay
push 300
call TimerWait

; clear the screen
call VESAClearScreen



; enter the infinite loop which runs the kernel
InfiniteLoop:
	; do stuff here, i guess... :)
	call DebugMenu
jmp InfiniteLoop



%include "api.asm"							; implements the kernel Application Programming Interface
%include "debug.asm"						; implements the debugging menu
%include "globals.asm"						; global variable setup
%include "hardware.asm"						; routines for other miscellaneous hardware
%include "idt.asm"							; Interrupt Descriptor Table
%include "inthandl.asm"						; interrupt handlers
%include "memory.asm"						; memory manager
%include "pic.asm"							; Programmable Interrupt Controller routines
%include "power.asm"						; Power Management (APM & ACPI) routines
%include "ps2.asm"							; PS/2 keyboard and mouse routines
%include "screen.asm"						; VESA and other screen routines
%include "serial.asm"						; serial communication routines
%include "logo.asm"							; logo data
