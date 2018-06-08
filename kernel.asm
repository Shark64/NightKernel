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


main:
; init the stack segment
mov ax, 0x0000
mov ss, ax
mov sp, 0x0600

mov ax, 0x0000
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax

; set hardware text mode
mov ah, 0x00
mov al, 0x03
int 0x10

; check the configbits to see if we should use 50 lines
mov eax, [tSystem.configBits]
and eax, 000000000000000000000000000000100b
cmp eax, 000000000000000000000000000000100b
jne .stickWith25

	; if we get here, we should shift to 50-line mode
	; first we update the constants
	mov byte [kMaxLines], 50
	mov word [kBytesPerScreen], 8000

	; now we set 8x8 character mode
	mov ax, 0x1112
	int 0x10

; ...or we can jump here to avoid setting that beautugly 50-line mode
.stickWith25:

; hide the hardware cursor
mov ah, 0x01
mov cx, 0x2707
int 0x10

; set kernel cursor location
mov byte [textColor], 7
mov byte [backColor], 0



; init and probe RAM
mov eax, [tSystem.configBits]
and eax, 000000000000000000000000000000010b
cmp eax, 000000000000000000000000000000010b
jne .NoPrint01

push progressText01$
call Print16

.NoPrint01:
call MemoryInit



; get that good ol' APM info
mov eax, [tSystem.configBits]
and eax, 000000000000000000000000000000010b
cmp eax, 000000000000000000000000000000010b
jne .NoPrint02

push progressText02$
call Print16

.NoPrint02:
call SetSystemAPM



; enable the APM interface
mov eax, [tSystem.configBits]
and eax, 000000000000000000000000000000010b
cmp eax, 000000000000000000000000000000010b
jne .NoPrint03

push progressText03$
call Print16

.NoPrint03:
call APMEnable



; load that GDT
mov eax, [tSystem.configBits]
and eax, 000000000000000000000000000000010b
cmp eax, 000000000000000000000000000000010b
jne .NoPrint04

push progressText04$
call Print16

.NoPrint04:
call LoadGDT



; enter protected mode. YAY!
mov eax, [tSystem.configBits]
and eax, 000000000000000000000000000000010b
cmp eax, 000000000000000000000000000000010b
jne .NoPrint05

push progressText05$
call Print16

.NoPrint05:
mov eax, cr0
or eax, 00000001b
mov cr0, eax

; jump to start the kernel in 32-bit mode
jmp 0x08:KernelStart

bits 32

KernelStart:
; init the registers, including the temporary stack
mov ax, 0x0010
mov ds, ax
mov es, ax
mov ss, ax
mov esp, 0x0009FB00




; enable the A20 line - one of the things we require for operation
mov eax, [tSystem.configBits]
and eax, 000000000000000000000000000000010b
cmp eax, 000000000000000000000000000000010b
jne .NoPrint06

push progressText06$
call Print32

.NoPrint06:
call A20Enable



; now that we have a temporary stack and access to all the memory addresses,
; let's allocate some RAM for the real stack
mov eax, [tSystem.configBits]
and eax, 000000000000000000000000000000010b
cmp eax, 000000000000000000000000000000010b
jne .NoPrint07

push progressText07$
call Print32

.NoPrint07:
push dword [kKernelStack]
call MemAllocate
pop eax
mov ebx, [kKernelStack]
add eax, ebx
mov esp, eax



; set up our interrupt handlers and IDT
mov eax, [tSystem.configBits]
and eax, 000000000000000000000000000000010b
cmp eax, 000000000000000000000000000000010b
jne .NoPrint08

push progressText08$
call Print32

.NoPrint08:
call IDTInit
call InterruptHandlerSetAddresses



; setup and remap both PICs
mov eax, [tSystem.configBits]
and eax, 000000000000000000000000000000010b
cmp eax, 000000000000000000000000000000010b
jne .NoPrint09

push progressText09$
call Print32

.NoPrint09:
call PICInit
call PICDisableIRQs
call PICUnmaskAll
call PITInit



; load system data into the info struct
mov eax, [tSystem.configBits]
and eax, 000000000000000000000000000000010b
cmp eax, 000000000000000000000000000000010b
jne .NoPrint0A

push progressText0A$
call Print32

.NoPrint0A:
call SetSystemRTC							; load the RTC values into the system struct
call SetSystemCPUID							; set some info from the CPU into the system struct
call SetSystemCPUSpeed						; write the CPU speed info to the system struct



; setup that mickey!
mov eax, [tSystem.configBits]
and eax, 000000000000000000000000000000010b
cmp eax, 000000000000000000000000000000010b
jne .NoPrint0B

push progressText0B$
call Print32

.NoPrint0B:
call MouseInit



; setup keyboard
mov eax, [tSystem.configBits]
and eax, 000000000000000000000000000000010b
cmp eax, 000000000000000000000000000000010b
jne .NoPrint0C

push progressText0C$
call Print32

.NoPrint0C:
call KeyboardInit



; let's get some interrupts firing!
mov eax, [tSystem.configBits]
and eax, 000000000000000000000000000000010b
cmp eax, 000000000000000000000000000000010b
jne .NoPrint0D

push progressText0D$
call Print32

.NoPrint0D:
sti



; find out how many PCI devices we have and save that info to the system struct
mov eax, [tSystem.configBits]
and eax, 000000000000000000000000000000010b
cmp eax, 000000000000000000000000000000010b
jne .NoPrint0E

push progressText0E$
call Print32

.NoPrint0E:
call PCIDetect
pop eax
cmp eax, [kTrue]
jne .PCIFail

call PCIInitBus
jmp .PCISkip

.PCIFail:
push PCIFailed$
call Print32
jmp .PCISkip

.PCISkip:


; load drivers for PCI devices
mov eax, [tSystem.configBits]
and eax, 000000000000000000000000000000010b
cmp eax, 000000000000000000000000000000010b
jne .NoPrint0F

push progressText0F$
call Print32

.NoPrint0F:
;call PCILoadDrivers



; clear the screen and start!
mov eax, [tSystem.configBits]
and eax, 000000000000000000000000000000010b
cmp eax, 000000000000000000000000000000010b
jne .NoPrint10

push progressText10$
call Print32

.NoPrint10:
call ClearScreen32



; enter the infinite loop which runs the kernel
InfiniteLoop:
	; do stuff here, i guess... :)

	mov eax, [tSystem.configBits]
	and eax, 000000000000000000000000000000001b
	cmp eax, 000000000000000000000000000000001b
	jne .SkipDebugMenu

	call DebugMenu

	.SkipDebugMenu:
jmp InfiniteLoop



progressText01$									db 'MemoryInit', 0x00
progressText02$									db 'SetSystemAPM', 0x00
progressText03$									db 'APMEnable', 0x00
progressText04$									db 'LoadGDT', 0x00
progressText05$									db 'Entering Protected Mode', 0x00
progressText06$									db 'A20Enable', 0x00
progressText07$									db 'Stack setup', 0x00
progressText08$									db 'IDTInit', 0x00
progressText09$									db 'Remaping PICs', 0x00
progressText0A$									db 'Load system data to the info struct', 0x00
progressText0B$									db 'MouseInit', 0x00
progressText0C$									db 'KeyboardInit', 0x00
progressText0D$									db 'Enabling interrupts', 0x00
progressText0E$									db 'Initializing PCI bus', 0x00
progressText0F$									db 'Loading drivers', 0x00
progressText10$									db 'Setup complete', 0x00
memE820Unsupported$								db 'Could not detect memory, function unsupported', 0x00
PCIFailed$										db 'PCI Controller not detected', 0x00



; includes for system routines
%include "api/misc.asm"							; implements the kernel Application Programming Interface
%include "api/lists.asm"						; list manager routines
%include "api/strings.asm"						; string manipulation routines
%include "io/ps2.asm"							; PS/2 keyboard and mouse routines
%include "io/serial.asm"						; serial communication routines
%include "system/debug.asm"						; implements the debugging menu
%include "system/gdt.asm"						; Global Descriptor Table code
%include "system/globals.asm"					; global variable setup
%include "system/hardware.asm"					; routines for other miscellaneous hardware
%include "system/interrupts.asm"				; IDT routines and interrupt handlers
%include "system/memory.asm"					; memory manager
%include "system/pci.asm"						; PCI support
%include "system/pic.asm"						; Programmable Interrupt Controller routines
%include "system/power.asm"						; Power Management (APM & ACPI) routines
%include "video/screen.asm"						; screen printing routine



; includes for drivers
%include "drivers/IDE Controller.asm"			; this should be obvious...
