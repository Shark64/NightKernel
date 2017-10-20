bits 16


GetModes:
; step through the VESA modes available and find the best one available
mov ds, [VESAInfoBlock.VideoModeListSegment]
mov si, [VESAInfoBlock.VideoModeListOffset]
mov edi, 0x00000000
mov edx, 0x00000000
.readLoop:
mov cx, [si]

;see if the mode = 0xffff so we know if we're all done
cmp cx, 0xFFFF
je .doneLoop

; get info on that mode
mov ax, 0x4F01
mov di, VESAModeInfo
sti
int 0x10
cli

; skip this mode if it doesn't support a linear frame buffer
cmp dword [VESAModeInfo.PhysBasePtr], 0x00000000
je .doNextIteration

push edx
mov eax, 0x00000000
mov ebx, 0x00000000
mov word ax, [VESAModeInfo.YResolution]
mov word bx, [VESAModeInfo.BytesPerScanline]
mul ebx
pop edx

; loop again if this mode doesn't score higher than our current record holder
cmp eax, edx
jna .doNextIteration
; it did score higher, so let's make note of it
mov gs, cx
mov edx, eax

.doNextIteration:
add si, 2
jmp .readLoop
.doneLoop:
mov ax, 0xbeef

; get info on the final mode
mov ax, 0x4F01
mov cx, gs
mov di, VESAModeInfo
sti
int 0x10
cli

; set that mode
mov ax, 0x4F02
mov bx, cx
sti
int 0x10
cli
jmp InitPM


bits 32

VESAPlot24:
 ; Draws a pixel directly to the VESA linear framebuffer
 ;  input:
 ;   horizontal position
 ;   vertical position
 ;   color attribute
 ;
 ;  output:
 ;   n/a

 pop esi                          ; get return address for end ret
 pop ebx                          ; get horizontal position
 pop eax                          ; get vertical position
 pop ecx                          ; get color attribute
 push esi                         ; push return address back on the stack

 ; calculate write position
 mov dx, [VESAModeInfo.XResolution]
 mul edx
 add ax, bx
 mov edx, 3
 mul edx
 add eax, [VESAModeInfo.PhysBasePtr]

 ; do the write
 mov byte [eax], cl
 inc eax
 ror ecx, 8
 mov byte [eax], cl
 inc eax
 ror ecx, 8
 mov byte [eax], cl
 ror ecx, 16
ret



VESAPlot32:
 ; Draws a pixel directly to the VESA linear framebuffer
 ;  input:
 ;   horizontal position
 ;   vertical position
 ;   color attribute
 ;
 ;  output:
 ;   n/a

 pop esi                          ; get return address for end ret
 pop ebx                          ; get horizontal position
 pop eax                          ; get vertical position
 pop ecx                          ; get color attribute
 push esi                         ; push return address back on the stack

 ; calculate write position
 mov dx, [VESAModeInfo.XResolution]
 mul edx
 add ax, bx
 mov edx, 4
 mul edx
 add eax, [VESAModeInfo.PhysBasePtr]

 ; do the write
 mov dword [eax], ecx
ret



VESAPrint24:
 ; Prints an ASCIIZ string directly to the VESA framebuffer in 24 bit color modes
 ;  input:
 ;   horizontal position
 ;   vertical position
 ;   color attribute
 ;   address of string to print
 ;
 ;  output:
 ;   n/a
 pop edx                          ; get return address for end ret
 pop ebx                          ; get horizontal position
 pop eax                          ; get vertical position
 pop ecx                          ; get text color
 pop ebp                          ; get background color
 pop esi                          ; get string address
 push edx                         ; push return address back on the stack

 ; calculate write position into edi and save to the stack
 mov edx, 0
 mov dx, [VESAModeInfo.XResolution] ; can probably be optimized to use bytes per scanline field to eliminate doing multiply
 mul edx
 add ax, bx
 mov edx, 3
 mul edx
 add eax, [VESAModeInfo.PhysBasePtr]
 mov edi, eax
 push edi

 ; keep the number of bytes in a scanline handy in edx for later
 mov edx, 0
 mov dx, [VESAModeInfo.BytesPerScanline]

 ; time to step through the string and draw it
 .StringDrawLoop:
 ; put the first character of the string into bl
 mov byte bl, [esi]

 ; see if the char we just got is null - if so, we exit
 cmp bl, 0x00
 jz .End

 ; it wasn't, so we need to calculate the beginning of the data for this char in the font table into eax
 mov eax, 0
 mov al, bl
 mov bh, 16
 mul bh
 add eax, kKernelFont

 .FontBytesLoop:
 ; save the contents of edx and move font byte 1 into dl, making a backup copy in dh
 push edx
 mov byte dl, [eax]
 mov byte dh, dl

 ; plot accordingly
 and dl, 10000000b
 cmp dl, 0
 jz .PointSkipA
 .PointPlotA:
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 16
 jmp .PointDoneA
 .PointSkipA:
 push ecx
 mov ecx, ebp
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 16
 pop ecx
 .PointDoneA:
 mov byte dl, dh

 ; plot accordingly
 and dl, 01000000b
 cmp dl, 0
 jz .PointSkipB
 .PointPlotB:
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 16
 jmp .PointDoneB
 .PointSkipB:
 push ecx
 mov ecx, ebp
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 16
 pop ecx
 .PointDoneB:
 mov byte dl, dh

 ; plot accordingly
 and dl, 00100000b
 cmp dl, 0
 jz .PointSkipC
 .PointPlotC:
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 16
 jmp .PointDoneC
 .PointSkipC:
 push ecx
 mov ecx, ebp
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 16
 pop ecx
 .PointDoneC:
 mov byte dl, dh

 ; plot accordingly
 and dl, 00010000b
 cmp dl, 0
 jz .PointSkipD
 .PointPlotD:
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 16
 jmp .PointDoneD
 .PointSkipD:
 push ecx
 mov ecx, ebp
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 16
 pop ecx
 .PointDoneD:
 mov byte dl, dh

 ; plot accordingly
 and dl, 00001000b
 cmp dl, 0
 jz .PointSkipE
 .PointPlotE:
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 16
 jmp .PointDoneE
 .PointSkipE:
 push ecx
 mov ecx, ebp
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 16
 pop ecx
 .PointDoneE:
 mov byte dl, dh

 ; plot accordingly
 and dl, 00000100b
 cmp dl, 0
 jz .PointSkipF
 .PointPlotF:
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 16
 jmp .PointDoneF
 .PointSkipF:
 push ecx
 mov ecx, ebp
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 16
 pop ecx
 .PointDoneF:
 mov byte dl, dh

 ; plot accordingly
 and dl, 00000010b
 cmp dl, 0
 jz .PointSkipG
 .PointPlotG:
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 16
 jmp .PointDoneG
 .PointSkipG:
 push ecx
 mov ecx, ebp
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 16
 pop ecx
 .PointDoneG:
 mov byte dl, dh

 ; plot accordingly
 and dl, 00000001b
 cmp dl, 0
 jz .PointSkipH
 .PointPlotH:
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 16
 jmp .PointDoneH
 .PointSkipH:
 push ecx
 mov ecx, ebp
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 8
 mov byte [edi], cl
 inc edi
 ror ecx, 16
 pop ecx
 .PointDoneH:
 mov byte dl, dh

 ; increment the font pointer
 inc eax

 ; set the framebuffer pointer to the next line
 sub edi, 24
 pop edx
 add edi, edx

 dec bh
 cmp bh, 0
 jne .FontBytesLoop


 ; increment the string pointer
 inc esi

 ;restore the framebuffer pointer to its original value, save a copy adjusted for the next loop
 pop edi
 add edi, 24
 push edi

 jmp .StringDrawLoop

 .End:

 ;get rid of that extra saved value
 pop edi

ret



VESAPrint32:
 ; Prints an ASCIIZ string directly to the VESA framebuffer in 32 bit color modes
 ;  input:
 ;   horizontal position
 ;   vertical position
 ;   color
 ;   background color
 ;   address of string to print
 ;
 ;  output:
 ;   n/a

 pop edx                          ; get return address for end ret
 pop ebx                          ; get horizontal position
 pop eax                          ; get vertical position
 pop ecx                          ; get text color
 pop ebp                          ; get background color
 pop esi                          ; get string address
 push edx                         ; push return address back on the stack

 ; calculate write position into edi and save to the stack
 mov edx, 0
 mov dx, [VESAModeInfo.XResolution] ; can probably be optimized to use bytes per scanline field to eliminate doing multiply
 mul edx
 add ax, bx
 mov edx, 4
 mul edx
 add eax, [VESAModeInfo.PhysBasePtr]
 mov edi, eax
 push edi

 ; keep the number of bytes in a scanline handy in edx for later
 mov edx, 0
 mov dx, [VESAModeInfo.BytesPerScanline]

 ; time to step through the string and draw it
 .StringDrawLoop:
 ; put the first character of the string into bl
 mov byte bl, [esi]

 ; see if the char we just got is null - if so, we exit
 cmp bl, 0x00
 jz .End

 ; it wasn't, so we need to calculate the beginning of the data for this char in the font table into eax
 mov eax, 0
 mov al, bl
 mov bh, 16
 mul bh
 add eax, kKernelFont

 .FontBytesLoop:
 ; save the contents of edx and move font byte 1 into dl, making a backup copy in dh
 push edx
 mov byte dl, [eax]
 mov byte dh, dl

 ; plot accordingly
 and dl, 10000000b
 cmp dl, 0
 jz .PointSkipA
 .PointPlotA:
 mov [edi], ecx
 jmp .PointDoneA
 .PointSkipA:
 mov [edi], ebp
 .PointDoneA:
 add edi, 4
 mov byte dl, dh

 ; plot accordingly
 and dl, 01000000b
 cmp dl, 0
 jz .PointSkipB
 .PointPlotB:
 mov [edi], ecx
 jmp .PointDoneB
 .PointSkipB:
 mov [edi], ebp
 .PointDoneB:
 add edi, 4
 mov byte dl, dh

 ; plot accordingly
 and dl, 00100000b
 cmp dl, 0
 jz .PointSkipC
 .PointPlotC:
 mov [edi], ecx
 jmp .PointDoneC
 .PointSkipC:
 mov [edi], ebp
 .PointDoneC:
 add edi, 4
 mov byte dl, dh

 ; plot accordingly
 and dl, 00010000b
 cmp dl, 0
 jz .PointSkipD
 .PointPlotD:
 mov [edi], ecx
 jmp .PointDoneD
 .PointSkipD:
 mov [edi], ebp
 .PointDoneD:
 add edi, 4
 mov byte dl, dh

 ; plot accordingly
 and dl, 00001000b
 cmp dl, 0
 jz .PointSkipE
 .PointPlotE:
 mov [edi], ecx
 jmp .PointDoneE
 .PointSkipE:
 mov [edi], ebp
 .PointDoneE:
 add edi, 4
 mov byte dl, dh

 ; plot accordingly
 and dl, 00000100b
 cmp dl, 0
 jz .PointSkipF
 .PointPlotF:
 mov [edi], ecx
 jmp .PointDoneF
 .PointSkipF:
 mov [edi], ebp
 .PointDoneF:
 add edi, 4
 mov byte dl, dh

 ; plot accordingly
 and dl, 00000010b
 cmp dl, 0
 jz .PointSkipG
 .PointPlotG:
 mov [edi], ecx
 jmp .PointDoneG
 .PointSkipG:
 mov [edi], ebp
 .PointDoneG:
 add edi, 4
 mov byte dl, dh

 ; plot accordingly
 and dl, 00000001b
 cmp dl, 0
 jz .PointSkipH
 .PointPlotH:
 mov [edi], ecx
 jmp .PointDoneH
 .PointSkipH:
 mov [edi], ebp
 .PointDoneH:
 add edi, 4
 mov byte dl, dh

 ; increment the font pointer
 inc eax

 ; set the framebuffer pointer to the next line
 sub edi, 32
 pop edx
 add edi, edx

 dec bh
 cmp bh, 0
 jne .FontBytesLoop


 ; increment the string pointer
 inc esi

 ;restore the framebuffer pointer to its original value, save a copy adjusted for the next loop
 pop edi
 add edi, 32
 push edi

 jmp .StringDrawLoop

 .End:

 ;get rid of that extra saved value
 pop edi
ret