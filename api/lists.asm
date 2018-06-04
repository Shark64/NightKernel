; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; lists.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



bits 32



LMItemAddAtSlot:
	; Adds an item to the list specified
	;
	;  input:
	;   table address
	;   element at which to add element
	;	new item address
	;	new item size
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, edx, esi, edi

	pop eax
	pop edi
	pop edx
	pop esi
	pop ebx
	push eax

	; save the important stuff
	mov dword [.listAddress], edi
	mov dword [.destElement], edx
	mov dword [.newItemAddress], esi
	mov dword [.newItemSize], ebx

	; check list validity
	push edi
	call LMListChecksumTest
	pop eax

	; error out if the list was invalid
	cmp eax, [kTrue]
	je .ListValid

	; add error handling code here later
	mov eax, 0xDEAD0003
	jmp $

	.ListValid:
	; the list passed the data integrity check, so we proceed
	; get the size of each element in this list
	mov edi, dword [.listAddress]
	push edi
	call LMListGetElementSize
	pop eax

	; save this for later
	mov dword [.listElementSize], eax

	; now compare that to the given size of the new item
	cmp dword [.newItemSize], eax
	jle .SizeValid

	; add error handling code here later
	mov eax, 0xDEAD0004
	jmp $

	.SizeValid:
	; if we get here, the size is ok, so we add it to the list!
	; get the size of each element in this list
	mov edi, dword [.listAddress]
	push edi
	call LMListGetElementSize
	pop eax

	; calculate the new destination address
	mov eax, dword [.listElementSize]
	mov edx, dword [.destElement]
	mul edx
	mov edi, dword [.listAddress]
	add eax, edi
	add eax, 20

	; prep the memory copy
	mov esi, dword [.newItemAddress]
	mov ebx, dword [.newItemSize]

	; copy the memory
	push ebx
	push eax
	push esi
	call MemCopy

	; new the checksum. yes, new is a verb.
	mov edi, dword [.listAddress]
	push edi
	call LMListChecksumCreate
	pop eax
	mov edi, dword [.listAddress]
	mov [edi], eax
ret
.listAddress									dd 0x00000000
.destElement									dd 0x00000000
.listElementSize								dd 0x00000000
.newItemAddress									dd 0x00000000
.newItemSize									dd 0x00000000



LMItemDelete:
	; Deletes the item specified from the list specified
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: 

	
ret



LMListChecksumCreate:
	; Creates and returns a checksum for the list specified
	;
	;  input:
	;   list address
	;
	;  output:
	;   checksum
	;
	;  changes: eax, ebx, ecx, edx, esi, edi


	pop edi
	pop esi

	; add 4 to the list pointer so we don't include the checksum area in the operation
	add esi, 4
	
	; get the total size of this list
	mov edx, [esi]

	; take 4 from the fix the size value to again compensate for the checksum area
	sub edx, 4

	; save our return value
	push edi

	; time to checksum!
	push dword 0xFFFFFFFF
	push edx
	push esi
	call CRC32
	pop eax
	
	; restore the return address
	pop edi

	; set up our exit
	push eax
	push edi
ret



LMListChecksumTest:
	; Tests the checksum of the list at the address specified to see if it's valid
	;
	;  input:
	;   list address
	;
	;  output:
	;   result
	;		kTrue - list valid
	;		kFalse - list invalid
	;
	;  changes: eax, ebx, ecx, edx, esi, edi

	pop edi
	pop esi

	; get the stored checksum of this list
	mov edx, [esi]

	; save some important stuff
	push edx
	push edi

	; now calculate a checksum ourselves to see how accurate the stored value is
	push esi
	call LMListChecksumCreate
	pop eax

	; restore important stuff
	pop edi
	pop edx

	; test the results
	cmp eax, edx
	je .ListValid

	; if we get here, the checksums don't match
	push dword [kFalse]
	jmp .Exit

	.ListValid:
	; if we get here, they do
	push dword [kTrue]

	.Exit:
	; restore the exit value
	push edi
ret



LMListCompact:
	; Compacts the list specified
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: 

	
ret



LMListDelete:
	; Deletes the list specified
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: 

	
ret



LMListFindFirstFreeSlot:
	; Finds the first free slot available in the list specified
	;
	;  input:
	;   list address
	;
	;  output:
	;   element number of first free slot
	;
	;  changes: eax, bl, ecx, edx, esi, edi

	pop edx
	pop edi
	push edx

	; save the address
	push edi

	; get the number of elements in this list
	push edi
	call LMListGetElementCount
	pop ecx

	; restore the address
	pop edi

	; initialize our counter
	mov esi, 0x00000000

	; set up a loop to test all of the elements in this list
	.FindLoop:
		; save the important stuff
		push ecx
		push esi
		push edi

		; test this element
		push esi
		push edi
		call LMListSlotFreeTest
		pop eax

		; restore the important stuff
		pop edi
		pop esi
		pop ecx

		; check the result
		cmp eax, [kTrue]
		jne .ElementNotEmpty

		; if we get here, the element was empty
		jmp .Exit

		.ElementNotEmpty:
		inc esi

	cmp esi, ecx
	jne .FindLoop

	.Exit:
	; set the stack and exit
	pop edx
	push esi
	push edx
ret



LMListGetElementCount:
	; Returns the number of elements in the list specified
	;
	;  input:
	;   list address
	;
	;  output:
	;   element number of first free slot
	;
	;  changes: eax, bl, ecx, edx, esi, edi

	pop ecx
	pop edi
	push ecx

	; save the important stuff
	push edi

	; check list validity
	push edi
	call LMListChecksumTest
	pop eax

	; restore the important stuff
	pop edi

	; error out if the list was invalid
	cmp eax, [kTrue]
	je .ListValid

	; add error handling code here later
	mov eax, 0xDEAD0006
	jmp $

	.ListValid:
	; our list has integrity, so let's proceed
	; now let's get the element size
	add edi, 8
	mov edx, [edi]

	; fix the stack and exit
	pop eax
	push edx
	push eax
ret



LMListGetElementSize:
	; Returns the size of elements in the list specified
	;
	;  input:
	;   list address
	;
	;  output:
	;   list element size
	;
	;  changes: eax, bl, ecx, edx, esi, edi

	pop ecx
	pop edi
	push ecx

	; save the important stuff
	push edi

	; check list validity
	push edi
	call LMListChecksumTest
	pop eax

	; restore the important stuff
	pop edi

	; error out if the list was invalid
	cmp eax, [kTrue]
	je .ListValid

	; add error handling code here later
	mov eax, 0xDEAD0005
	jmp $

	.ListValid:
	; our list has integrity, so let's proceed
	; now let's get the element size
	add edi, 16
	mov edx, [edi]

	; fix the stack and exit
	pop eax
	push edx
	push eax
ret



LMListNew:
	; Creates a new list in memory from the parameters specified
	;
	;  input:
	;   number of elements
	;	size of each element
	;
	;  output:
	;   memory address of list
	;
	;  changes: eax, ebx, edx, esi, edi

	pop esi
	pop eax
	pop ebx

	; save eax and ebx for later
	push ebx
	push eax

	; calculate size of memory block needed to hold the actual list data into eax (may overwrite edx)
	; might want to add code here to check for edx being non-zero to indicate the list size is over 4 GB
	mul ebx

	; add bytes for the control block on the beginning of the list data
	add eax, 20

	; save the total memory size
	push eax

	; allocate the block
	push eax
	call MemAllocate
	pop edi

	; restore the saved memory size
	pop ecx

	; test the address we just got to see if it's valid
	cmp edi, 0
	jne .MemoryBlockValid

	; if we get here, the block address we got is invalid, so error time
	; add code here for an error eventually
	mov eax, 0x00DEAD00
	jmp $

	.MemoryBlockValid:
	; write the data to the start of the list area
	; add 4 to edi to allow for the checksum which will be filled in last
	add edi, 4

	; total size of list gets written first after being retrieved from the stack
	mov [edi], ecx
	add edi, 4

	; write the total number of elements
	pop eax
	mov [edi], eax
	add edi, 4

	; write the number of elements used
	; since this is a new list, there are a grand total of zero elements used
	mov [edi], dword 0x00000000
	add edi, 4

	; write the size of each element next
	; grab ebx that we saved at the beginning
	pop ebx
	mov [edi], ebx

	; now that everything else has been written, it's time to checksum the list
	; make edi point to the proper place
	sub edi, 16

	; save important stuff befrore the checksum call
	push esi
	push edi
	
	; let's get us a checksum!
	push edi
	call LMListChecksumCreate
	pop eax

	; restore the important stuff
	pop edi
	pop esi

	; write the checksum
	mov [edi], eax

	; the memory address needs to be returned so the caller knows where the list is. duh.
	push edi

	; restore our return vector and exit
	push esi
ret



LMListSearch:
	; Searches the list specified for the element specified
	;
	;  input:
	;   n/a
	;
	;  output:
	;   memory address of list
	;
	;  changes: 


ret



LMListSlotFreeTest:
	; Tests the element specified in trhe list specified to see if it is free
	;
	;  input:
	;   list address
	;   element number
	;
	;  output:
	;   result
	;		kTrue - element empty
	;		kFalse - element not empty
	;
	;  changes: eax, bl, ecx, edx, esi, edi

	pop ecx
	pop edi
	pop edx
	push ecx

	; save the important stuff
	push edx
	push edi

	; check list validity
	push edi
	call LMListChecksumTest
	pop eax

	; restore the important stuff
	pop edi
	pop edx

	; error out if the list was invalid
	cmp eax, [kTrue]
	je .ListValid

	; add error handling code here later
	mov eax, 0xDEAD0001
	jmp $

	.ListValid:
	; our list has integrity, so let's proceed

	; first we check that the element being tested is within the range of the list
	; do to this, first we get the number of elements from the list's control block
	add edi, 8
	mov eax, [edi]
	sub edi, 8

	; now compare that to the given size of the new item
	cmp edx, eax
	jle .ElementValid

	; add error handling code here later
	mov eax, 0xDEAD0002
	jmp $

	.ElementValid:
	; if we get here, the element is within range, so we caclulate the element's address in RAM
	; to do that, we'll need the size of each element
	add edi, 16
	mov ecx, [edi]
	sub edi, 16

	; get the address of the element in question
	mov esi, edi
	mov eax, edx
	mul ecx
	add esi, eax
	add esi, 20

	; set up a loop to check each byte of this element
	; ecx is already set up with the proper counter value from above
	mov edx, [kTrue]
	.CheckElement:
		; load a byte from the element into bl
		mov eax, esi
		add eax, ecx
		dec eax
		mov bl, [eax]

		; test bl to see if it's empty
		cmp bl, 0x00

		; decide what to do
		je .ByteEmpty

		; if we get here, the byte weasn't empty, so we set a flag
		mov edx, [kFalse]

		.ByteEmpty:
	loop .CheckElement

	; fix the stack and exit
	pop eax
	push edx
	push eax
ret



; list format:
; dword		checksum
; dword		total size of list in bytes
; dword		number of elements total
; dword		number of elements used
; dword		size of each element in bytes
; 			...followed by the actual list data
