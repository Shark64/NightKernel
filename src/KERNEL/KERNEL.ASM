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

org 0x0600                             ; set origin point to where the
                                       ; FreeDOS bootloader loads this code

jmp skipDescriptorTables

idt:
     dd       0x00                     ; int 0 handler descriptor
     dd       0x08
     dd       0x00
     dd       010001110b
     dd       0x00

gdt_start:
     dd 0
     dd 0
     
     dw 0xffff
     dw 0 
     db 0
     db 10011010b
     db 11001111b
     db 0 
     
     dw 0xffff
     dw 0 
     db 0
     db 10010010b
     db 11001111b
     db 0 
gdt_end:

GDTHeader:
dw gdt_end - gdt_start - 1
dd gdt_start


load_GDT:
pusha
lgdt [GDTHeader]
popa
ret

skipDescriptorTables:
cli
mov ax, 0x0000                         ; init the stack segment 
mov ss, ax
mov sp, 0xffff

mov ax, 0x0000
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax

call load_GDT

mov eax, cr0                           ; enter protected mode. YAY!
or eax, 00000001b
mov cr0, eax

jmp 0x08:load_kernel



bits 32



load_kernel:
mov ax, 0x0010
mov ds, ax
mov es, ax
mov ss, ax
mov esp, 0x00090000


cli

push kCopyright
push 0x07
call print



; as proof we're in protected mode and addressing with 32 bits, let's write a
; "hello" greeeting at the 16MB mark!

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

infiniteLoop:
jmp infiniteLoop



; There are functions in the basement, Arthur O.O

print:
 ; Prints an ASCIIZ string to the screen. Assumes text mode already set.
 ;  input:
 ;   address of string to print
 ;   color attribute
 ;
 ;  output:
 ;   n/a

 pop edx                   ; get return address for end ret
 pop ebx                   ; get color attribute
 pop eax                   ; get string address
 push edx                  ; push return address back onto the stack

 ; set up color attribute

 mov esi, eax
 mov edi, [gVideoMem]      ; load edi with video memory address

 .loopBegin:
 mov al, [esi]
 inc esi

 cmp al, [kNull]           ; have we reached the string end?
 jz .end                   ; if yes, jump to end of routine

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
 
 mov ax, 0
 mov gs, ax
 mov ax, 0x1234
 mov [gs:0x02c8], ax
 jmp 0xffff:0000
ret



; vars
kCopyright           db     'Night DOS Kernel     2015 by Mercury0x000d, Maarten Vermeulen', 0x00
kCRLF                db     0x0d, 0x0a, 0x00
kNull                db     0
gVideoMem            dd     0x000B8000

