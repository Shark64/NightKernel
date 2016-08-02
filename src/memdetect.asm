
starte820:
xor ebx, ebx 	;ebx needs to be set to 0
xor bp, bp      ;an entry count..........
mov edx, 0x0534D4150 ;smap needs to be set into edx
mov eax, 0xE820       ;eax needs to be E820
mov [es:di + 20], dword 1 ; so we are forcing a valid ACPI here
mov ecx, 24	;ask for 24 bytes
int 0x15		;call the int
jc short .failed
mov edx, 0x0534D4150
cmp eax, edx    ;eax gets reset to the 'smap' and edx is already that, so...
jne short .failed
test ebx, ebx  ;if ebx = 0 we failed, if ebx = 0 it's 1 entry long.
je short .failed
jmp short .next

.e820Continue:
mov eax, 0xe820 ;eax gets overwritten every time
mov [es:di + 20], dword 1
mov ecx, 24 ;ecx gets overwritten as well
int 0x15
jc short .e820f
mov edx, 0x0534D4150 ;repair the trashed register

.next:
jcxz .skipentry		;skip the entry which are 0 long
cmp cl, 20			;did we got a 24 byte ACPI response
jbe short .notext
test byte [es:di + 20], 1 ;if that's true is the ignore data bit clear
je short .skipentry

.notext:
mov ecx, [es:di + 8] ;get the lower memory region length
or ecx, [es:di + 12] ;or test for zero
jz .skipentry

.skipentry:
test ebx, ebx ;if it resets to 0 the list is done
jne short .e820Continue

.e820f:
mov [memmap_ent], bp ;store the entry count
clc					 ;clear the carry
ret

.failed:		;function unsupported
stc
push 0x07                         ; print failed to run kernel message
push 1
push 1
push kFailed
call PrintString

push 0x07                         ; print function unsupported message
push 1
push 2
push kMeme820unsup
call PrintString

push 0x07                         ; print reboot message
push 1
push 1
push kCopyright1
call PrintString

call Reboot
ret

memmap_ent db 0
