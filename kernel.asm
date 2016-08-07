; Night Kernel version 0.04
; Copyright 1995 - 2016 by mercury0x000d
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

; get video controller info
mov ax, 0x4F00
mov di, VESAInfoBlock
sti
int 0x10
cli
cmp ax, 0x004F
je GetModes
jmp InfiniteLoop

GetModes:
; step through the VESA modes available and find the best one available
mov ds, [VESAInfoBlock.VideoModeListSegment]
mov si, [VESAInfoBlock.VideoModeListOffset]
mov edi, 0x00000000
mov edx, 0x00000000
.readLoop:
mov cx, [si]

;see if the mode = 0xffff so we know if we're all done
cmp cx, 0xFFFF
je .doneLoop

; get info on that mode
mov ax, 0x4F01
mov di, VESAModeInfo
sti
int 0x10
cli

; skip this mode if it doesn't support a linear frame buffer
cmp dword [VESAModeInfo.PhysBasePtr], 0x00000000
je .doNextIteration

push edx
mov eax, 0x00000000
mov ebx, 0x00000000
mov word ax, [VESAModeInfo.YResolution]
mov word bx, [VESAModeInfo.BytesPerScanline]
mul ebx
pop edx

; loop again if this mode doesn't score higher than our current record holder
cmp eax, edx
jna .doNextIteration
; it did score higher, so let's make note of it
mov gs, cx
mov edx, eax

.doNextIteration:
add si, 2
jmp .readLoop
.doneLoop:
mov ax, 0xbeef

; get info on the final mode
mov ax, 0x4F01
mov cx, gs
mov di, VESAModeInfo
sti
int 0x10
cli

; set that mode
mov ax, 0x4F02
mov bx, cx
sti
int 0x10
cli

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
.base   dd 0x18000


kernel_start:

; init the registers
mov ax, 0x0010
mov ds, ax
mov es, ax
mov ss, ax
mov esp, 0x00090000

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

; Fast A20 enable
in al, 0x92
or al, 0x02
out 0x92, al

; verify it worked
in al, 0x92
and al, 0x02
cmp al, 0
jnz kernelInitFastA20Success
; it failed, so we have to say so
push kFastA20Fail
push 0xff777777
push 2
push 2
call [VESAPrint]
jmp InfiniteLoop
kernelInitFastA20Success:

; probe CPUID for vendor ID
mov eax, 0x00000000
cpuid
mov esi, SystemInfo.CPUIDVendorString
mov [SystemInfo.CPUIDLargestBasicQuery], eax
mov [esi], ebx
add esi, 4
mov [esi], edx
add esi, 4
mov [esi], ecx

; set VESA information into the SystemInfo structure
mov byte dl, [VESAInfoBlock.VBEVersionMajor]
mov byte [SystemInfo.VESAVersionMajor], dl

mov byte dl, [VESAInfoBlock.VBEVersionMinor]
mov byte [SystemInfo.VESAVersionMinor], dl

mov eax, 0x00000000
mov word ax, [VESAInfoBlock.OEMStringSegment]
shl eax, 4
mov ebx, 0x00000000
mov bx, [VESAInfoBlock.OEMStringOffset]
add eax, ebx
mov dword [SystemInfo.VESAOEMStringPointer], eax

mov dword edx, [VESAInfoBlock.Capabilities]
mov dword [SystemInfo.VESACapabilities], edx

mov word dx, [VESAModeInfo.XResolution]
mov word [SystemInfo.VESAWidth], dx

mov word dx, [VESAModeInfo.YResolution]
mov word [SystemInfo.VESAHeight], dx

mov byte dl, [VESAModeInfo.BitsPerPixel]
mov byte [SystemInfo.VESAColorDepth], dl

; while we're messing with color depth, we may as well set up function pointers to the appropriate VESA code
cmp dl, 0x20
jne ColorTest24Bit
mov edx, VESAPrint32
mov dword [VESAPrint], edx
mov edx, VESAPlot32
mov dword [VESAPlot], edx
ColorTest24Bit:
cmp dl, 0x18
jne ColorTest16Bit
mov edx, VESAPrint24
mov dword [VESAPrint], edx
mov edx, VESAPlot24
mov dword [VESAPlot], edx
ColorTest16Bit:
; no others implemented for now

mov eax, 0x00000000
mov word ax, [VESAInfoBlock.TotalMemory]
mov ebx, 0x00010000
mul ebx
mov ebx, 0x00000400
div ebx
mov dword [SystemInfo.VESAVideoRAMKB], eax

mov word dx, [VESAInfoBlock.OEMSoftwareRev]
mov word [SystemInfo.VESAOEMSoftwareRevision], dx

mov eax, 0x00000000
mov word ax, [VESAInfoBlock.OEMVendorNameSegment]
shl eax, 4
mov ebx, 0x00000000
mov bx, [VESAInfoBlock.OEMVendorNameOffset]
add eax, ebx
mov [SystemInfo.VESAOEMVendorNamePointer], eax

mov eax, 0x00000000
mov word ax, [VESAInfoBlock.OEMProductNameSegment]
shl eax, 4
mov ebx, 0x00000000
mov bx, [VESAInfoBlock.OEMProductNameOffset]
add eax, ebx
mov [SystemInfo.VESAOEMProductNamePointer], eax

mov eax, 0x00000000
mov word ax, [VESAInfoBlock.OEMProductRevSegment]
shl eax, 4
mov ebx, 0x00000000
mov bx, [VESAInfoBlock.OEMProductRevOffset]
add eax, ebx
mov [SystemInfo.VESAOEMProductRevisionPointer], eax

mov eax, VESAInfoBlock.OEMData
mov [SystemInfo.VESAOEMDataStringsPointer], eax

mov dword edx, [VESAModeInfo.PhysBasePtr]
mov dword [SystemInfo.VESALFBAddress], edx

; probe CPUID for processor brand string
mov eax, 0x80000000
cpuid
cmp eax, 0x80000004
jnae CPUIDDoneProbing
mov [SystemInfo.CPUIDLargestExtendedQuery], eax
mov eax, 0x80000002
cpuid
mov esi, SystemInfo.CPUIDBrandString
mov [esi], eax
add esi, 4
mov [esi], ebx
add esi, 4
mov [esi], ecx
add esi, 4
mov [esi], edx
add esi, 4
mov eax, 0x80000003
cpuid
mov [esi], eax
add esi, 4
mov [esi], ebx
add esi, 4
mov [esi], ecx
add esi, 4
mov [esi], edx
add esi, 4
mov eax, 0x80000004
cpuid
mov [esi], eax
add esi, 4
mov [esi], ebx
add esi, 4
mov [esi], ecx
add esi, 4
mov [esi], edx
CPUIDDoneProbing:

; setup and remap both PICs, enable ints
call PICInit
call PICDisableIRQs
call PICUnmaskAll
call PITInit

; print splash message - if we get here, we're all clear!
push SystemInfo.kernelCopyright
push 0xFF777777
push 2
push 2
call [VESAPrint]

; testing number to string code
push kPrintString
push memmap_ent
call ConvertHexToString

; print number of int 15h entries
push kPrintString
push 0xFF777777
push 18
push 2
call [VESAPrint]

; pixel color test
push 0xAAFF0000
push 22
push 100
call [VESAPlot]

push 0xAA00FF00
push 22
push 101
call [VESAPlot]

push 0xAA0000FF
push 22
push 102
call [VESAPlot]

sti

InfiniteLoop:
call KeyGet
pop eax
cmp al, 0x71 ; ascii code for "q"
je .showMessage
cmp al, 0x77 ; ascii code for "w"
je .hideMessage
jmp InfiniteLoop

.showMessage:
push SystemInfo.CPUIDBrandString
push 0xFF777777
push 34
push 100
call [VESAPrint]
jmp InfiniteLoop

.hideMessage:
push SystemInfo.CPUIDBrandString
push 0xFF000000
push 34
push 100
call [VESAPrint]
jmp InfiniteLoop



%include "inthandl.asm"						; interrupt handlers
%include "idt.asm"							; Interrupt Descriptor Table
%include "hardware.asm"						; hardware routines
%include "memory.asm"						; memory manager
%include "api.asm"							; memory manager
%include "globals.asm"						; global variable setup
