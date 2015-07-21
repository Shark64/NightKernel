[map all kernel.map]

bits 16

org 0x0600

jmp main


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

GDT:
dw gdt_end - gdt_start - 1
dd gdt_start


load_GDT:
pusha
cli
lgdt [GDT]
sti
popa
ret

main:
cli
mov ax,0x0000
mov ss, ax
mov sp, 0xffff
sti

mov ax, 00h
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax

call load_GDT

cli
mov eax, cr0
or eax, 1
mov cr0, eax

jmp 08h:load_kernel



bits 32



print:
 ; Prints an ASCIIZ string to the screen. Assumes text mode already set.
 ;  input:
 ;   address of string to print
 ;   color of text
 ;   color of background
 ;
 ;  output:
 ;   n/a

 pop edx                   ; get return address for end ret
 pop ebx
 pop ecx
 pop eax
 push edx                  ; push return address back onto the stack

 mov esi, eax
 mov edi, 0xb8000          ; load edi with video memory address

 .loopBegin:
 mov al, [esi]
 inc esi

 cmp al, [kNull]           ; have we reached the string end?
 jz .end                   ; if yes, jump to end of routine

 mov byte[edi], al
 inc edi
 mov byte[edi], 0x07
 inc edi
 jmp .loopBegin
 .end:
ret



load_kernel:
mov ax, 10h
mov ds, ax
mov es, ax
mov ss, ax
mov esp, 0x900000


cli

push kCopyright
push 0x07
push 0x01
call print

infiniteLoop:
jmp infiniteLoop


; vars
kCopyright      db     'second.asm     2015 by Maarten Vermeulen'
kNull           db     0
