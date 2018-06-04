; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; strings.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



bits 16



ConvertByteToHexString16:
	; Translates the byte value specified to a hexadecimal number in a zero-padded 2 byte string in real mode
	;
	;  input:
	;   numeric byte value
	;   string address
	;
	;  output:
	;   n/a
	;
	; changes: al, cx, si, di

	pop cx
	pop si
	pop di
	push cx

	; handle digit 1
	mov cx, 0x00F0
	and cx, si
	shr cx, 4
	add cx, kHexDigits
	push si
	mov si, cx
	mov al, [si]
	pop si
	mov byte[di], al
	inc di

	; handle digit 2
	mov cx, 0x000F
	and cx, si
	add cx, kHexDigits
	push si
	mov si, cx
	mov al, [si]
	pop si
	mov byte[di], al
ret



ConvertWordToHexString16:
	; Translates the word value specified to a hexadecimal number in a zero-padded 4 byte string in real mode
	;
	;  input:
	;   numeric word value
	;   string address
	;
	;  output:
	;   n/a
	;
	; changes: al, cx, si, di

	pop cx
	pop si
	pop di
	push cx

	; handle digit 1
	mov cx, 0xF000
	and cx, si
	shr cx, 12
	add cx, kHexDigits
	push si
	mov si, cx
	mov al, [si]
	pop si
	mov byte[di], al
	inc di

	; handle digit 2
	mov cx, 0x0F00
	and cx, si
	shr cx, 8
	add cx, kHexDigits
	push si
	mov si, cx
	mov al, [si]
	pop si
	mov byte[di], al
	inc di

	; handle digit 3
	mov cx, 0x00F0
	and cx, si
	shr cx, 4
	add cx, kHexDigits
	push si
	mov si, cx
	mov al, [si]
	pop si
	mov byte[di], al
	inc di

	; handle digit 4
	mov cx, 0x000F
	and cx, si
	add cx, kHexDigits
	push si
	mov si, cx
	mov al, [si]
	pop si
	mov byte[di], al
	inc di
ret



bits 32



ConvertToBinaryString:
	; Translates the value specified to a binary number in a zero-padded 32 byte string
	; Note: No length checking is done on this string; make sure it's long enough to hold the converted number!z
	;       No terminating null is put on the end of the string - do that yourself.
	;
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
	pusha
	push 48
	push 32
	push esi
	call MemFill
	popa

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
	;
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
	pusha
	push 48
	push 10
	push esi
	call MemFill
	popa

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
	;
	;  input:
	;   numeric value
	;   string address
	;
	;  output:
	;   n/a
	;
	; changes: al, ecx, esi, edi

	pop ecx
	pop esi
	pop edi
	push ecx

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
	;
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
	pusha
	push 48
	push 11
	push esi
	call MemFill
	popa

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



StringBuild:
	; Builds a string out of the specified arguments
	;
	;  input:
	;   formatting string address
	;   destination string address
	;
	;  output:
	;   n/a
	;
	; changes:

	pop edx
	pop esi
	pop edi

	; save the addresses for later
	mov [.sourceAddress], esi
	mov [.destAddress], edi

	; get the length of the source string
	push edx
	push esi
	call StringLength
	pop ecx
	pop edx
	mov [.sourceLength], ecx

	; init the padding value
	mov al, 0
	mov [.padding], al

	; restore the destination address
	mov edi, [.destAddress]

	.StringBuildLoop:
		mov al, [esi]

		; see if this is the "^" token
		cmp al, 94
		je .ProcessToken

		; it wasn't the token, so we just write the character directly
		mov byte [edi], al
		inc edi

		; see if this is the end of the string
		cmp al, 0
		je .LoopDone

		.TokenDone:
		inc esi
	jmp .StringBuildLoop
	.LoopDone:
	push edx
ret

; local storage
.sourceLength									dd 0x00000000
.sourceAddress									dd 0x00000000
.destAddress									dd 0x00000000
.scratch$										times 36 db 0x00
.tokenStringLength								dd 0x00000000
.temp											dd 0x00000000
.padding										db 0x00
.zero$											db '0', 0x00

; subroutines - remember, edx, esi and edi MUST BE PRESERVED to not screw up the routines above
.ProcessToken:
	; get the character after the token to see what we need to do
	inc esi
	mov al, [esi]

	; b		Binary
	cmp al, 98
	je .TokenBinary

	; B		Binary
	cmp al, 66
	je .TokenBinary

	; d		Decimal
	cmp al, 100
	je .TokenDecimal

	; D		Decimal
	cmp al, 68
	je .TokenDecimal

	; h		Hexadecimal
	cmp al, 104
	je .TokenHexadecimal

	; H		Hexadecimal
	cmp al, 72
	je .TokenHexadecimal

	; o		Octal
	cmp al, 111
	je .TokenOctal

	; O		Octal
	cmp al, 79
	je .TokenOctal

	; s		String
	cmp al, 115
	je .TokenString

	; S		String
	cmp al, 83
	je .TokenString

	; p		set padding value
	cmp al, 112
	je .SetPaddingValue

	; P		set padding value
	cmp al, 80
	je .SetPaddingValue

	; if we get here, there was no token match. let's just put the character itself in instead
	mov byte [edi], al
	inc edi

jmp .TokenDone

.TokenBinary:
	; get the number
	pop eax

	; convert it to a string
	pusha
	push .scratch$
	push eax
	call ConvertToBinaryString
	popa
jmp .TokenProcessing

.TokenDecimal:
	; get the number
	pop eax

	; convert it to a string
	pusha
	push .scratch$
	push eax
	call ConvertToDecimalString
	popa
jmp .TokenProcessing

.TokenHexadecimal:
	; get the number
	pop eax

	; convert it to a string
	pusha
	push .scratch$
	push eax
	call ConvertToHexString
	popa
jmp .TokenProcessing

.TokenOctal:
	; get the number
	pop eax

	; convert it to a string
	pusha
	push .scratch$
	push eax
	call ConvertToOctalString
	popa
jmp .TokenProcessing

.TokenString:
	; get the starting address
	pop ebx

	; get its length
	pusha
	push ebx
	call StringLength
	pop eax
	mov [.tokenStringLength], eax
	popa

	; insert the temp string into our destination string
	pusha
	mov eax, [.tokenStringLength]
	push eax
	push edi
	push ebx
	call MemCopy
	popa

	; adjust the length
	mov eax, [.tokenStringLength]
	add edi, eax
jmp .TokenDone

.SetPaddingValue:
	; get the character after to see what value is there
	inc esi
	mov al, [esi]
	sub al, 48
	mov [.padding], al
jmp .TokenDone

.TokenProcessing:
	pusha

	; trim all those extra zeros
	push 48
	push .scratch$
	call StringTrimLeft

	; get the resulting string length
	push .scratch$
	call StringLength
	pop eax
	mov [.temp], eax

	; test the scratch string to see if the entire string was trimmed out (e.g. it was all zeros to begin with)
	mov eax, [.temp]
	cmp eax, 0
	jne .TokenProcessingNoAdjust

	; if we get here, the string length after trimming is 0, so lets make the number an actual zero instead
	mov esi, .scratch$
	mov byte [esi], 48
	inc esi
	mov byte [esi], 0

	; now adjust the length to reflect our changes
	mov eax, 1
	mov [.temp], eax
	.TokenProcessingNoAdjust:

	; see if the string is shorter than our padding value
	mov eax, [.temp]
	mov ebx, 0x00000000
	mov bl, [.padding]
	cmp ebx, eax
	jle .TokenProcessingNoPadding
	; if we get here, we need to pad with zeros
	.TokenProcessingPaddingLoop:
		mov esi, .scratch$
		mov edi, .zero$
		push 0
		push edi
		push esi
		call StringInsert

		; get the resulting string length
		push .scratch$
		call StringLength
		pop eax
		mov [.temp], eax

		; compare the length again to see if we're done
		mov eax, [.temp]
		mov ebx, 0x00000000
		mov bl, [.padding]
		cmp ebx, eax
	jg .TokenProcessingPaddingLoop

	; if we get here, padding wasn't necessary
	.TokenProcessingNoPadding:
	popa

	; insert the temp string into our destination string
	pusha
	mov eax, [.temp]
	push eax
	push edi
	push .scratch$
	call MemCopy
	popa

	; modify edi for the string length
	mov eax, [.temp]
	add edi, eax

	; clear the scratch string
	pusha
	push 0
	push 36
	push .scratch$	
	call MemFill
	popa
jmp .TokenDone



StringCaseLower:
	; Converts a string to lower case
	;
	;  input:
	;   string starting address
	;
	;  output:
	;   n/a
	;
	; changes: eax, ecx

	pop eax
	pop ecx
	push eax

	.StringLoop:
		mov byte al, [ecx]

		cmp al, 0x00
		je .StringLoopDone

		cmp al, 65
		jb .NotInRange

		cmp al, 90
		ja .NotInRange

		; if we get here, it was in range, so we drop it to lower case
		add al, 32
		mov [ecx], al

		.NotInRange:
		inc ecx
	jmp .StringLoop
	.StringLoopDone:
ret



StringCaseUpper:
	; Converts a string to upper case
	;
	;  input:
	;   string starting address
	;
	;  output:
	;   n/a
	;
	; changes: eax, ecx

	pop edx
	pop ecx
	push edx

	.StringLoop:
		mov byte al, [ecx]

		cmp al, 0x00
		je .StringLoopDone

		cmp al, 97
		jb .NotInRange

		cmp al, 122
		ja .NotInRange

		; if we get here, it was in range, so we raise it to upper case
		sub al, 32
		mov [ecx], al

		.NotInRange:
		inc ecx
	jmp .StringLoop
	.StringLoopDone:
ret



StringDelete:
	; Deletes the character at the location specified from the string
	;
	;  input:
	;   string starting address
	;   character position to remove
	;
	;  output:
	;   n/a
	;
	; changes: ecx, edx, esi

	pop esi
	pop ecx										; string starting address
	pop edx										; character position to remove
	push esi

	; test for null string for efficiency
	mov byte al, [ecx]
	cmp al, 0x00
	je .StringTrimDone

	; calculate source string position
	add ecx, edx

	; calculate the destination position
	mov edx, ecx
	dec edx

	.StringShiftLoop:
		; load a char from the source position
		mov al, [ecx]
		mov [edx], al

		; test if this is the end of the string
		cmp al, 0x00
		je .StringTrimDone

		; that wasn't the end, so we increment the pointers and do the next character
		inc edx
		inc ecx
	jmp .StringShiftLoop
	.StringTrimDone:
ret



StringFill:
	; Fills the entire string specified with the character specified
	;
	;  input:
	;   string starting address
	;   fill character
	;
	;  output:
	;   n/a
	;
	; changes: eax, ebx, ecx

	pop eax
	pop ecx
	pop ebx
	push eax

	.StringLoop:
		mov byte al, [ecx]

		cmp al, 0x00
		je .StringLoopDone

		mov [ecx], bl

		inc ecx
	jmp .StringLoop
	.StringLoopDone:
ret



StringInsert:
	; Inserts a character into the string at the location specified
	;
	;  input:
	;   main string address
	;   insert string address
	;	position after which to insert the character
	;
	;  output:
	;   n/a
	;
	; changes: eax, ebx, ecx, edx, edi

	pop edi
	pop ecx										; main string address
	pop edx										; insert string address
	pop ebx										; position after which to insert the character
	push edi

	; we'll need these again later
	push edx
	push ecx

	; get the length of the main string
	pusha
	push ecx
	call StringLength
	pop eax
	mov [.mainLength], eax
	popa

	; check insert position; writing AT the end of the string is okay, PAST it is not
	mov eax, [.mainLength]
	cmp ebx, eax
	jbe .CheckOK
	; if we get here the insert position is invalid, so get rid of the saved values on the stack and exit
	pop eax
	pop eax
	jmp .Exit
	.CheckOK:

	; get the length of the insert string
	pusha
	push edx
	call StringLength
	pop eax
	mov [.insertLength], eax
	popa

	; set up a value to use later to check if the loop is over
	mov edx, ecx
	add edx, ebx

	; calculate address of the first char in the section of chars to be shifted down
	add ecx, eax

	; calculate the address of the last char of the resulting string
	mov edi, ecx
	add edi, [.insertLength]

	.StringShiftLoop:
		; load a char from the source position
		mov al, [ecx]
		mov [edi], al

		; test if we have reached the insert position
		cmp edx, edi
		je .StringTrimDone

		; that wasn't the end, so we increment the pointers and do the next character
		dec edi
		dec ecx
	jmp .StringShiftLoop

	; now that we've made room for it, we can proceed to write the insert string into the main string

	.StringTrimDone:
	; calculate the write address based on the location specified
	pop ecx
	add ecx, ebx

	; get the address of the insert string
	pop edx

	.StringWriteLoop:
		mov al, [edx]							; get a byte from the insert string
		cmp al, 0x00							; see if it's null
		je .StringWriteDone						; if so, jump out of the loop - we're done!
		mov [ecx], al							; if we get here, it's not the end yet
		inc edx									; increment the pointers and start over
		inc ecx
	jmp .StringWriteLoop
	.StringWriteDone:
.Exit:
ret
.mainLength										dd 0x00000000
.insertLength									dd 0x00000000



StringLength:
	; Returns the length of the string specified
	;
	;  input:
	;   string starting address
	;
	;  output:
	;   string length
	;
	; changes: al, ebx, ecx, edx

	pop edx
	pop ecx
	mov ebx, ecx

	.StringLoop:
		mov byte al, [ecx]

		cmp al, 0x00
		je .StringLoopDone

		; if we get here, it wasn't the end
		inc ecx
	jmp .StringLoop
	.StringLoopDone:
	sub ecx, ebx
	push ecx
	push edx
ret



StringReplaceChars:
	; Replaces all occurrances of the specified character with another character specified
	;
	;  input:
	;   string starting address
	;   character to be replaced
	;   replacement character
	;
	;  output:
	;   n/a
	;
	; changes: al, ebx, ecx, edx, esi

	pop esi
	pop ecx										; string starting address
	pop ebx										; character to be replaced
	pop edx										; replacement character
	push esi

	.StringLoop:
		mov byte al, [ecx]

		cmp al, 0x00
		je .StringLoopDone

		cmp al, bl
		jne .NoMatch

		; if we get here, it was in range, so replace it
		mov [ecx], dl

		.NoMatch:
		inc ecx
	jmp .StringLoop
	.StringLoopDone:
ret



StringReplaceCharsInRange:
	; Replaces any character within the range of ASCII codes specified with the specified character
	;
	;  input:
	;   string starting address
	;   start of ASCII range
	;   end of ASCII range
	;   replacement character
	;
	;  output:
	;   n/a
	;
	; changes: eax, ebx, ecx, edx, esi

	pop esi
	pop ecx										; string starting address
	pop eax										; start of range
	pop ebx										; end of range
	pop edx										; replacement character
	push esi

	mov bh, al

	; see if the range numbers are backwards and swap them if necessary
	cmp bh, bl
	jl .StringLoop
	xchg bh, bl

	.StringLoop:
		mov byte al, [ecx]

		cmp al, 0x00
		je .StringLoopDone

		cmp al, bh
		jb .NotInRange

		cmp al, bl
		ja .NotInRange

		; if we get here, it was in range, so replace it
		mov [ecx], dl

		.NotInRange:
		inc ecx
	jmp .StringLoop
	.StringLoopDone:
ret



StringTrimLeft:
	; Trims any occurrances of the character specified off the left side of the string
	;
	;  input:
	;   string starting address
	;   ASCII code of the character to be trimmed
	;
	;  output:
	;   n/a
	;
	; changes: al, ebx, ecx, edx, esi

	pop esi
	pop ecx										; string starting address
	pop ebx										; ASCII code of the character to be trimmed
	push esi
	mov edx, ecx								; save the string address for later

	; see from where we have to start shifting
	.StringLoop:
		mov byte al, [ecx]

		cmp al, bl
		jne .StartShifting

		; if theis was the last byte of the string, then exit the loop
		cmp al, 0x00
		je .StringTrimDone

		inc ecx
	jmp .StringLoop

	.StartShifting:
	; if we get here, the current character isn't a match, so we can start shifting the characters

	; but first, a test... if ecx = edx then there's no shifting necessary and we can exit right away
	cmp ecx, edx
	je .StringTrimDone

	.StringShiftLoop:
		; load a char from the source position
		mov al, [ecx]
		mov [edx], al

		; test if this is the end of the string
		cmp al, 0x00
		je .StringTrimDone

		; that wasn't the end, so we increment the pointers and do the next character
		inc edx
		inc ecx
	jmp .StringShiftLoop
	.StringTrimDone:
ret



StringTrimRight:
	; Trims any occurrances of the character specified off the right side of the string
	;
	;  input:
	;   string starting address
	;   ASCII code of the character to be trimmed
	;
	;  output:
	;   n/a
	;
	; changes: eax, ebx, ecx, esi

	pop esi
	pop ecx										; string starting address
	pop ebx										; ASCII code of the character to be trimmed
	push esi

	; get the length of the string and use it to adjust the starting pointer of the string
	pusha
	push ecx
	call StringLength
	pop eax
	mov [.tempEAX], eax
	popa
	mov eax, [.tempEAX]
	add ecx, eax
	dec ecx

	.StringLoop:
		mov byte al, [ecx]

		cmp al, 0x00
		je .StringTrimDone

		cmp al, bl
		jne .Truncate
		dec ecx
	jmp .StringLoop

	.Truncate:
	; adjust the pointer to the position after the last char of the string and insert the null byte
	inc ecx
	mov byte [ecx], 0

	.StringTrimDone:
ret
.tempEAX										dd 0x00000000
