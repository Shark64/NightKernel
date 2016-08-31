; Night Kernel
; Copyright 2015 - 2016 by mercury0x000d
; api.asm is a part of the Night Kernel

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



; Miscellaneous routines which will eventually comprise the Night API

ConvertHexToString:
 ; Makes a string out of a hexidceimal number
 ; Note: No length checking is done on this string; make sure it's long enough to hold the converted number!
 ;       No terminating null is put on the end of the string - do that yourself.
 ;  input:
 ;   numeric value
 ;   string address
 ;
 ;  output:
 ;   n/a

 pop ebx
 pop esi
 pop edi
 push ebx

 mov ecx, 0xF0000000
 and ecx, esi
 shr ecx, 28
 add ecx, kHexDigits
 mov al, [ecx]
 mov byte[edi], al
 inc edi

 mov ecx, 0x0F000000
 and ecx, esi
 shr ecx, 24
 add ecx, kHexDigits
 mov al, [ecx]
 mov byte[edi], al
 inc edi

 mov ecx, 0x00F00000
 and ecx, esi
 shr ecx, 20
 add ecx, kHexDigits
 mov al, [ecx]
 mov byte[edi], al
 inc edi

 mov ecx, 0x000F0000
 and ecx, esi
 shr ecx, 16
 add ecx, kHexDigits
 mov al, [ecx]
 mov byte[edi], al
 inc edi

 mov ecx, 0x0000F000
 and ecx, esi
 shr ecx, 12
 add ecx, kHexDigits
 mov al, [ecx]
 mov byte[edi], al
 inc edi

 mov ecx, 0x00000F00
 and ecx, esi
 shr ecx, 8
 add ecx, kHexDigits
 mov al, [ecx]
 mov byte[edi], al
 inc edi

 mov ecx, 0x000000F0
 and ecx, esi
 shr ecx, 4
 add ecx, kHexDigits
 mov al, [ecx]
 mov byte[edi], al
 inc edi

 mov ecx, 0x0000000F
 and ecx, esi
 add ecx, kHexDigits
 mov al, [ecx]
 mov byte[edi], al
 inc edi

ret



DebugPrint:
 ; Quick minimal printing routine for debug purposes
 ;  input:
 ;   horizontal position
 ;   vertical position
 ;   numeric value to print
 ;   address of string to print
 ;
 ;  output:
 ;   n/a

 ; do some stack magic to line up the items for calling in the order they'll be used
 pop esi
 pop eax
 pop ebx
 pop ecx
 pop edx
 push esi
 push edx
 push eax
 push ebx

 ; set up value print
 push .scratchString
 push ecx
 call ConvertHexToString
 pop ebx
 pop eax
 push eax
 push ebx
 push .scratchString
 push 0xFF000000
 push 0xFF777777
 push ebx
 push eax
 call [VESAPrint]

 ; set up string print
 pop ebx
 pop eax
 pop edx
 push edx
 push 0xFF000000
 push 0xFF777777
 push ebx
 add eax, 72
 push eax
 call [VESAPrint]
ret
.scratchString						times 10 db 0x00
















