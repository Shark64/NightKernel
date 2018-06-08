; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; pci.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



; function listing:
; PCICalculateNext				Calculates the proper value of the next spot on the PCI bus
; PCICheckForFunction			Checks the bus/device/function specified to see if there's something there
; PCIDetect						Pokes the 32-bit I/O register at 0x0CF8 to see if there's a PCI controller there
; PCIDriverSearch				Scans all the drivers in the kernel to see if any match the class/subclass/progif given
; PCIGetFunctionCount			Returns the total number of functions across all PCI busses in the system
; PCIGetNextFunction			Starts a scans at the bus/device/function specified to find the next function in order
; PCIInitBus					Scans all PCI busses and shadows all data to a List Manager list
; PCILiveRead					Reads a 32-bit register value from the PCI target specified
; PCILiveWrite					Writes a 32-bit value to the target PCI register specified
; PCILoadDrivers				Cycles through all functions in the PCI list and loads drivers for each
; PCIReadAll					Gets all info for the specified PCI device and fills it into the struct at the given address
; PCIReadByte					Reads a byte register from the PCI target specified
; PCIReadWord					Reads a word register from the PCI target specified
; PCIReadDWord					Reads a dword register from the PCI target specified
; PCIWriteByte					Writes a byte value to the PCI target specified
; PCIWriteWord					Writes a word value to the PCI target specified
; PCIWriteDword					Writes a dword value to the PCI target specified



bits 32



PCICalculateNext:
	; Calculates the proper value of the next spot on the PCI bus
	;
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;
	;  output:
	;   next PCI Bus
	;	next PCI Device
	;	next PCI Function
	;
	;  changes: eax, ebx, ecx, edx

	pop eax
	pop ebx
	pop edx
	pop ecx

	; add one to the data before checking for possible adjustments
	inc ecx

	.FunctionCheck:
	cmp ecx, 7
	jbe .DeviceCheck

	; if we get here, adjustment is needed
	mov ecx, 0x00000000
	inc edx



	.DeviceCheck:
	cmp edx, 31
	jbe .BusCheck

	; if we get here, adjustment is needed
	mov edx, 0x00000000
	inc ebx



	.BusCheck:
	cmp ebx, 255
	jbe .Done

	; if we get here, adjustment is needed
	mov ebx, 0x0000FFFF
	mov edx, 0x0000FFFF
	mov ecx, 0x0000FFFF



	.Done:
	; throw the new values on the stack and exit
	push ebx
	push edx
	push ecx

	push eax
ret



PCICheckForFunction:
	; Checks the bus/device/function specified to see if there's something there
	;
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;
	;  output:
	;   result
	;		kTrue - function was found
	;		kFalse - function was not found
	;
	;  changes: eax, ebx, ecx, edx

	pop eax
	pop ebx
	pop edx
	pop ecx
	push eax

	; load the first register (vendor and device IDs) for this device
	push 0
	push ecx
	push edx
	push ebx
	call PCILiveRead
	pop eax

	; preset our result now
	mov ebx, dword [kFalse]

	; if the vendor ID is 0xFFFF, there's nothing here
	cmp ax, 0xFFFF
	je .Exit
		; if we get here, the device is valid
		mov ebx, dword [kTrue]
	.Exit:
	; the usual stack fixup and exit
	pop eax
	push ebx
	push eax
ret



PCIDetect:
	; Pokes the 32-bit I/O register at 0x0CF8 to see if there's a PCI controller there
	;
	;  input:
	;   n/a
	;
	;  output:
	;   PCI controller presence
	;		0 = false
	;		1 = true
	;
	;  changes: eax, ebx, ecx, edx

	pop ecx

	; write a vcalue to the port
	mov dx, [PCIAddressPort]
	mov eax, 0x19801988
	out dx, eax

	; clear eax for sanity and to give the previous write time to "settle in"
	mov eax, 0x00000000
	
	; read it back
	in eax, dx

	; now compare to see what we got
	cmp eax, 0x19801988
	je .ItMatched
	push dword [kFalse]
	jmp .AllDone

	.ItMatched:
	push dword [kTrue]

	.AllDone:
	push ecx
ret



PCIDriverSearch:
	; Scans all the drivers in the kernel to see if any match the class/subclass/progif given
	;
	;  input:
	;   PCI Class value
	;   PCI Subclass value
	;   PCI ProgIf value
	;
	;  output:
	;   Match code
	;
	;  changes: eax, ebx, ecx, edx

	pop eax
	pop dword [.PCIBus]
	pop dword [.PCIDevice]
	pop dword [.PCIFunction]
	push eax

jmp $
	; push the return value on the stack and exit
	pop eax
	push ebx
	push eax
ret
.PCIBus											dd 0x00000000
.PCIDevice										dd 0x00000000
.PCIFunction									dd 0x00000000



PCIGetFunctionCount:
	; Returns the total number of functions across all PCI busses in the system
	;
	;  input:
	;   n/a
	;
	;  output:
	;   PCI device count
	;
	;  changes: eax, ebx, ecx, dx, edi

	; init the bus (ebx), device (edx), and function (ecx) values
	mov dword [.PCIBus], 0
	mov dword [.PCIDevice], 0
	mov dword [.PCIFunction], 0

	; start the scanning loop
	.ScanLoop:
	push dword [.PCIFunction]
	push dword [.PCIDevice]
	push dword [.PCIBus]
	call PCICheckForFunction
	pop eax

	; check to see if anything was there
	cmp eax, [kTrue]
	jne .NothingFound

	; if we get here, something was found, so increment the counter
	inc dword [.PCIDeviceCount]

	.NothingFound:

	; increment to the next function slot
	push dword [.PCIFunction]
	push dword [.PCIDevice]
	push dword [.PCIBus]
	call PCICalculateNext
	pop dword [.PCIFunction]
	pop dword [.PCIDevice]
	pop dword [.PCIBus]

	; add all the values together to be tested
	mov eax, dword [.PCIBus]
	add eax, dword [.PCIDevice]
	add eax, dword [.PCIFunction]

	; see if we're done, loop again if not
	cmp eax, 0x0002FFFD
	jne .ScanLoop

	; and we exit!
	pop eax
	push dword [.PCIDeviceCount]
	push eax
ret
.PCIBus											dd 0x00000000
.PCIDevice										dd 0x00000000
.PCIFunction									dd 0x00000000
.PCIDeviceCount									dd 0x00000000



PCIGetNextFunction:
	; Starts a scans at the bus/device/function specified to find the next function in order
	;
	;  input:
	;   starting PCI Bus
	;	starting PCI Device
	;	starting PCI Function
	;
	;  output:
	;   next occupied PCI Bus
	;	next occupied PCI Device
	;	next occupied PCI Function
	;
	;  changes: eax, ebx, ecx, dx, edi

	; init the bus (ebx), device (edx), and function (ecx) values
	pop eax
	pop dword [.PCIBus]
	pop dword [.PCIDevice]
	pop dword [.PCIFunction]
	push eax

	; start the scanning loop
	.ScanLoop:
	push dword [.PCIFunction]
	push dword [.PCIDevice]
	push dword [.PCIBus]
	call PCICheckForFunction
	pop eax

	; check to see if anything was there
	cmp eax, [kFalse]
	je .NothingFound
	
	; if we get here, something was found
	jmp .Exit

	.NothingFound:
	; if we get here, nothing was found, so we keep scanning
	; increment to the next function slot
	push dword [.PCIFunction]
	push dword [.PCIDevice]
	push dword [.PCIBus]
	call PCICalculateNext
	pop dword [.PCIFunction]
	pop dword [.PCIDevice]
	pop dword [.PCIBus]

	; add all the values together to be tested
	mov eax, dword [.PCIBus]
	add eax, dword [.PCIDevice]
	add eax, dword [.PCIFunction]

	; see if we're done, loop again if not
	cmp eax, 0x0002FFFD
	jne .ScanLoop

	.Exit:
	; and we exit!
	pop eax
	push dword [.PCIBus]
	push dword [.PCIDevice]
	push dword [.PCIFunction]
	push eax
ret
.PCIBus											dd 0x00000000
.PCIDevice										dd 0x00000000
.PCIFunction									dd 0x00000000



PCIInitBus:
	; Scans all PCI busses and shadows all data to a List Manager list
	;
	;  input:
	;   n/a
	;
	;  output:
	;   address in RAM of PCI list
	;
	;  changes: 

	; see how many PCI functions we have
	call PCIGetFunctionCount
	pop dword [tSystem.PCIDeviceCount]

	; create a list with that many entries of 268 bytes each
	push 268
	push dword [tSystem.PCIDeviceCount]
	call LMListNew
	pop eax
	mov dword [tSystem.PCITableAddress], eax

	call PrintRegs32

	; add a check here to make sure we didn't get a null address

	; cycle through all busses and devices on those busses, copying all registers into RAM
	mov dword [.PCIBus], 0
	mov dword [.PCIDevice], 0
	mov dword [.PCIFunction], 0
	mov dword [.currentElement], 0

	.FunctionLoop:
		push dword [.PCIFunction]
		push dword [.PCIDevice]
		push dword [.PCIBus]
		call PCIGetNextFunction
		pop dword [.PCIFunction]
		pop dword [.PCIDevice]
		pop dword [.PCIBus]

		; see if we're done yet
		mov eax, dword [.PCIBus]
		add eax, dword [.PCIDevice]
		add eax, dword [.PCIFunction]
		cmp eax, 0x0002FFFD
		je .LoopDone

		; now that we have a valid device, let's copy all the registers

		; set up the target address
		push dword [.currentElement]
		push dword [tSystem.PCITableAddress]
		call LMItemGetAddress
		pop esi

		; copy PCI bus location info to the table
		mov eax, [.PCIBus]
		mov [esi], eax
		add esi, 4

		mov eax, [.PCIDevice]
		mov [esi], eax
		add esi, 4

		mov eax, [.PCIFunction]
		mov [esi], eax
		add esi, 4

		; set the number of PCI register reads we need to do
		mov ecx, 64
		mov edx, 0

		; start the loop to copy all the info
		.ReadLoop:
			; save important stuff
			push esi
			push ecx
			push edx

			; adjust ecx to point to the correct PCI register
			dec ecx

			; get the register
			push edx
			push dword [.PCIFunction]
			push dword [.PCIDevice]
			push dword [.PCIBus]
			call PCILiveRead
			pop eax

			; restore important stuff
			pop edx
			pop ecx
			pop esi

			; write the register to the struct and increment destination
			mov [esi], eax

			; adjust the destination address and register counter
			inc edx
			add esi, 4

		loop .ReadLoop

		; advance to the next slot
		push dword [.PCIFunction]
		push dword [.PCIDevice]
		push dword [.PCIBus]
		call PCICalculateNext
		pop dword [.PCIFunction]
		pop dword [.PCIDevice]
		pop dword [.PCIBus]

		; move to the next element
		inc dword [.currentElement]

	jmp .FunctionLoop

	.LoopDone:
ret
.PCIBus											dd 0x00000000
.PCIDevice										dd 0x00000000
.PCIFunction									dd 0x00000000
.currentElement									dd 0x00000000



PCILiveRead:
	; Reads a 32-bit register value from the PCI target specified
	; Note: This function reads directly from the PCI bus, not from the shadowed PCI data in RAM
	;
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;
	;  output:
	;   register value
	;
	;  changes: eax, ebx, dx, edi

	pop edi

	; we start by building a value out of the bus, device, function and register values provided
	mov eax, 0x00000000							; clear the destination
	pop ebx										; load the PCI bus provided
	and ebx, 0x000000FF							; PCI registers are 8 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 5									; shift left 5 bits to get ready for the next section

	pop ebx										; load the PCI device provided
	and ebx, 0x0000001F							; PCI devices are 5 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 3									; shift left 3 bits to get ready for the next section

	pop ebx										; load the PCI function provided
	and ebx, 0x00000007							; PCI functions are 3 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 6									; shift left 6 bits to get ready for the next section

	pop ebx										; load the PCI registers provided
	and ebx, 0x0000003F							; PCI registers are 6 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 2									; shift left 2 bits to finalize and align

	or eax, 0x80000000							; set bit 31 to enable configuration

	; write the value we just built to select the proper target
	mov dx, [PCIAddressPort]
	out dx, eax

	; read the register back
	mov dx, [PCIDataPort]
	in eax, dx

	;push the result
	push eax

	; restore the return address
	push edi
ret



PCILiveWrite:
	; Writes a 32-bit value to the target PCI register specified
	;
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;	value to write
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, dx, edi

	pop edi

	; we start by building a value out of the bus, device, function and register values provided
	mov eax, 0x00000000							; clear the destination
	pop ebx										; load the PCI bus provided
	and ebx, 0x000000FF							; PCI registers are 8 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 5									; shift left 5 bits to get ready for the next section

	pop ebx										; load the PCI device provided
	and ebx, 0x0000001F							; PCI devices are 5 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 3									; shift left 3 bits to get ready for the next section

	pop ebx										; load the PCI function provided
	and ebx, 0x00000007							; PCI functions are 3 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 6									; shift left 6 bits to get ready for the next section

	pop ebx										; load the PCI registers provided
	and ebx, 0x0000003F							; PCI registers are 6 bits, so make sure it's in range
	or eax, ebx									; copy the bits into our destination
	shl eax, 2									; shift left 2 bits to finalize and align

	or eax, 0x80000000							; set bit 31 to enable configuration

	; write the value we just built to select the proper target
	mov dx, [PCIAddressPort]
	out dx, eax

	; get the value to write from the stack
	pop eax

	; write the data register
	mov dx, [PCIDataPort]
	out dx, eax

	; restore the return address
	push edi
ret



PCILoadDrivers:
	; Cycles through all functions in the PCI list and loads drivers for each
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: 
	; 

	; first get the number of elements in the PCI list
	push dword [tSystem.PCITableAddress]
	call LMListGetElementCount
	pop eax


;		; now that we have a valid device, let's copy all the registers
;		pusha
;
;		; maybe make these three separate routines in the future for handiness?
;		; get the class, subclass, and progif values for this device so we can search for a suitable driver
;		push dword 0x00000002
;		push dword [.PCIFunction]
;		push dword [.PCIDevice]
;		push dword [.PCIBus]
;		call PCIReadDWord
;		pop eax
;
;		; juggle the bytes here to transfer the proper data into our variables
;		shr eax, 8
;		mov ebx, eax
;		and ebx, 0x000000FF
;		mov dword [.PCIProgIf], ebx
;
;		shr eax, 8
;		mov ebx, eax
;		and ebx, 0x000000FF
;		mov dword [.PCISubclass], ebx
;
;		shr eax, 8
;		mov ebx, eax
;		and ebx, 0x000000FF
;		mov dword [.PCIClass], ebx
;
;		; search for precise driver first for this exact class/subclass/prog if 
;		push dword [.PCIFunction]
;		push dword [.PCIDevice]
;		push dword [.PCIBus]
;		call PCIDriverSearch
;		pop eax
;
;		; test the result of the search
;
;		; didn't find one, so search for a driver that handles the entire subclass (all prog if values)
;		push dword [.PCIFunction]
;		push dword [.PCIDevice]
;		push dword [.PCIBus]
;		call PCIDriverSearch
;		pop eax
;		; test the result of the search
;
;		; still nothing?!? ok, search for a driver for the entire class (all subclasses and prog if values)
;		push dword [.PCIFunction]
;		push dword [.PCIDevice]
;		push dword [.PCIBus]
;		call PCIDriverSearch
;		pop eax
;		; test the result of the search
;
;		; what?? ok, fine. there's just no driver in the kernel for this device
;
;		; restore the previous values
;		popa



	jmp $

ret
.PCIBus											dd 0x00000000
.PCIDevice										dd 0x00000000
.PCIFunction									dd 0x00000000
.PCIClass										dd 0x00000000
.PCISubclass									dd 0x00000000
.PCIProgIf										dd 0x00000000



PCIReadAll:
	; Gets all info for the specified PCI device and fills it into the struct at the given address
	;
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI info struct address
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, ecx, edx, esi, edi

	pop edi
	pop dword [.bus]
	pop dword [.device]
	pop dword [.function]
	pop esi
	push edi

	; set the number of reads we need to do
	mov ecx, 64

	; start the loop to copy all the info
	.ReadLoop:
		; adjust ecx to point to the correct PCI register
		dec ecx

		pusha

		; get the register
		push ecx
		push dword [.function]
		push dword [.device]
		push dword [.bus]
		call PCIReadDWord
		pop eax

		; fixup for eax
		mov [.temp], eax
		popa
		mov eax, [.temp]

		; calculate the write address
		mov edi, esi
		mov edx, ecx
		shl edx, 2
		add edi, edx

		; adjust ecx back to normal
		inc ecx

		; write the register to the struct
		mov [edi], eax

	loop .ReadLoop
ret
.bus											dd 0x00000000
.device											dd 0x00000000
.function										dd 0x00000000
.temp											dd 0x00000000



PCIReadByte:
	; Reads a byte register from the PCI target specified
	;
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;
	;  output:
	;   Register value
	;
	;  changes: 

	; scan the list for the proper device

ret



PCIReadWord:
	; Reads a word register from the PCI target specified
	;
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;
	;  output:
	;   Register value
	;
	;  changes: 

	; scan the list for the proper device

ret



PCIReadDWord:
	; Reads a dword register from the PCI target specified
	;
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;
	;  output:
	;   Register value
	;
	;  changes: 

	; get the data for what we're supposed to search for
	pop edx
	pop dword [.PCIBus]
	pop dword [.PCIDevice]
	pop dword [.PCIFunction]
	pop dword [.PCIRegister]
	push edx

	; scan the list for the proper device
	mov ecx, dword [tSystem.PCITableAddress]
	add ecx, 20

	.RegisterSearchLoop:
		; set the check flag for the following tests
		mov eax, 0x00000000

		; read the next dword from the table
		mov edx, [ecx]

		; see if it's an invalid bus
		cmp edx, 0xFFFFFFFF
		je .PCISearchExit

		; see if we have a match
		cmp edx, [.PCIBus]
		je .PCISearchSkip1

		; if we get here, it wasn't a match, so we adjust the flag register
		or eax, 00000000000000000000000000000001b
		.PCISearchSkip1:



		; increment ecx to check the next number
		add ecx, 4

		; read the next dword from the table
		mov edx, [ecx]

		; see if it's an invalid device
		cmp edx, 0xFFFFFFFF
		je .PCISearchExit

		; see if we have a match
		cmp edx, [.PCIDevice]
		je .PCISearchSkip2

		; if we get here, it wasn't a match, so we adjust the flag register
		or eax, 00000000000000000000000000000010b
		.PCISearchSkip2:



		; increment ecx to check the next number
		add ecx, 4

		; read the next dword from the table
		mov edx, [ecx]

		; see if it's an invalid function
		cmp edx, 0xFFFFFFFF
		je .PCISearchExit

		; see if we have a match
		cmp edx, [.PCIFunction]
		je .PCISearchSkip3

		; if we get here, it wasn't a match, so we adjust the flag register
		or eax, 00000000000000000000000000000100b
		.PCISearchSkip3:



		; check the result of the previous tests
		cmp eax, 0x00000000
		jne .PCISearchNoMatch


		; if we get here, it's a match
		; adjust ecx to point to first register
		add ecx, 4

		; adjust ecx to point to the specific register requested
		mov edx, dword [.PCIRegister]

		; multiply the register by 4 to mimic how the real PCI system handles register numbers
		rol edx, 2

		; truncate edx for safety
		and edx, 0xFF

		; add the register offset to the table address to pinpoint the register we need
		add ecx, edx

		; load the register data
		mov edx, [ecx]

		; we got the register value in edx, so we can exit
		jmp .PCISearchExit



		.PCISearchNoMatch:
		; adjust the ecx pointer to the next device in the table
		add ecx, 260

	jmp .RegisterSearchLoop

	.PCISearchExit:

	; fixup the return value and exit
	pop ecx
	push edx
	push ecx
ret
.PCIBus											dd 0x00000000
.PCIDevice										dd 0x00000000
.PCIFunction									dd 0x00000000
.PCIRegister									dd 0x00000000



PCIWriteByte:
	; Writes a byte value to the PCI target specified
	;
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;	Register value
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, dx, edi
ret



PCIWriteWord:
	; Writes a word value to the PCI target specified
	;
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;	Register value
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, dx, edi
ret



PCIWriteDword:
	; Writes a dword value to the PCI target specified
	;
	;  input:
	;   PCI Bus
	;	PCI Device
	;	PCI Function
	;	PCI Register
	;	Register value
	;
	;  output:
	;   n/a
	;
	;  changes: eax, ebx, dx, edi
ret



; for PCI bus access
PCIAddressPort									dw 0x0CF8
PCIDataPort										dw 0x0CFC
