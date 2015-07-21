bits 16

org 5000h

jmp main


gdt_start:
dd 0
dd 0

dw 0xFFFF
dw 0 
db 0
db 10011010b
db 11001111b
db 0 

dw 0xFFFF
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
mov sp, 0xFFFF
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

load_kernel:
mov ax, 10h
mov ds, ax
mov es, ax
mov ss, ax
mov esp, 0x900000

mov edi, 0xB80000
mov BYTE[edi], '32-bit mode entered'
mov BYTE[edi+1], 14


cli
hlt

