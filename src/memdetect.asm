; Night DOS Kernel (kernel.asm) version 0.03
; Copyright 1995-2015 by mercury0x000d

; memdetect.asm is a part of the Night DOS Kernel

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



;some stuff has changed, just to look if it did anything. I did some stuff lately which didn't help.
;It does really nothing with it now, it doesn't work yet. Just give me more time :)


memdetect:
mov eax, 0xE820					    ;ax need to be set to 0xE820 in order to call int 0x15
mov ecx, 20							; size for the result of the buffer, in bytes
mov edx, 534D4150h					; 'smap', no idea what that is, but it needs to be there
mov di, 20
int 0x15						    ;Detect upper memory

mov eax, [di]
cmp ax, 0
jnz e820Next

cmp eax, 03F00000h
jc e820Next



e820Next:
inc ebx								;ebx contains the next offset, this needs to be increased
cmp ebx, 00000000h
jne memdetect
mov ebx, 0FC00h
mov dx, [es:di]
push dx								;push dx, containing stuff and info
jmp errcheck


errcheck:
cmp ah, 86h
je .memerr86							;look for error: function not supported
cmp ah, 80h
je .memerr80							;look for error: invalid command
jmp memID

.memerr86:
push 0x07
push 3
push 1
push kMemErr86h
call PrintString
push 0x07
push 4
push 1
push kmemdetectFail
call PrintString
hlt

.memerr80:
push 0x07
push 3
push 1
push kMemErr86h
call PrintString
push 0x07
push 4
push 1
push kmemdetectFail
call PrintString
hlt





afterdetect:
push 0x07
push 3
push 1
push ecx
call PrintHex
hlt
;cmp ecx, [less20]
;je lessthen20
;cmp ecx, 20
;jne more20




memID:
cmp BYTE[es:di],	01h				;memory available	
je .memmsg01h
cmp BYTE[es:di],	02h				;memory reserved	
je .memmsg02h
cmp BYTE[es:di],	03h		        ;ACPI reserved			
je .memmsg03h
cmp BYTE[es:di],	04h				;ACPI RVS Memory	
je .memmsg04h
jmp msgdetectsuc6


;If this works....
.memmsg01h:						;this message must show
push 0x07
push 3
push 1
push mem01hret
call PrintString

.memmsg02h:						;Or this message must show
push 0x07
push 3
push 1
push mem02hret
call PrintString

.memmsg03h:						;Or this message must show
push 0x07
push 3
push 1
push mem03hret
call PrintString

.memmsg04h:						;Or this message must show
push 0x07
push 3
push 1
push mem03hret
call PrintString


msgdetectsuc6:
push 0x07
push 4
push 1
push kMemDetectSuc6
call PrintString

pop dx
push 0x07
push 4
push 1
push dx
call PrintHex

jmp done16




;%include "console.asm"
;%include "globals.asm" 



