; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; ddskel.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.


ddskel:

;
; Header information
;
    link_field      dd      -1                      ; link to next driver
    attributes      dw    0x8000                    ; device attributes
				                                    ;  Bit 15         1       - Character device
				                                    ;  Bit 14         0       - IOCTL supported
				                                    ;  Bit 13         0       - Output 'till  busy
				                                    ;  Bit 12         0       - Reserved
				                                    ;  Bit 11         0       - OPEN/CLOSE/RM supported
				                                    ;  Bit 10-4       0       - Reserved
				                                    ;  Bit  3         0       - Dev is CLOCK
				                                    ;  Bit  2         0       - Dev is NUL
				                                    ;  Bit  1         0       - Dev is STO (standard output)
				                                    ;  Bit  0         0       - Dev is STI (standard input)
                    dw      strategy
                    dw      commands
    device_name     db      '<DDSKEL>'               ; device driver name
;
; Additional driver data
;

    pkt_ptr         dd      0                       ; packet pointer storagre

    disp_tbl        dw      Init             	    ; 0 - Initialize driver
                    dw      ErrExit                 ; 1 - Build DPB
                    dw      ErrExit                 ; 2 - Media ID
                    dw      ErrExit                 ; 3 - IOCTL Read
                    dw      ErrExit                 ; 4 - Read
                    dw      ErrExit                 ; 5 - Non-Destructive Read
                    dw      ErrExit                 ; 6 - Input Status
                    dw      ErrExit                 ; 7 - Input Flush
                    dw      ErrExit                 ; 8 - Write
                    dw      ErrExit                 ; 9 - Write and Verify
                    dw      ErrExit                 ; 10 - Build DPB
                    dw      ErrExit                 ; 11 - Build DPB
                    dw      ErrExit                 ; 12 - Media ID
                    dw      ErrExit                 ; 13 - IOCTL Read
                    dw      ErrExit                 ; 14 - Read
                    dw      ErrExit                 ; 15 - Non-Destructive Read
                    dw      ErrExit                 ; 16 - Input Status
                    dw      ErrExit                 ; 17 - Input Flush
                    dw      ErrExit                 ; 18 - Write
                    dw      ErrExit                 ; 19 - Write and Verify
    Nbr_codes       equ     ($ - disp_tbl) / 2

    ;
    ; Strategy routine
    ;

        strategy:
                    mov     word [cs:pkt_ptr], bx
                    mov     word [cs:pkt_ptr+2], es
                    retf

    ;
    ; Interrupt routine
    ;
        commands:
                    pushf                       ; save all registers
                    push    ax
                    push    bx
                    push    cx
                    push    dx
                    push    ds
                    push    es
                    push    si
                    push    di
                    push    bp
                    mov     ax, cs                  ; set DS to this segment
                    mov     ds, ax
                    les     bx, [pkt_ptr]             ; Point ES:BX to packet
                    mov     al, [es:bx+2]           ; get function code
                    cmp     al, Nbr_codes           ; is it supported?
                    jae     ErrExit                 ; exit with error
                    cbw                             ; yes, jump to it's code
                    add     ax, ax
                    mov     si, ax
                    jmp     [disp_tbl+si]

        ErrExit:    mov     ax, 0x8103              ; error exit
        Exit:       mov     [es:bx+3], ax           ; normal exit
                    pop     bp
                    pop     di
                    pop     si
                    pop     es
                    pop     ds
                    pop     dx
                    pop     cx
                    pop     bx
                    pop     ax
                    popf
                    retf

;
; The resident routine
;
;
;   Any code to stay resident goes here
;


;
;   Initialization routine
;

    Init:               ; driver initialization code goes here
                        ; jump to fail if there is an error

                    mov ax, ErrExit
                    mov [disp_tbl], ax            ; make Init illegal next time

                    mov ax, 0x100               ; set DONE bit for status
                    jmp okay
    
    failed:         mov ax, 0x8100              ; set ERROR and DONE

    okay:           les bx, [pkt_ptr]             ; Release init space for use

                    ; assume es:nothing

                    mov [es:bx+0x0e], word Init
                    mov [es:bx+0x10], cs
                    jmp Exit     
