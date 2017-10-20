bits 16  

;For if we ever need to print (while it's not an error) in 16 bit :)

SimplePrint16:
;Basic screen output, very very very basic function
;;Note: This function doesn't care about line numbers (prints at cursor location)
; Input:
;  Message via the 'si' register (null terminated)
;
; Output:
;  Nothing to the system, message to the screen

;TODO:
;This needs to be user friendly some time (give it line numbers, maybe static)

lodsb
cmp al, 0 ;done yet?
je .done
mov ah, 0x0E ;print character on the screen
int 10h
jmp SimplePrint16
.done:
ret



bits 32

SimplePrint32:
;Basic screen output
;Note: This function doesn't care about line numbers (prints at x.0 and y.0)
; Input:
;  A message from the stack
;
; Output:
;  Nothing to the system, message to the screen


;TODO:
;This, sometime
