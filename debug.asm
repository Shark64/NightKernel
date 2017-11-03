; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; debug.asm is a part of the Night Kernel

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



bits 32



DebugMenu:
	; Implements the in-kernel debugging menu
	;  input:
	;   n/a
	;
	;  output:
	;   n/a










; print splash message - if we get here, we're all clear!
push tSystemInfo.kernelCopyright
push 0xFF000000
push 0xFF777777
push 2
push 2
call [VESAPrint]



push 115200
push 1
call SerialSetBaud
pop edx

push 8
push 1
call SerialSetWordSize
pop edx

push 1
push 1
call SerialSetStopBits
pop edx

push 0
push 1
call SerialSetParity
pop edx



push tSystemInfo.kernelCopyright
call PrintSerial

push kCRLF
call PrintSerial

; debugging code follows

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
call PrintSimple32

call KeyGet
pop eax
cmp al, 0x71 ; ascii code for "q"
je .showMessage
cmp al, 0x77 ; ascii code for "w"
je .hideMessage






.DebugLoop:

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



mov eax, 0x00000000
mov al, [tSystemInfo.hours]
push kPrintString
push eax
call ConvertHexToString
push kPrintString
push 0xFF000000
push 0xFF777777
push 180
push 20
call [VESAPrint]
;;;;;;;;;;;;;;;;;
mov eax, 0x00000000
mov al, [tSystemInfo.minutes]
push kPrintString
push eax
call ConvertHexToString
push kPrintString
push 0xFF000000
push 0xFF777777
push 180
push 120
call [VESAPrint]
;;;;;;;;;;;;;;;;;
mov eax, 0x00000000
mov al, [tSystemInfo.seconds]
push kPrintString
push eax
call ConvertHexToString
push kPrintString
push 0xFF000000
push 0xFF777777
push 180
push 220
call [VESAPrint]
;;;;;;;;;;;;;;;;;
mov eax, 0x00000000
mov al, [tSystemInfo.ticks]
push kPrintString
push eax
call ConvertHexToString
push kPrintString
push 0xFF000000
push 0xFF777777
push 180
push 320
call [VESAPrint]
;;;;;;;;;;;;;;;;;
mov eax, 0x00000000
mov al, [tSystemInfo.month]
push kPrintString
push eax
call ConvertHexToString
push kPrintString
push 0xFF000000
push 0xFF777777
push 200
push 20
call [VESAPrint]
;;;;;;;;;;;;;;;;;
mov eax, 0x00000000
mov al, [tSystemInfo.day]
push kPrintString
push eax
call ConvertHexToString
push kPrintString
push 0xFF000000
push 0xFF777777
push 200
push 120
call [VESAPrint]
;;;;;;;;;;;;;;;;;
mov eax, 0x00000000
mov al, [tSystemInfo.century]
push kPrintString
push eax
call ConvertHexToString
push kPrintString
push 0xFF000000
push 0xFF777777
push 200
push 220
call [VESAPrint]
;;;;;;;;;;;;;;;;;
mov eax, 0x00000000
mov al, [tSystemInfo.year]
push kPrintString
push eax
call ConvertHexToString
push kPrintString
push 0xFF000000
push 0xFF777777
push 200
push 320
call [VESAPrint]
;;;;;;;;;;;;;;;;;




mov eax, 0x00000000
mov dx, 0x03F8
in al, dx
push kPrintString
push eax
call ConvertHexToString
push kPrintString
push 0xFF000000
push 0xFF777777
push 300
push 20
call [VESAPrint]


jmp .DebugLoop

ret

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
