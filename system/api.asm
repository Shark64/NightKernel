; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
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



bits 16



PrintSimple16:
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



SetSystemInfoAPM:
	; Gets the APM interface version and saves results to the tSystemInfo structure
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: ax, bx, cx

	mov ax, 0x5300
	mov bx, 0x0000
	int 0x15
	cmp bx, 0x504D
	jne .skipped
	mov byte [tSystemInfo.APMVersionMajor], ah
	mov byte [tSystemInfo.APMVersionMinor], al
	mov word [tSystemInfo.APMFeatures], cx
	.skipped:
ret



bits 32



ConvertToBinaryString:
	; Translates the value specified to a binary number in a zero-padded 32 byte string
	; Note: No length checking is done on this string; make sure it's long enough to hold the converted number!
	;       No terminating null is put on the end of the string - do that yourself.
	;  input:
	;   numeric value
	;   string address
	;
	;  output:
	;   n/a
	;
	; changes: eax, ebx, edx, esi

	pop edx
	pop eax
	pop esi
	push edx

	; clear the string to all zeroes
	pushad
	push 48
	push 32
	push esi
	call MemFill
	popad

	; add to the buffer since we start from the right (max possible length - 1)
	add esi, 31
	
	; set the divisor
	mov ebx, 2
	.DecodeLoop:
		mov edx, 0													; clear edx so we don't mess up the division
		div ebx														; divide eax by 10
		add dx, 48													; add 48 to the remainder to give us an ASCII character for this number
		mov [esi], dl
		dec esi														; move to the next position in the buffer
		cmp eax, 0
		jz .Exit													; if ax=0, end of the procedure
		jmp .DecodeLoop												; else repeat
	.Exit:
ret



ConvertToDecimalString:
	; Translates the value specified to a decimal number in a zero-padded 10 byte string
	; Note: No length checking is done on this string; make sure it's long enough to hold the converted number!
	;       No terminating null is put on the end of the string - do that yourself.
	;  input:
	;   numeric value
	;   string address
	;
	;  output:
	;   n/a
	;
	; changes: eax, ebx, edx, esi

	pop edx
	pop eax
	pop esi
	push edx

	; clear the string to all zeroes
	pushad
	push 48
	push 10
	push esi
	call MemFill
	popad

	; add to the buffer since we start from the right (max possible length - 1)
	add esi, 9
	
	; set the divisor
	mov ebx, 10
	.DecodeLoop:
		mov edx, 0													; clear edx so we don't mess up the division
		div ebx														; divide eax by 10
		add dx, 48													; add 48 to the remainder to give us an ASCII character for this number
		mov [esi], dl
		dec esi														; move to the next position in the buffer
		cmp eax, 0
		jz .Exit													; if ax=0, end of the procedure
		jmp .DecodeLoop												; else repeat
	.Exit:
ret



ConvertToHexString:
	; Translates the value specified to a hexadecimal number in a zero-padded 8 byte string
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



ConvertToOctalString:
	; Translates the value specified to an octal number in a zero-padded 11 byte string
	; Note: No length checking is done on this string; make sure it's long enough to hold the converted number!
	;       No terminating null is put on the end of the string - do that yourself.
	;  input:
	;   numeric value
	;   string address
	;
	;  output:
	;   n/a
	;
	; changes: eax, ebx, edx, esi

	pop edx
	pop eax
	pop esi
	push edx

	; clear the string to all zeroes
	pushad
	push 48
	push 11
	push esi
	call MemFill
	popad

	; add to the buffer since we start from the right (max possible length - 1)
	add esi, 10
	
	; set the divisor
	mov ebx, 8
	.DecodeLoop:
		mov edx, 0													; clear edx so we don't mess up the division
		div ebx														; divide eax by 10
		add dx, 48													; add 48 to the remainder to give us an ASCII character for this number
		mov [esi], dl
		dec esi														; move to the next position in the buffer
		cmp eax, 0
		jz .Exit													; if ax=0, end of the procedure
		jmp .DecodeLoop												; else repeat
	.Exit:
ret



PrintDebug:
	; Quick minimal printing routine, mainly for debug purposes
	;  input:
	;   horizontal position
	;   vertical position
	;   numeric value to print
	;   address of string to print
	;
	;  output:
	;   n/a
	;
	; changes:

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
	call ConvertToHexString
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
.scratchString														times 10 db 0x00



PrintSerial:
	; Prints an ASCIIZ string as a series of characters to serial port 1
	; Note: primarily for debugging
	;  input:
	;   address of string to print
	;
	;  output:
	;   n/a
	;
	;  changes: al, ebx, edx

	pop edx
	pop ebx
	push edx

	mov dx, 0x03F8
	.serialLoop:
		mov al, [ebx]

		; have we reached the string end? if yes, exit the loop
		cmp al, 0x00
		je .end

		; we're still here, so let's send a character
		out dx, al

		mov cl, [tSystemInfo.ticks]
		.timerloop:
			mov ch, [tSystemInfo.ticks]
			cmp cl, ch
			jne .timerdone
		jmp .timerloop
		.timerdone:
		inc ebx
	jmp .serialLoop
	.end:

	; throw on a cr & lf
	mov al, 0x013
	out dx, al
	mov al, 0x010
	out dx, al
ret



PrintSimple32:
	; Quick minimal printing routine, mainly for debug purposes in 16 bit mode
	;  input:
	;   address of string to print
	;
	;  output:
	;   n/a
	;
	; changes: 

	pop dword [.tempAddress]
	push 0xff000000
	push 0xff777777
	push 2
	push 2
	call [VESAPrint]
	push dword [.tempAddress]
ret
.tempAddress														dd 0x00000000



SetSystemInfoCPUID:
	; Probes the CPU using CPUID instruction and saves results to the tSystemInfo structure
	;  input:
	;   n/a
	;
	;  output:
	;   n/a

	; get vendor ID
	mov eax, 0x00000000
	cpuid
	mov esi, tSystemInfo.CPUIDVendorString
	mov [tSystemInfo.CPUIDLargestBasicQuery], eax
	mov [esi], ebx
	add esi, 4
	mov [esi], edx
	add esi, 4
	mov [esi], ecx

	; get processor brand string
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000004
	jnae .done
	mov [tSystemInfo.CPUIDLargestExtendedQuery], eax
	mov eax, 0x80000002
	cpuid
	mov esi, tSystemInfo.CPUIDBrandString
	mov [esi], eax
	add esi, 4
	mov [esi], ebx
	add esi, 4
	mov [esi], ecx
	add esi, 4
	mov [esi], edx
	add esi, 4
	mov eax, 0x80000003
	cpuid
	mov [esi], eax
	add esi, 4
	mov [esi], ebx
	add esi, 4
	mov [esi], ecx
	add esi, 4
	mov [esi], edx
	add esi, 4
	mov eax, 0x80000004
	cpuid
	mov [esi], eax
	add esi, 4
	mov [esi], ebx
	add esi, 4
	mov [esi], ecx
	add esi, 4
	mov [esi], edx
	.done:
ret



SetSystemInfoCPUSpeed:
	; Writes CPU speed info to the tSystemInfo structure
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: eax

	sti
	call CPUSpeedDetect
	pop eax
	mov [tSystemInfo.delayValue], eax
	cli
ret



SetSystemInfoRTC:
	; Copies the RTC time and date into the tSystemInfo structure
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: eax

	; wait until the status register tells us the RTC is busy
	mov al, 0x0A
	out 0x70, al
	.pollStatus1:
	in al, 0x71
	and al, 10000000b
	cmp al, 10000000b
	je .flagSet
	jmp .pollStatus1
	.flagSet:
	; wait until the status register tells us the RTC is not busy
	mov al, 0x0A
	out 0x70, al
	.pollStatus2:
	in al, 0x71
	and al, 10000000b
	cmp al, 00000000b
	je .flagClear
	jmp .pollStatus2
	.flagClear:

	; set binary format and 24 hour mode
	mov al, 0x0B
	out 0x70, al
	in al, 0x71
	or al, 00000110b
	mov bl, al
	mov al, 0x0B
	out 0x70, al
	mov al, bl
	out 0x71, al
	; get the century
	mov al, 0x32
	out 0x70, al
	mov eax, 0x00000000
	in al, 0x71
	mov byte [tSystemInfo.century], al
	; get the year
	mov al, 0x09
	out 0x70, al
	mov eax, 0x00000000
	in al, 0x71
	mov byte [tSystemInfo.year], al
	; get the month
	mov al, 0x08
	out 0x70, al
	mov eax, 0x00000000
	in al, 0x71
	mov byte [tSystemInfo.month], al
	; get the day
	mov al, 0x07
	out 0x70, al
	mov eax, 0x00000000
	in al, 0x71
	mov byte [tSystemInfo.day], al
	; get the hour
	mov al, 0x04
	out 0x70, al
	mov eax, 0x00000000
	in al, 0x71
	mov byte [tSystemInfo.hours], al
	; get the minutes
	mov al, 0x02
	out 0x70, al
	mov eax, 0x00000000
	in al, 0x71
	mov byte [tSystemInfo.minutes], al
	; get the seconds
	mov al, 0x00
	out 0x70, al
	mov eax, 0x00000000
	in al, 0x71
	mov byte [tSystemInfo.seconds], al
ret



SetSystemInfoVESA:
	; Sets information from the VESA subsystem into the tSystemInfo structure
	;  input:
	;   n/a
	;
	;  output:
	;   n/a

	mov byte dl, [tVESAInfoBlock.VBEVersionMajor]
	mov byte [tSystemInfo.VESAVersionMajor], dl

	mov byte dl, [tVESAInfoBlock.VBEVersionMinor]
	mov byte [tSystemInfo.VESAVersionMinor], dl

	mov eax, 0x00000000
	mov word ax, [tVESAInfoBlock.OEMStringSegment]
	shl eax, 4
	mov ebx, 0x00000000
	mov bx, [tVESAInfoBlock.OEMStringOffset]
	add eax, ebx
	mov dword [tSystemInfo.VESAOEMStringPointer], eax

	mov dword edx, [tVESAInfoBlock.Capabilities]
	mov dword [tSystemInfo.VESACapabilities], edx

	mov word dx, [tVESAModeInfo.XResolution]
	mov word [tSystemInfo.VESAWidth], dx

	mov word dx, [tVESAModeInfo.YResolution]
	mov word [tSystemInfo.VESAHeight], dx

	mov byte dl, [tVESAModeInfo.BitsPerPixel]
	mov byte [tSystemInfo.VESAColorDepth], dl

	; while we're messing with color depth, we may as well set up function pointers to the appropriate VESA code
	cmp dl, 0x20
	jne .ColorTest24Bit
	mov edx, VESAPrint32
	mov dword [VESAPrint], edx
	mov edx, VESAPlot32
	mov dword [VESAPlot], edx
	jmp .ColorTestDone
	.ColorTest24Bit:
	cmp dl, 0x18
	jne .ColorTest16Bit
	mov edx, VESAPrint24
	mov dword [VESAPrint], edx
	mov edx, VESAPlot24
	mov dword [VESAPlot], edx
	.ColorTest16Bit:
	; no others implemented for now
	.ColorTestDone:

	mov eax, 0x00000000
	mov word ax, [tVESAInfoBlock.TotalMemory]
	mov ebx, 0x00010000
	mul ebx
	mov ebx, 0x00000400
	div ebx
	mov dword [tSystemInfo.VESAVideoRAMKB], eax

	mov word dx, [tVESAInfoBlock.OEMSoftwareRev]
	mov word [tSystemInfo.VESAOEMSoftwareRevision], dx

	mov eax, 0x00000000
	mov word ax, [tVESAInfoBlock.OEMVendorNameSegment]
	shl eax, 4
	mov ebx, 0x00000000
	mov bx, [tVESAInfoBlock.OEMVendorNameOffset]
	add eax, ebx
	mov [tSystemInfo.VESAOEMVendorNamePointer], eax

	mov eax, 0x00000000
	mov word ax, [tVESAInfoBlock.OEMProductNameSegment]
	shl eax, 4
	mov ebx, 0x00000000
	mov bx, [tVESAInfoBlock.OEMProductNameOffset]
	add eax, ebx
	mov [tSystemInfo.VESAOEMProductNamePointer], eax

	mov eax, 0x00000000
	mov word ax, [tVESAInfoBlock.OEMProductRevSegment]
	shl eax, 4
	mov ebx, 0x00000000
	mov bx, [tVESAInfoBlock.OEMProductRevOffset]
	add eax, ebx
	mov [tSystemInfo.VESAOEMProductRevisionPointer], eax

	mov eax, tVESAInfoBlock.OEMData
	mov [tSystemInfo.VESAOEMDataStringsPointer], eax

	mov dword edx, [tVESAModeInfo.PhysBasePtr]
	mov dword [tSystemInfo.VESALFBAddress], edx
ret



TimerWait:
	; Waits the specified number of ticks
	;  input:
	;   tick count
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ecx, edx
	
	pop edx
	pop eax
	push edx
	
	mov ebx, 0x00000000

	.mainLoop:
		; set up the first pass of the inner delay loop
		mov dl, [tSystemInfo.ticks]
		mov dh, dl

		.timerLoop:
			mov dl, [tSystemInfo.ticks]
			cmp dl, dh
			jne .loopExit
		jmp .timerLoop
		.loopExit:
		inc ebx
		cmp eax, ebx
		je .done
	jmp .mainLoop
	.done:
ret
