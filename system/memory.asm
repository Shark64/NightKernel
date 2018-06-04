; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; memory.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



bits 16



MemoryInit:
	; Probes the BIOS memory map using interrupt 0x15 function 0xE820,
	; finds the largest block of free RAM, and fills in the appropriate
	; system data structures for future use by the memory manager
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a

	; print the labels string if appropriate
	mov eax, [tSystem.configBits]
	and eax, 000000000000000000000000000000010b
	cmp eax, 000000000000000000000000000000010b
	jne .SkipLabelPrinting
	mov byte [textColor], 7
	mov byte [backColor], 0
	push .memoryMapLabels$
	call Print16

	.SkipLabelPrinting:

	mov ebx, 0x00000000							; set ebx index to zero to start the probing loop
	.ProbeLoop:
		mov eax, 0x0000E820						; eax needs to be 0xE820
		mov ecx, 24
		mov edx, 0x534D4150						; the magic value "SMAP"
		mov di, .buffer
		int 0x15

		; display the memory mapping table if appropriate
		push bx
		mov eax, [tSystem.configBits]
		and eax, 000000000000000000000000000000010b
		cmp eax, 000000000000000000000000000000010b
		jne .SkipMemoryMapPrinting

		; if we get here, it's cool to print verbose data, so let's build some strings!
		; first we fill in the address section of the string
		mov cx, 8
		mov dx, 0
		.MemoryMapAddressPrintLoop:
			mov si, .addressLow
			add si, cx
			dec si
			mov ax, [si]

			push cx
			mov si, .memoryMap$
			add si, 3							; position in output string
			add si, dx
			push si
			push ax
			call ConvertByteToHexString16
			pop cx
			add dx, 2
		loop .MemoryMapAddressPrintLoop

		; fill in the length section
		mov cx, 8
		mov dx, 0
		.MemoryMapLengthPrintLoop:
			mov si, .lengthLow
			add si, cx
			dec si
			mov ax, [si]

			push cx
			mov si, .memoryMap$
			add si, 22							; position in output string
			add si, dx
			push si
			push ax
			call ConvertByteToHexString16
			pop cx
			add dx, 2
		loop .MemoryMapLengthPrintLoop

		; fill in the type section
		mov si, .attributes
		mov ax, [si]

		push cx
		mov si, .memoryMap$
		add si, 41								; position in output string
		push si
		push ax
		call ConvertByteToHexString16
		pop cx

		; print the string
		push .memoryMap$
		call Print16

		.SkipMemoryMapPrinting:
		pop bx

		; add the size of this block to the total counter in the system struct
		mov ecx, dword [.lengthLow]
		add dword [tSystem.memoryInstalledBytes], ecx

		; test the output to see what we've just found
		mov ecx, dword [.attributes]
		cmp ecx, 0x01
		jne .SkipCheckBlock

			; if we get here, there's a good block of available RAM
			; let's see if we've found a bigger block than the current record holder!
			mov eax, dword [.lengthLow]
			cmp eax, dword [tSystem.memoryInitialAvailableBytes]
			jna .SkipCheckBlock

			; if we get here, we've found a new biggest block! YAY!
			mov dword [tSystem.memoryInitialAvailableBytes], eax
			mov eax, dword [.addressLow]
			mov dword [tSystem.memoryBlockAddress], eax

		.SkipCheckBlock:
		; check to see if we're done with the loop
		cmp ebx, 0x00
		je .Done
	jmp .ProbeLoop

	.Done:
ret
.memoryMapLabels$								db '   Address            Size               Type', 0x00
.memoryMap$										db '   xxxxxxxxxxxxxxxx   xxxxxxxxxxxxxxxx   xx', 0x00
.buffer:
	.addressLow									dd 0x00000000
	.addressHigh								dd 0x00000000
	.lengthLow									dd 0x00000000
	.lengthHigh									dd 0x00000000
	.attributes									dd 0x00000000
	.extra										dd 0x00000000



bits 32



MemAllocate:
	; Returns the address of a block of memory of the specified size, or zero if a block of that size is unavailble
	;
	;  input:
	;   requested memory size in bytes
	;
	;  output:
	;   address of requested block, or zero if call fails

	; This routine temporarily uses a "dummy" allocation scheme; it simply allocates the amount of RAM requested beginning
	; at the 2 MB mark and increasing upward with no error checking whatsoever. This will allow basic allocate calls to
	; function for development purposes until the full paged memory manager is completed.

	pop edx
	pop ecx

	; see if nextAllocation is zero
	cmp dword [.nextAllocation], 0
	jne .DoAllocation

	; if we get here, nextAllocation = 0, so we init the value before using it
	mov eax, [tSystem.memoryBlockAddress]
	mov dword [.nextAllocation], eax

	.DoAllocation:
	mov eax, [.nextAllocation]
	push eax
	add eax, ecx
	mov [.nextAllocation], eax
	push edx
ret
.nextAllocation									dd 0x00000000



MemCopy:
	; Copies the specified number of bytes from one address to another
	;
	;  input:
	;   source address
	;   destination address
	;   transfer length
	;
	;  output:
	;   n/a
	;
	; changes: eax, ecx, esi, edi

	pop eax
	pop esi
	pop edi
	pop ecx
	push eax

	; to copy at top speed, we will break the copy operation into two parts
	; first, we'll see how many multiples of 16 need transferred, and do those in 16-byte chunks

	; save the amount first
	push ecx

	; divide by 16
	shr ecx, 4

	; make sure the loop doesn't get executed if the counter is zero
	cmp ecx, 0
	je .ChunkLoopDone

	; do the copy
	.ChunkLoop:
		; read 16 bytes in
		mov eax, [esi]
		add esi, 4
		mov ebx, [esi]
		add esi, 4
		mov ebp, [esi]
		add esi, 4
		mov edx, [esi]
		add esi, 4

		; write them out
		mov [edi], eax
		add edi, 4
		mov [edi], ebx
		add edi, 4
		mov [edi], ebp
		add edi, 4
		mov [edi], edx
		add edi, 4
	loop .ChunkLoop
	.ChunkLoopDone:

	; now restore the transfer amount
	pop ecx

	; see how many bytes we have remaining
	and ecx, 0x0000000F

	; make sure the loop doesn't get executed if the counter is zero
	cmp ecx, 0
	je .ByteLoopDone

	; and do the copy
	.ByteLoop:
		lodsb
		mov byte [edi], al
		inc edi	
	loop .ByteLoop
	.ByteLoopDone:
ret



MemDispose:
	; Notifies the memory manager that the block specified by the address given is now free for reuse
	;
	;  input:
	;   starting address of block (obtained with MemoryGet)
	;
	;  output:
	;   n/a
	;
	; changes: eax, ebx, ecx, edx, esi, edi

ret



MemFill:
	; Fills the range of memory given with the byte value specified
	;
	;  input:
	;   starting fill address
	;   fill length
	;   fill character
	;
	;  output:
	;   n/a
	;
	; changes: ebx, ecx, esi, edi

	pop edi
	pop esi
	pop ecx
	pop ebx
	push edi

	mov edi, esi
	add edi, ecx

	.Loop:
		cmp esi, edi
		je .LoopDone
		mov byte [esi], bl
		inc esi
	jmp .Loop
	.LoopDone:
ret



MemResize:
	; Resizes the specified block of RAM to the new size specified
	;
	;  input:
	;	
	;
	;  output:
	;   
	;
	; changes: 

	
ret



MemSearchDWord:
	; Searches the memory range specified for the given dword value
	;
	;  input:
	;   search range start
	;   search range end
	;   dword for which to search
	;
	;  output:
	;   n/a
	;
	; changes: eax, ebx, ecx, edx


	pop eax
	pop ecx
	pop edx
	pop ebx
	push eax

	.MemorySearchLoop:
		; check if the dword we just loaded is a match
		mov eax, [ecx]
		cmp eax, ebx
		je .MemorySearchLoopDone
		; check if we're at the end of the search range
		cmp ecx, edx
		je .MemorySearchLoopDone
		inc ecx
	jmp .MemorySearchLoop
	.MemorySearchLoopDone:
ret



MemSearchWord:
	; Searches the memory range specified for the given word value
	;
	;  input:
	;   search range start
	;   search range end
	;   word for which to search
	;
	;  output:
	;   n/a
	;
	; changes: eax, ebx, ecx, edx

	pop eax
	pop ecx
	pop edx
	pop ebx
	push eax

	.MemorySearchLoop:
		; check if the word we just loaded is a match
		mov word ax, [ecx]
		cmp ax, bx
		je .MemorySearchLoopDone
		; check if we're at the end of the search range
		cmp ecx, edx
		je .MemorySearchLoopDone
		inc ecx
	jmp .MemorySearchLoop
	.MemorySearchLoopDone:
ret



memE820Unsupported$								db 'Could not detect memory, function unsupported', 0x00
