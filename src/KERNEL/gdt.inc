;----------------------------------------------------------
; GDT support routines
;----------------------------------------------------------

%ifndef __GDT_INC
%define __GDT_INC

bits	16

;----------------------------------------------------------
; load_GDT()
;     - Install our GDT
;----------------------------------------------------------

load_GDT:

cli								; clear interrupts
pusha							; save registers
lgdt	[GDTHeader]				; load GDT into GDTR
sti								; enable interrupts
popa							; restore registers
ret								; Return

;----------------------------------------------------------
; Global Descriptor Table (GDT)
;
;  --- Complete with Kernel and User space
;----------------------------------------------------------

gdt_start:

;----------------------------------------------------------
; Null descriptor (Offset 0x0)
;----------------------------------------------------------
dd 0
dd 0

;----------------------------------------------------------
; Kernel space code (Offset 0x8)
;----------------------------------------------------------
dw 0xffff						; limit low
dw 0 							; base low
db 0							; base middle
db 10011010b					; access
db 11001111b					; granularity
db 0 							; base high

;----------------------------------------------------------
; Kernel space data (Offset 0x10)	 
;----------------------------------------------------------
dw 0xffff						; limit low
dw 0 							; base low
db 0							; base middle
db 10010010b					; access
db 11001111b					; granularity
db 0 							; base high

;----------------------------------------------------------
; User Space code (Offset 0x18)
;----------------------------------------------------------
dw 0xffff						; limit low
dw 0 							; base low
db 0							; base middle
db 11111010b					; access
db 11001111b					; granularity
db 0 							; base high

;----------------------------------------------------------
; User Space data (Offset 0x20)
;----------------------------------------------------------
dw 0xFFFF 						; limit low
dw 0		 					; base low
db 0 							; base middle
db 11110010b 					; access
db 11001111b					; granularity
db 0							; base high

gdt_end:

GDTHeader:
dw gdt_end - gdt_start - 1		; size of GDT
dd gdt_start					; base of GDT

%endif ;__GDT_INC
