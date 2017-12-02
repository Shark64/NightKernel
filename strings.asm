; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; strings.asm is a part of the Night Kernel

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



StringBuild:
	; Builds a string out of the specified arguments
	;  input:
	;   start string address
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
	pushad
	push esi
	call StringLength
	pop ecx
	mov [.sourceLength], ecx
	popad
	mov ecx, [.sourceLength]

	.StringBuildLoop:
		mov al, [esi]

		; see if this is the "%" token
		cmp al, 37
		je .ProcessToken
		mov byte [edi], al
		.TokenDone:
		inc esi
		inc edi
	loop .StringBuildLoop
	push edx
ret

; local storage
.sourceLength									dd 0x00000000
.sourceAddress									dd 0x00000000
.destAddress									dd 0x00000000
.scratchString									times 36 db 0x00
.scratchStringCopy								times 36 db 0x00
.tokenStringLength								dd 0x00000000
.temp											dd 0x00000000

; subroutines
.ProcessToken:
	; get the character after the token to see what we need to dos
	inc esi
	mov al, [esi]

	; b		Binary
	cmp al, 98
	je .TokenBinary

	; d		Decimal
	cmp al, 100
	je .TokenDecimal

	; h		Hexadecimal
	cmp al, 104
	je .TokenHexadecimal

	; o		Octal
	cmp al, 111
	je .TokenOctal

	; s		String
	cmp al, 115
	je .TokenString

	; if we get here, there was no token match. let's just put the character itself in instead
	mov byte [edi], al

jmp .TokenDone

.TokenBinary:
	; get the number
	pop eax

	; convert it to a string
	pushad
	push .scratchString
	push eax
	call ConvertToBinaryString
	popad

	; trim all those extra zeros
	pushad
	push 48
	push .scratchString
	call StringTrimLeft
	popad

	; insert the temp string into our destination string
	pushad
	mov eax, [.destAddress]
	sub edi, eax
	push edi
	push .scratchString
	mov eax, [.destAddress]
	push eax
	call StringInsert
	popad

	; get the resulting string length
	pushad
	push .scratchString
	call StringLength
	pop eax
	mov [.temp], eax
	popad
	
	; modify edi for the string length
	mov eax, [.temp]
	dec eax
	add edi, eax
	
	; clear the scratch string
	pushad
	push 36
	push .scratchString
	push .scratchStringCopy
	call MemCopy
	popad
jmp .TokenDone

.TokenDecimal:
	; get the number
	pop eax

	; convert it to a string
	pushad
	push .scratchString
	push eax
	call ConvertToDecimalString
	popad

	; trim all those extra zeros
	pushad
	push 48
	push .scratchString
	call StringTrimLeft
	popad

	; insert the temp string into our destination string
	pushad
	mov eax, [.destAddress]
	sub edi, eax
	push edi
	push .scratchString
	mov eax, [.destAddress]
	push eax
	call StringInsert
	popad

	; get the resulting string length
	pushad
	push .scratchString
	call StringLength
	pop eax
	mov [.temp], eax
	popad
	
	; modify edi for the string length
	mov eax, [.temp]
	dec eax
	add edi, eax
	
	; clear the scratch string
	pushad
	push 36
	push .scratchString
	push .scratchStringCopy
	call MemCopy
	popad
jmp .TokenDone

.TokenHexadecimal:
	; get the number
	pop eax

	; convert it to a string
	pushad
	push .scratchString
	push eax
	call ConvertToHexString
	popad

	; trim all those extra zeros
	pushad
	push 48
	push .scratchString
	call StringTrimLeft
	popad

	; insert the temp string into our destination string
	pushad
	mov eax, [.destAddress]
	sub edi, eax
	push edi
	push .scratchString
	mov eax, [.destAddress]
	push eax
	call StringInsert
	popad

	; get the resulting string length
	pushad
	push .scratchString
	call StringLength
	pop eax
	mov [.temp], eax
	popad
	
	; modify edi for the string length
	mov eax, [.temp]
	dec eax
	add edi, eax
	
	; clear the scratch string
	pushad
	push 36
	push .scratchString
	push .scratchStringCopy
	call MemCopy
	popad
jmp .TokenDone

.TokenOctal:
	; get the number
	pop eax

	; convert it to a string
	pushad
	push .scratchString
	push eax
	call ConvertToOctalString
	popad

	; trim all those extra zeros
	pushad
	push 48
	push .scratchString
	call StringTrimLeft
	popad

	; insert the temp string into our destination string
	pushad
	mov eax, [.destAddress]
	sub edi, eax
	push edi
	push .scratchString
	mov eax, [.destAddress]
	push eax
	call StringInsert
	popad

	; get the resulting string length
	pushad
	push .scratchString
	call StringLength
	pop eax
	mov [.temp], eax
	popad
	
	; modify edi for the string length
	mov eax, [.temp]
	dec eax
	add edi, eax
	
	; clear the scratch string
	pushad
	push 36
	push .scratchString
	push .scratchStringCopy
	call MemCopy
	popad
jmp .TokenDone

.TokenString:
	; get the starting address
	pop ebx

	; get its length
	pushad
	push ebx
	call StringLength
	pop eax
	mov [.tokenStringLength], eax
	popad

	; insert the temp string into our destination string
	pushad
	mov eax, [.destAddress]
	sub edi, eax
	push edi
	push ebx
	mov eax, [.destAddress]
	push eax
	call StringInsert
	popad
	
	mov eax, [.tokenStringLength]
	dec eax
	add edi, eax
jmp .TokenDone



StringCaseLower:
	; Converts a string to lower case
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



StringFill:
	; Fills the entire string specified with the character specified
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



StringDelete:
	; Deletes the character at the location specified from the string
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



StringInsert:
	; Inserts a character into the string at the location specified
	;  input:
	;   main string starting address
	;   insert string starting address
	;	position after which to insert the character
	;
	;  output:
	;   n/a
	;
	; changes: eax, ebx, ecx, edx, edi

	pop edi
	pop ecx										; main string starting address
	pop edx										; insert string starting address
	pop ebx										; position after which to insert the character
	push edi

	; we'll need these again later
	push edx
	push ecx

	; get the length of the main string
	pushad
	push ecx
	call StringLength
	pop eax
	mov [.mainLength], eax
	popad

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
	pushad
	push edx
	call StringLength
	pop eax
	mov [.insertLength], eax
	popad

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
	;  input:
	;   string starting address
	;   character to be trimmed
	;
	;  output:
	;   n/a
	;
	; changes: al, ebx, ecx, edx, esi

	pop esi
	pop ecx										; string starting address
	pop ebx										; character to be trimmed
	push esi
	mov edx, ecx								; save the string address for later

	.StringLoop:
		mov byte al, [ecx]

		cmp al, 0x00
		je .StringTrimDone

		cmp al, bl
		jne .StartShifting
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
	;  input:
	;   string starting address
	;   character to be trimmed
	;
	;  output:
	;   n/a
	;
	; changes: eax, ebx, ecx, esi

	pop esi
	pop ecx										; string starting address
	pop ebx										; character to be trimmed
	push esi

	; get the length of the string and use it to adjust the starting pointer of the string
	pushad
	push ecx
	call StringLength
	pop eax
	mov [.tempEAX], eax
	popad
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
