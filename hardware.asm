; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; hardware.asm is a part of the Night Kernel

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



bits 16



PrintReal:
 ; Prints an ASCIIZ failure message directly to the screen.
 ; Note: Uses text mode (assumed already set) not VESA.
 ; Note: For use in Real Mode only.
 ;  input:
 ;   address of string to print
 ;
 ;  output:
 ;   n/a
 ;
 ;  changes: ax, bl, es, di, ds, si

 ; set the proper mode
 mov ah, 0x00
 mov al, 0x03
 sti
 int 0x10
 cli

 pop ax
 pop si
 push ax

 ; write the string
 mov bl, 0x07
 mov ax, 0xB800
 mov ds, ax
 mov di, 0x0000
 mov ax, 0x0000
 mov es, ax

 .loopBegin:
 mov al, [es:si]

 ; have we reached the string end? if yes, exit the loop
 cmp al, 0x00
 je .end

 mov byte[ds:di], al
 inc di
 mov byte[ds:di], bl
 inc di
 inc si
 jmp .loopBegin
 .end:

ret



bits 32



A20Enable:
 ; Enables the A20 line of the processor's address bus using the "Fast A20 enable" method
 ; Since A20 support is critical, this code will print an error then intentionally hang if unsuccessful
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   n/a

 in al, 0x92
 or al, 0x02
 out 0x92, al

 ; verify it worked
 in al, 0x92
 and al, 0x02
 cmp al, 0
 jnz .success

 ; it failed, so we have to say so
 push kFastA20Fail
 push 0xff777777
 push 2
 push 2
 call [VESAPrint]
 jmp .infiniteLoop
 .success:
ret
.infiniteLoop:
jmp .infiniteLoop



CPUSpeedDetect:
 ; Determines how many iterations of random activities the CPU is capable of in one second
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   number of iterations
 ;
 ;  changes: ebx, ecx, edx

 mov ebx, 0x00000000
 mov ecx, 0x00000000
 mov edx, 0x00000000
 mov al, [tSystemInfo.tickCounter]
 mov ah, al
 dec ah
 .loop1:
 inc ebx
 push ebx
 inc ecx
 push ecx
 inc edx
 push edx
 pop edx
 pop ecx
 pop ebx
 mov al, [tSystemInfo.tickCounter]
 cmp al, ah
 jne .loop1
 pop ebx
 push ecx
 push ebx
ret



PITInit:
 ; Init the PIT for our timing purposes
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   n/a

 mov ax, 1193180 / 256

 mov al, 00110110b
 out 0x43, al

 out 0x40, al
 xchg ah, al
 out 0x40, al
ret



Reboot:
 ; Performs a warm reboot of the PC
 ;  input:
 ;   n/a
 ;
 ;  output:
 ;   n/a
 ;
 ;  changes: al, dx

 mov dx, 0x92
 in al, dx
 or al, 00000001b
 out dx, al

 ; and now, for the return we'll never reach...
ret
