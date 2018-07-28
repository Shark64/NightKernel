; Night Kernel
; Copyright 1995 - 2018 by mercury0x0d
; floppy.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



; 32-bit function listing:
; LegacyFloppyDriverInit				Performs any necessary setup of the driver
; LegacyFloppyControllerCommandSend		Sends a command to the floppy controller
; LegacyFloppyControllerDataRead		Reads a data byte from the floppy controller
; LegacyFloppyControllerDataWrite		Writes a data byte to the floppy controller
; LegacyFloppyControllerRecalibrate		Recalibrates the floppy controller
; LegacyFloppyControllerReset			Resets the floppy controller
; LegacyFloppyDetect					Detects which floppy drives are active in the system and sets the bits accordingly
; LegacyFloppyInterruptHandler			Interrupt handler for floppy interrupts
; LegacyFloppyLBAToCHS					Interrupt handler for ATA interrupts
; LegacyFloppyMotorOff					Turns off the drive motor
; LegacyFloppyMotorOn					Turns on the drive motor
; LegacyFloppySectorRead				Reads sectors from disk
; LegacyFloppySectorSeek				Seeks the floppy heads to the sector specified
; LegacyFloppyWaitInterrupt				Waits until the floppy controller interrupt is called
; LegacyFloppyWaitReady					Waits until bit 7 is set and bit 6 is clear on the floppy controller port



bits 32



; defines
%define kFloppyCommandReadTrack					0x02	; generates IRQ6
%define kFloppyCommandSpecify					0x03	; set drive parameters
%define kFloppyCommandSenseDriveStatus			0x04
%define kFloppyCommandWriteData					0x05	; write to the disk
%define kFloppyCommandReadData					0x06	; read from the disk
%define kFloppyCommandRecalibrate				0x07	; seek to cylinder 0
%define kFloppyCommandSenseInterrupt			0x08	; ack IRQ6, get status of last command
%define kFloppyCommandWriteDeletedData			0x09
%define kFloppyCommandReadID 					0x0A	; generates IRQ6
%define kFloppyCommandReadDeletedData			0x0C
%define kFloppyCommandFormatTrack				0x0D
%define kFloppyCommandDumpReg					0x0E
%define kFloppyCommandSeek						0x0F	; seek both heads to cylinder X
%define kFloppyCommandVersion					0x10	; used during initialization, once
%define kFloppyCommandScanEqual					0x11
%define kFloppyCommandPerpendicularMode 		0x12	; used during initialization, once, maybe
%define kFloppyCommandConfigure					0x13	; set controller parameters
%define kFloppyCommandLock						0x14	; protect controller params from a reset
%define kFloppyCommandVerify					0x16
%define kFloppyCommandScanLowOrEqual			0x19
%define kFloppyCommandScanHighOrEqual			0x1D

%define kFloppyRegisterStatusA					0x3F0	; read only
%define kFloppyRegisterStatusB					0x3F1	; read only
%define kFloppyRegisterDigitalOutput			0x3F2	; read/write
%define kFloppyRegisterTapeDrive				0x3F3	; read/write
%define kFloppyRegisterMainStatus				0x3F4	; read only
%define kFloppyRegisterDataRateSelect			0x3F4	; write only
%define	kFloppyRegisterDataFIFO					0x3F5	; read/write
%define	kFloppyRegisterDigitalInput				0x3F7	; read only
%define	kFloppyRegisterConfigControl			0x3F7	; write only



LegacyFloppyDriverHeader:
.signature$										db 'N', 0x01, 'g', 0x09, 'h', 0x09, 't', 0x05, 'D', 0x02, 'r', 0x00, 'v', 0x01, 'r', 0x05
.classMatch										dd 0x00000000							; meaningless for a legacy driver
.subclassMatch									dd 0x00000000							; meaningless for a legacy driver
.progIfMatch									dd 0x00000000							; meaningless for a legacy driver
.driverFlags									dd 10000000000000000000000000000000b	; flag for legacy driver
.ReadCodePointer								dd 0x00000000
.WriteCodePointer								dd 0x00000000



; due to the nature of the Night driver detection model, the driver init code must directly follow the header
LegacyFloppyDriverInit:
	; Performs any necessary setup of the driver
	;
	;  input:
	;   PCI Bus
	;   PCI Device
	;   PCI Function
	;   config info
	;
	;  output:
	;   driver response

	push ebp
	mov ebp, esp

	; announce ourselves!
	push .driverIntro$
	call PrintIfConfigBits32

	; check for primary floppy drive
	push 0
	call LegacyFloppyDetect
	pop eax

	; if we found something, announce it
	cmp eax, 0
	je .CheckDone

		; if we get here, we found a drive!
		; push the description string
		dec eax,
		mov edx, 14
		mul edx
		add eax, .driveCode01
		push eax

		; build the string
		push kPrintText$
		push .foundDrive$
		call StringBuild

		; print the string
		push kPrintText$
		call PrintIfConfigBits32

	.CheckDone:

	; get the floppy controller version
	push 0x10
	call LegacyFloppyControllerDataWrite

	push 0
	call LegacyFloppyControllerDataRead
	pop eax

	; error out if controller is not what we want
	cmp al, 0x90
	je .ControllerOK
		push .errorControllerBad
		call PrintIfConfigBits32
		mov eax, [kFalse]
		jmp .Exit
	.ControllerOK:
	mov eax, [kTrue]

	; set up the interrupt handler
	push 0x8e
	push LegacyFloppyInterruptHandler
	push 0x08
	push 0x26
	call InterruptHandlerSet

	; reset the controller
	push eax
	call LegacyFloppyControllerReset
	pop eax

	; recalibrate drive 0 (we don't care about the other drives)
	push 0
	call LegacyFloppyControllerRecalibrate

	; get the floppy controller version
	push 0x10
	call LegacyFloppyControllerDataWrite

	push 0
	call LegacyFloppyControllerDataRead
	pop eax

	.Exit:
	mov dword [ebp + 20], eax

	mov esp, ebp
	pop ebp
ret 12
.driverIntro$									db 'Legacy Floppy Drive Controller Driver, 2018 by mercury0x0d', 0x00
.foundDrive$									db 'Found ^s floppy drive', 0x00
.errorControllerBad								db 'No 82077AA controller found', 0x00
.driveCode01									db '360 KB, 5.25"', 0x00
.driveCode02									db '1.2 MB, 5.25"', 0x00
.driveCode03									db '720 KB, 3.5"', 0x00, 0x00
.driveCode04									db '1.44 MB, 3.5"', 0x00
.driveCode05									db '2.88 MB, 3.5"', 0x00



LegacyFloppyControllerCommandSend:
	; Sends a command to the floppy controller
	; Note: This function returns no result bytes, use LegacyFloppyControllerDataSend() for that
	; Can probably delete this function
	;
	;  input:
	;	command
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; read status
	; ensure bit 7 = 1 and bit 6 = 0
	call LegacyFloppyWaitReady

	; send the command byte
	mov edx, kFloppyRegisterDataFIFO
	mov eax, [ebp + 8]
	out dx, al

	mov esp, ebp
	pop ebp
ret 4



LegacyFloppyControllerDataRead:
	; Reads a data byte from the floppy controller
	;
	;  input:
	;	dummy value
	;
	;  output:
	;	data byte read

	push ebp
	mov ebp, esp

	; read status until bit 7 = 1 and bit 6 = 0 then send one byte
	; wait for the controller to be ready
	call LegacyFloppyWaitReady

	; get the byte
	mov edx, kFloppyRegisterDataFIFO
	in al, dx

	mov dword [ebp + 8], eax

	mov esp, ebp
	pop ebp
ret



LegacyFloppyControllerDataWrite:
	; Writes a data byte to the floppy controller
	;
	;  input:
	;	data byte to send
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; read status until bit 7 = 1 and bit 6 = 0 then send one byte
	; wait for the controller to be ready
	call LegacyFloppyWaitReady

	; send the byte
	mov edx, kFloppyRegisterDataFIFO
	mov eax, [ebp + 8]
	out dx, al

	mov esp, ebp
	pop ebp
ret 4



LegacyFloppyControllerRecalibrate:
	; Recalibrates the floppy controller
	;
	;  input:
	;	drive number
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; turn the floppy motor on
	push dword [ebp + 8]
	call LegacyFloppyMotorOn

	; write the command
	push kFloppyCommandRecalibrate
	call LegacyFloppyControllerDataWrite

	; write what drive
	push dword [ebp + 8]
	call LegacyFloppyControllerDataWrite

	; wait for ready
	call LegacyFloppyWaitInterrupt

	; sense interrupt
	push kFloppyCommandSenseInterrupt
	call LegacyFloppyControllerDataWrite

	push 0
	call LegacyFloppyControllerDataRead
	pop eax
	mov ebx, eax

	push 0
	call LegacyFloppyControllerDataRead
	pop eax

	; check for errors... they tell me that kind of thing is important...
	test bl, 00100000b
	jz .Error

	test al, 00010000b
	jnz .Error

	; if we get here, we can exit
	jmp .Exit

	.Error:
	; oh noes, there was an error!

	.Exit:
	mov esp, ebp
	pop ebp
ret 4



LegacyFloppyControllerReset:
	; Resets the floppy controller
	;
	;  input:
	;	n/a
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; set all drive motors off, disable IRQs/DMA, enter reset mode and select drive 0 for next command
	mov dx, kFloppyRegisterDigitalOutput
	mov al, 00000000b
	out dx, al

	; wait for ready
	call LegacyFloppyWaitReady

	; set 500 KiB/sec mode
	mov dx, kFloppyRegisterDigitalOutput
	mov al, 0
	out dx, al

	; leave all drive motors off, leave IRQs/DMA disabled, leave reset mode and select drive 0 for next command
	mov dx, kFloppyRegisterDigitalOutput
	mov al, 00001100b
	out dx, al

	; wait for ready
	call LegacyFloppyWaitInterrupt

	; dummy reads for floppy drive
	push kFloppyCommandSenseInterrupt
	call LegacyFloppyControllerDataWrite
	push 0
	call LegacyFloppyControllerDataRead
	pop eax
	push 0
	call LegacyFloppyControllerDataRead
	pop eax

	push kFloppyCommandSenseInterrupt
	call LegacyFloppyControllerDataWrite
	push 0
	call LegacyFloppyControllerDataRead
	pop eax
	push 0
	call LegacyFloppyControllerDataRead
	pop eax

	push kFloppyCommandSenseInterrupt
	call LegacyFloppyControllerDataWrite
	push 0
	call LegacyFloppyControllerDataRead
	pop eax
	push 0
	call LegacyFloppyControllerDataRead
	pop eax

	push kFloppyCommandSenseInterrupt
	call LegacyFloppyControllerDataWrite
	push 0
	call LegacyFloppyControllerDataRead
	pop eax
	push 0
	call LegacyFloppyControllerDataRead
	pop eax

	; stuff and things
	push kFloppyCommandSpecify
	call LegacyFloppyControllerDataWrite

	push 0xDF
	call LegacyFloppyControllerDataWrite

	push 0X02
	call LegacyFloppyControllerDataWrite

	mov esp, ebp
	pop ebp
ret



LegacyFloppyDetect:
	; Detects which floppy drives are active in the system and sets the bits accordingly
	;
	;  input:
	;	drive number of which to return description
	;	 0 - primary drive
	;	 1 - secondary drive
	;
	;  output:
	;	value describing the drive specified, or zero if it doesn't exist

	push ebp
	mov ebp, esp

	; exit if the drive number is out of range
	xor eax, eax
	mov ecx, [ebp + 8]
	cmp ecx, 1
	ja .Exit

	; get drive info from CMOS
	push 0x10
	call CMOSRead
	pop eax

	; swap the byte to properly place the data for each drive to work nicely with the rest of our algorithm
	ror al, 4

	; extract data from the returned value for the selected drive
	mov ecx, [ebp + 8]
	shl ecx, 2
	shr eax, cl

	; truncate potentially invalid data
	and eax, 0x0F

	.Exit:
	mov dword [ebp + 8], eax

	mov esp, ebp
	pop ebp
ret



LegacyFloppyInterruptHandler:
	; Interrupt handler for ATA interrupts
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a

	push ebp
	mov ebp, esp

	pusha
	pushf

	; make note that the interrupt fired
	mov byte [gLegacyFloppyInterruptHappened], 0x01

	; acknowledge the interrupt to the PIC
	call PICIntComplete

	popf
	popa

	mov esp, ebp
	pop ebp
iretd



LegacyFloppyLBAToCHS:
	; Interrupt handler for ATA interrupts
	;
	;  input:
	;   LBA value
	;
	;  output:
	;   dword containing chs in lower 3 bytes in that order

	push ebp
	mov ebp, esp

	mov eax, [ebp + 8]

	; make sure the LBA is valid
	mov ecx, 0xFFFFFFFF
	cmp eax, 2879
	ja .Exit

	; clear edx and ecx
	xor edx, edx
	xor ecx, ecx

	; divide by number of sectors per track
	mov bx, 18
	div bx
	
	inc dl

	; save the Sector value
	mov cl, dl
	
	; clear edx (again)
	xor edx, edx

	; divide by number of heads per track
	mov bx, 2
	div bx

	; save the Head value
	ror ecx, 8
	mov cl, dl

	; save the Cylinder value
	ror ecx, 8
	mov cl, al
	ror ecx, 16

	.Exit:
	; return the CHS value
	mov dword [ebp + 8], ecx

	mov esp, ebp
	pop ebp	
ret



LegacyFloppyMotorOff:
	; Turns off the drive motor
	;
	;  input:
	;	n/a
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	mov ecx, 0

	; get the register contents
	mov dx, kFloppyRegisterDigitalOutput
	in al, dx

	; clear the motor bit for drive 0
	mov bl, 11101111b
	and al, bl

	; write the register back
	out dx, al

	mov esp, ebp
	pop ebp
ret



LegacyFloppyMotorOn:
	; Turns on the drive motor
	;
	;  input:
	;	n/a
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; get the register contents
	mov dx, kFloppyRegisterDigitalOutput
	in al, dx

	; set the motor bit for drive 0
	mov bl, 00010000b
	or al, bl

	; write the register back
	out dx, al

	mov dword [ebp + 8], eax

	mov esp, ebp
	pop ebp
ret



LegacyFloppySectorRead:
	; Reads sectors from disk
	;
	;  input:
	;	LBA address of starting sector
	;	number of sectors to write
	;	memory buffer address to which data will be written
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; retrieve the LBA address
	; mov eax, [ebp + 8]

	; read status
	mov dx, kFloppyRegisterMainStatus
	in al, dx

	; set 500 KiB mode
	mov dx, kFloppyRegisterDigitalInput
	mov al, 0
	out dx, al



	mov ecx, 3
	.SeekLoop:
		push [ebp + 8]
		call LegacyFloppySectorSeek
	loop SeekLoop



	























	; RESTART POINT:::
	; ensure bit 7 = 1 and bit 6 = 0
	call LegacyFloppyWaitReady

	; send the command byte
	mov dx, kFloppyRegisterDataFIFO
	mov eax, kFloppyCommandSeek
	or eax, 11000000b
	out dx, al

	; wait for the controller to be ready
	call LegacyFloppyWaitReady

	; send a parameter byte
	mov dx, kFloppyRegisterMainStatus
	mov al, 0
	out dx, al

	; wait for the controller to be ready
	call LegacyFloppyWaitReady

	; send a parameter byte
	mov dx, kFloppyRegisterMainStatus
	mov al, 0
	out dx, al

	; wait for the controller to be ready
	call LegacyFloppyWaitReady

	; send a parameter byte
	mov dx, kFloppyRegisterMainStatus
	mov al, 0
	out dx, al

	; wait for the controller to be ready
	call LegacyFloppyWaitReady

	; send a parameter byte
	mov dx, kFloppyRegisterMainStatus
	mov al, 0
	out dx, al

	; wait for the controller to be ready
	call LegacyFloppyWaitReady

	; send a parameter byte
	mov dx, kFloppyRegisterMainStatus
	mov al, 0
	out dx, al

	; wait for the controller to be ready
	call LegacyFloppyWaitReady

	; send a parameter byte
	mov dx, kFloppyRegisterMainStatus
	mov al, 0
	out dx, al

	; wait for the controller to be ready
	call LegacyFloppyWaitReady

	; send a parameter byte
	mov dx, kFloppyRegisterMainStatus
	mov al, 0
	out dx, al

	; wait for the controller to be ready
	call LegacyFloppyWaitReady

	; send a parameter byte
	mov dx, kFloppyRegisterMainStatus
	mov al, 0
	out dx, al



	; read status, check if bit 5 = 1, if it is then we need to do a command execution phase, else skip to result phase
	mov dx, kFloppyRegisterMainStatus
	in al, dx
	test al, 00100000b
	jz .ResultPhase

	; execution phase:
	; poll bit 7 until = 1, or wait for int6
	.PollStatusLoop:
		mov dx, kFloppyRegisterMainStatus
		in al, dx
		and al, 10000000b
		cmp al, 0
	je .PollStatusLoop

	; transfer a byte out of fifo port, repeat while status register bit 7 = 1 and bit 5 = 1. if bit 5 = 1 loop back to beginning of main loop unless data buffer ran out ??

	.ResultPhase:
	; if the command doesn't have this phase, it will silently exit and wait for next command. else;
	; loop reading status until bit 7 = 1, then checek that bit 6 = 1

	; transfer a byte out of fifo port, repeat until status register bit 7 = 1 while verifying bit 6 = 1 and bit 4 = 1
	mov dx, kFloppyRegisterDataFIFO
	in al, dx
	mov ebx, eax

	; after all bytes have been retrieved, verify status bit 7 = 1 and 6 = 0 and bit 4 = 0, if they don't then start the command over from RESTART POINT:::
	mov dx, kFloppyRegisterMainStatus
	in al, dx


	.Exit:

	mov esp, ebp
	pop ebp
ret



LegacyFloppySectorSeek:
	; Seeks the floppy heads to the sector specified
	;
	;  input:
	;	LBA address of starting sector
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	; turn the motor on
	call LegacyFloppyMotorOn

	; send the command
	push kFloppyCommandSeek
	call LegacyFloppyControllerDataWrite

	; send the drive number
	push 0
	call LegacyFloppyControllerDataWrite

	; send the cylinder
	push 0
	call LegacyFloppyControllerDataWrite

	; wait for the controller interrupt
	call LegacyFloppyWaitInterrupt

	; acknowledge the interrupt on the controller
	push kFloppyCommandSenseInterrupt
	call LegacyFloppyControllerDataWrite
 
	push 0
	call LegacyFloppyControllerDataRead
	pop eax
	mov ebx, eax

	push 0
	call LegacyFloppyControllerDataRead
	pop eax

	; check for errors... they tell me that kind of thing is important...
	test bl, 00100000b
	jz .Error

	test al, 10000000b
	jnz .Error

	; if we get here, we can exit
	jmp .Exit

	.Error:
	; oh noes, there was an error!

	.Exit:
	mov esp, ebp
	pop ebp	
ret



LegacyFloppyWaitInterrupt:
	; Waits until the floppy controller interrupt is called
	;
	;  input:
	;	n/a
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	.WaitLoop:
		mov al, byte [gLegacyFloppyInterruptHappened]
		cmp al, 0x00
	je .WaitLoop

	; zero out the interrupt flag for next time
	mov byte [gLegacyFloppyInterruptHappened], 0x00

	mov esp, ebp
	pop ebp	
ret



LegacyFloppyWaitReady:
	; Waits until bit 7 is set and bit 6 is clear on the floppy controller port
	;
	;  input:
	;	n/a
	;
	;  output:
	;	n/a

	push ebp
	mov ebp, esp

	mov dx, kFloppyRegisterStatusA

	.WaitLoop:
		in al, dx
		test al, 10000000b
	jz .WaitLoop

	mov esp, ebp
	pop ebp	
ret



gLegacyFloppyInterruptHappened					db 0x00
