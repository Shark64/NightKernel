
; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; Kernel.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



; here's where all the magic happens :)

; Note: Any call to a kernel (or system library) function may destroy the
; contents of eax, ebx, ecx, edx, edi and esi.



[map all kernel.map]

bits 16
org 0x0600										; set origin point to where the FreeDOS bootloader loads this code
cli												; turn off interrupts and skip the GDT in a jump to our main routine
jmp main

%include "system/gdt.asm"

main:
; init the stack segment
mov ax, 0x0000
mov ss, ax
mov sp, 0x05F0

mov ax, 0x0000
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax

; set text mode
mov ah, 0x00
mov al, 0x03
int 0x10

; hide the cursor
mov ah, 0x01
mov cx, 0x2707
int 0x10

; init and probe RAM
mov byte [textColor], 7
mov byte [backColor], 0
push progressText1$
call Print16
call MemoryInit

; get that good ol' APM info
push progressText2$
call Print16
call SetSystemAPM

; enable the APM interface
push progressText3$
call Print16
call APMEnable

; load that GDT
push progressText4$
call Print16
call LoadGDT

; enter protected mode. YAY!
push progressText5$
call Print16
mov eax, cr0
or eax, 00000001b
mov cr0, eax

; jump to start the kernel in 32-bit mode
jmp 0x08:KernelStart



bits 32



KernelStart:
; init the registers
mov ax, 0x0010
mov ds, ax
mov es, ax
mov ss, ax
mov esp, 0x0009F800

push progressText6$
call Print32
call IDTInit									; init our IDT
%include "system/setints.asm"					; set interrupt handler addresses

push progressText7$
call Print32
call A20Enable									; enable the A20 line - one of the things we require for operation

; setup and remap both PICs
push progressText8$
call Print32
call PICInit
call PICDisableIRQs
call PICUnmaskAll
call PITInit

; load system data into the info struct
push progressText9$
call Print32
call SetSystemRTC							; load the RTC values into the system struct
call SetSystemCPUID							; set some info from the CPU into the system struct
call SetSystemCPUSpeed						; write the CPU speed info to the system struct

; setup that mickey!
push progressTextA$
call Print32
call MouseInit

; setup keyboard
push progressTextB$
call Print32
call KeyboardInit

; let's get some interrupts firing!
push progressTextC$
call Print32
sti

; find out how many PCI devices we have and save that info to the system struct
push progressTextD$
call Print32
call PCIGetDeviceCount
pop dword [tSystem.PCIDeviceCount]

; clear the screen and start!
push progressTextE$
call Print32
call ClearScreen32

; enter the infinite loop which runs the kernel
InfiniteLoop:
	; do stuff here, i guess... :)
	call DebugMenu
jmp InfiniteLoop



progressText1$									db 'MemoryInit', 0x00
progressText2$									db 'SetSystemAPM', 0x00
progressText3$									db 'APMEnable', 0x00
progressText4$									db 'LoadGDT', 0x00
progressText5$									db 'Entering Protected Mode', 0x00
progressText6$									db 'IDTInit', 0x00
progressText7$									db 'A20Enable', 0x00
progressText8$									db 'Remaping PICs', 0x00
progressText9$									db 'Load system data to the info struct', 0x00
progressTextA$									db 'MouseInit', 0x00
progressTextB$									db 'KeyboardInit', 0x00
progressTextC$									db 'Enabling interrupts', 0x00
progressTextD$									db 'Probing PCI interface', 0x00
progressTextE$									db 'Setup complete', 0x00



%include "io/disks.asm"							; disk I/O routines
%include "io/ps2.asm"							; PS/2 keyboard and mouse routines
%include "io/serial.asm"						; serial communication routines
%include "system/api.asm"						; implements the kernel Application Programming Interface
%include "system/debug.asm"						; implements the debugging menu
%include "system/globals.asm"					; global variable setup
%include "system/hardware.asm"					; routines for other miscellaneous hardware
%include "system/idt.asm"						; Interrupt Descriptor Table
%include "system/inthandle.asm"					; interrupt handlers
%include "system/memory.asm"					; memory manager
%include "system/pci.asm"						; PCI support
%include "system/pic.asm"						; Programmable Interrupt Controller routines
%include "system/power.asm"						; Power Management (APM & ACPI) routines
%include "system/strings.asm"					; string manipulation routines
%include "video/screen.asm"						; screen printing routine
