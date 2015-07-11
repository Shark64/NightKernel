; Night DOS Kernel (kernel.asm) version 0.01
; Copyright 1995-2015 by mercury0x000d

; Kernel.asm is a part of the Night DOS Kernel

; The Night DOS Kernel is free software: you can redistribute it and/or modify it under the terms of the
; GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.

; The Night DOS Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
; the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
; for more details.

; You should have received a copy of the GNU General Public License along with the Night DOS Kernel.
; If not, see <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



; here's where all the magic happens :)

org 0x0600                             ; set origin point to where the
                                       ; FreeDOS bootloader loads this code

; Note: Any call to a kernel (or system library) function may destroy the
; contents of ax, bx, cx, dx and si.

; A word about the JMP below...
; I've seen a number of ways to adjust CS after entering protected mode.
; Some folks do a far jump to a selector:label combo, others manualy adjust
; CS themselves or use a call or something... I figured a novel approach
; would be to prepare CS while still in real mode. The JMP line below this
; massive comment does just that - simply jumps to the very next line, but
; it is now specified by segment 0x08 and offset 0x0555 instead of the usual
; 0x0060 segment at which the FreeDOS bootloader sets up code. We're
; essentially referring to the _exact_ same location, except by a different
; segment:offset pair. The segment used here (0x08) happens to be the code
; selector which will be set up later in the GDT. We just got the processor
; prepared early. :)

jmp 0x0008:0x0555                      ; jump to the very next line to
                                       ; alter the CS register

mov ax, 0x00                           ; set up the registers
mov ds, ax
mov es, ax
mov ax, 0x9000
mov ss, ax
mov sp, 0xffff

call Cls

push kCopyright                        ; print the intro message
call Print
push kCRLF
call Print
push kCRLF
call Print
push kCRLF
call Print

push kLoadGDT
call Print
cli                                    ; load GDT
lgdt [gdtHeader]
push kSuccess
call Print

push kTryPMode
call Print

mov eax, cr0                           ; enter protected mode
or eax, 00000001b                      ; set bit 0 of cr0
mov cr0, eax


jmp mainLoop



mainLoop:
mov ax, 0x10                           ; fix segment registers
mov ds, ax
mov ss, ax
mov es, ax
mov esp, 0x9000



; environment detection and setup starts here
mov eax, 0x01000000
mov ebx, 0x48
mov [eax], ebx

inc eax
mov ebx, 0x65
mov [eax], ebx

inc eax
mov ebx, 0x6c
mov [eax], ebx

inc eax
mov ebx, 0x6c
mov [eax], ebx

inc eax
mov ebx, 0x6f
mov [eax], ebx

mov eax, 0xffffffff
printloop:
dec eax
jmp printloop


ret                                    ; and exit!



; There are functions in the basement, Arthur O.O



Cls:
 mov ax, 0x03                           ; clear screen with mode 3
 push ax
 call VGASetMode
ret



Reboot:
 mov ax, 0
 mov gs, ax
 mov ax, 0x1234
 mov [gs:0x02C8], ax
 jmp 0xFFFF:0
ret



Print:
 pop dx                                ; pop off the return address
 mov cx, si                            ; save si in cx
 pop si
 mov ah, 0x0E
 PrintLoopStart:
 lodsb
 cmp al, 0
 jz PrintDone 
 int 0x10
 jmp PrintLoopStart
 PrintDone:
 mov si, cx                            ; restore si
 push dx                               ; restore return address
ret



VGASetMode:
 pop bx                                ; pop off the return address
 pop ax                                ; pop off the parameter
 mov ah, 0x00                          ; finally do the function
 int 0x10
 push bx                               ; push the return address back on
ret



; allocate space for variables
gdt:
               dd       0              ; null descriptor (0)
               dd       0
                
               dw       0xffff         ; code descriptor (1)
               dw       0x0000
               db       0x0000
               db       10011010b
               db       11001111b
               db       0x00

               dw       0xffff         ; data descriptor (2)
               dw       0x0000
               db       0x0000
               db       10010010b
               db       11001111b
               db       0

gdtHeader:
               dw gdt - gdtHeader - 1
               dd gdt

idt:
               dd       0x00           ; int 0 handler descriptor
               dd       0x08
               dd       0x00
               dd       010001110b
               dd       0x00

kCRLF          db       0x0d, 0x0a, 0x00
kCopyright     db       'DOSPM 1995 - 2015 by Mercury0x000d', 0
kSuccess       db       'success.', 0x0d, 0x0a, 0x0d, 0x0a, 0
kTryPMode      db       'Attempting to enter protected mode... ', 0
kLoadGDT       db       'Loading GDT... ', 0
gVideoMem      dd       0x000B8000
