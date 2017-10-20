; Night Kernel
; Copyright 2015 - 2016 by mercury0x000d
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

; Thanks to:
; Tom Ehlert for optimizing our text printing code which resulted in a 30% speedup

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
mov di, tVESAInfoBlock
sti
int 0x10
cli
cmp ax, 0x004F
je GetModes
jmp InfiniteLoop

GetModes:
; step through the VESA modes available and find the best one available
mov ds, [tVESAInfoBlock.VideoModeListSegment]
mov si, [tVESAInfoBlock.VideoModeListOffset]
mov edi, 0x00000000
mov edx, 0x00000000
.readLoop:
mov cx, [si]

;see if the mode = 0xffff so we know if we're all done
cmp cx, 0xFFFF
je .doneLoop

; get info on that mode
mov ax, 0x4F01
mov di, tVESAModeInfo
sti
int 0x10
cli

; skip this mode if it doesn't support a linear frame buffer
cmp dword [tVESAModeInfo.PhysBasePtr], 0x00000000
je .doNextIteration

push edx
mov eax, 0x00000000
mov ebx, 0x00000000
mov word ax, [tVESAModeInfo.YResolution]
mov word bx, [tVESAModeInfo.BytesPerScanline]
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
mov di, tVESAModeInfo
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
mov esi, tSystemInfo.CPUIDVendorString
mov [tSystemInfo.CPUIDLargestBasicQuery], eax
mov [esi], ebx
add esi, 4
mov [esi], edx
add esi, 4
mov [esi], ecx

; set VESA information into the tSystemInfo structure
mov byte dl, [tVESAInfoBlock.VBEVersionMajor]
mov byte [tSystemInfo.VESAVersionMajor], dl

mov byte dl, [tVESAInfoBlock.VBEVersionMinor]
mov byte [tSystemInfo.VESAVersionMinor], dl

mov eax, 0x00000000
mov word ax, [tVESAInfoBlock.OEMStringSegment]
shl eax, 4
mov ebx, 0x00000000
mov bx, [tVESAInfoBlock.OEMStringOffset]
add eax, ebx
mov dword [tSystemInfo.VESAOEMStringPointer], eax

mov dword edx, [tVESAInfoBlock.Capabilities]
mov dword [tSystemInfo.VESACapabilities], edx

mov word dx, [tVESAModeInfo.XResolution]
mov word [tSystemInfo.VESAWidth], dx

mov word dx, [tVESAModeInfo.YResolution]
mov word [tSystemInfo.VESAHeight], dx

mov byte dl, [tVESAModeInfo.BitsPerPixel]
mov byte [tSystemInfo.VESAColorDepth], dl

; while we're messing with color depth, we may as well set up function pointers to the appropriate VESA code
cmp dl, 0x20
jne ColorTest24Bit
mov edx, VESAPrint32
mov dword [VESAPrint], edx
mov edx, VESAPlot32
mov dword [VESAPlot], edx
jmp ColorTestDone
ColorTest24Bit:
cmp dl, 0x18
jne ColorTest16Bit
mov edx, VESAPrint24
mov dword [VESAPrint], edx
mov edx, VESAPlot24
mov dword [VESAPlot], edx
ColorTest16Bit:
; no others implemented for now
ColorTestDone:

mov eax, 0x00000000
mov word ax, [tVESAInfoBlock.TotalMemory]
mov ebx, 0x00010000
mul ebx
mov ebx, 0x00000400
div ebx
mov dword [tSystemInfo.VESAVideoRAMKB], eax

mov word dx, [tVESAInfoBlock.OEMSoftwareRev]
mov word [tSystemInfo.VESAOEMSoftwareRevision], dx

mov eax, 0x00000000
mov word ax, [tVESAInfoBlock.OEMVendorNameSegment]
shl eax, 4
mov ebx, 0x00000000
mov bx, [tVESAInfoBlock.OEMVendorNameOffset]
add eax, ebx
mov [tSystemInfo.VESAOEMVendorNamePointer], eax

mov eax, 0x00000000
mov word ax, [tVESAInfoBlock.OEMProductNameSegment]
shl eax, 4
mov ebx, 0x00000000
mov bx, [tVESAInfoBlock.OEMProductNameOffset]
add eax, ebx
mov [tSystemInfo.VESAOEMProductNamePointer], eax

mov eax, 0x00000000
mov word ax, [tVESAInfoBlock.OEMProductRevSegment]
shl eax, 4
mov ebx, 0x00000000
mov bx, [tVESAInfoBlock.OEMProductRevOffset]
add eax, ebx
mov [tSystemInfo.VESAOEMProductRevisionPointer], eax

mov eax, tVESAInfoBlock.OEMData
mov [tSystemInfo.VESAOEMDataStringsPointer], eax

mov dword edx, [tVESAModeInfo.PhysBasePtr]
mov dword [tSystemInfo.VESALFBAddress], edx

; probe CPUID for processor brand string
mov eax, 0x80000000
cpuid
cmp eax, 0x80000004
jnae CPUIDDoneProbing
mov [tSystemInfo.CPUIDLargestExtendedQuery], eax
mov eax, 0x80000002
cpuid
mov esi, tSystemInfo.CPUIDBrandString
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

; setup and remap both PICs
call PICInit
call PICDisableIRQs
call PICUnmaskAll
call PITInit

; print splash message - if we get here, we're all clear!
push tSystemInfo.kernelCopyright
push 0xFF000000
push 0xFF777777
push 2
push 2
call [VESAPrint]

sti

call SpeedDetect
pop eax
mov [tSystemInfo.delayValue], eax

cli

; setup that mickey!
call MouseInit

; setup keyboard
call KeyboardInit

sti

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



%include "inthandl.asm"						; interrupt handlers
%include "idt.asm"							; Interrupt Descriptor Table
%include "hardware.asm"						; hardware routines
%include "memory.asm"						; memory manager
%include "api.asm"							; memory manager
%include "globals.asm"						; global variable setup
