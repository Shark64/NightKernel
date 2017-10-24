; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; serial.asm is a part of the Night Kernel

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



Serial1Init:
 ; Initializes the PS/2 keyboard
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   n/a
 ;
 ;  changes: 
 
 push dx
 mov al, 65
 mov dx, 0x03F8
 out dx, al
 pop dx
 pop ax
ret



Serial1Send:
 ; Initializes the PS/2 keyboard
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   n/a
 ;
 ;  changes: 
 
 push dx
 mov al, 65
 mov dx, 0x03F8
 out dx, al
 pop dx
 pop ax
ret



