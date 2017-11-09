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

org 0x0600									; set origin point to where the FreeDOS bootloader loads this code
cli											; turn off interrupts and skip the GDT in a jump to our main routine
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

call MemoryInit								; init and probe RAM

; get that good ol' APM info and enable the interface
call SetSystemInfoAPM
call APMEnable

call VESAInit								; init VESA
call load_GDT								; load that GDT

; enter protected mode. YAY!
mov eax, cr0
or eax, 00000001b
mov cr0, eax

; jump to start the kernel in 32-bit mode
jmp 0x08:kernel_start



bits 32



kernel_start:
; init the registers
mov ax, 0x0010
mov ds, ax
mov es, ax
mov ss, ax
mov esp, 0x0009F800

call IDTInit								; init our IDT
%include "setints.asm"						; set interrupt handler addresses
call SetSystemInfoVESA						; set the remaining important video stuff to the system struct
call A20Enable								; enable the A20 line - one of the things we require for operation

; draw our lovely splash screen, if enabled
mov eax, [kConfigBits]
and eax, 00000000000000000000000000000001b
cmp eax, 00000000000000000000000000000001b
jne .SkipLogo
call LogoSplash
.SkipLogo:

; setup and remap both PICs
call PICInit
call PICDisableIRQs
call PICUnmaskAll
call PITInit

call SetSystemInfoRTC						; load the RTC values into the system struct
call SetSystemInfoCPUID						; set some info from the CPU into the system struct
call SetSystemInfoCPUSpeed					; write the CPU speed info to the system struct
call MouseInit								; setup that mickey!
call KeyboardInit							; setup keyboard
call VESAClearScreen						; clear the screen
sti											; let's get some interrupts firing!


push kPrintString
push 19881980
call ConvertDecimalToString

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
