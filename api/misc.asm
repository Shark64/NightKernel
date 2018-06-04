; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; api.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



; Miscellaneous routines which will eventually comprise the Night API
bits 16



SetSystemAPM:
	; Gets the APM interface version and saves results to the tSystem structure
	;
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
	mov byte [tSystem.APMVersionMajor], ah
	mov byte [tSystem.APMVersionMinor], al
	mov word [tSystem.APMFeatures], cx
	.skipped:
ret



bits 32



CRC32:
	; Generates a CRC-32/JAMCRC checksum for the memory block specified
	; Algorithm extracted from "All PDS/QuickBASIC 4.5 CRC-32 Routine" by Rich Geldreich, 1992
	;
	;  input:
	;   memory block address
	;	length of memory block
	;	CRC seed value
	;
	;  output:
	;   CRC checksum
	;
	;  changes: eax, ebx, ecx, edx, esi

	pop esi
	pop dword [.blockAddress]
	pop dword [.length]
	pop dword [.CRCChecksum]

	; set up a loop to go from 1 to length AND 3
	mov ecx, dword [.length]
	and ecx, 3

	; make sure the loop doesn't execute if ecx = 0
	cmp ecx, 0
	je .SkipLoop

	.CRCLoop:
		call .CRCCalc

		; increment our address
		inc dword [.blockAddress]

	loop .CRCLoop
	.SkipLoop:
	
	; round length down to the next lowest multiple of 4
	mov eax, 0xFFFFFFFC
	and dword [.length], eax

	jmp .lengthTest

	.CalcLoop:
		call .CRCCalc

		; increment our address
		inc dword [.blockAddress]

		; decrement the length
		dec dword [.length]

	.lengthTest:
		cmp dword [.length], 0
		jne .CalcLoop

	push dword [.CRCChecksum]
	push esi
ret

.CRCCalc:
	; AND the CRCChecksum with 0xFF
	mov eax, [.CRCChecksum]
	and eax, 0x000000FF

	; load ebx with the byte at blockAddress
	mov ebx, [.blockAddress]
	mov bl, byte [ebx]
	and ebx, 0x000000FF

	; XOR eax with ebx
	xor eax, ebx

	; load edx with the value from the poly table specified by eax
	; eax is multiplied by 4 (using the shift trick) to point to the right value
	mov edx, .PolynomialTable
	shl eax, 2
	add eax, edx
	mov edx, [eax]

 	; AND the CRCChecksum with 0xFFFFFF00
	mov eax, [.CRCChecksum]
	and eax, 0xFFFFFF00

	; divide eax by 256 using the good ol' shift trick and save the result to ebx
	mov ebx, eax
	shr ebx, 8

	; get rid of the upper two bits of ebx by ANDing it with 0x00FFFFFF
	and ebx, 0x00FFFFFF

	; XOR edx with ebx
	xor edx, ebx

	; load edx into CRCChecksum
	mov [.CRCChecksum], edx
ret

.blockAddress									dd 0x00000000
.length											dd 0x00000000
.CRCChecksum									dd 0x00000000

.PolynomialTable:
dd 0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F, 0xE963A535, 0x9E6495A3
dd 0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988, 0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91
dd 0x1DB71064, 0x6AB020F2, 0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7
dd 0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9, 0xFA0F3D63, 0x8D080DF5
dd 0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172, 0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B
dd 0x35B5A8FA, 0x42B2986C, 0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59
dd 0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423, 0xCFBA9599, 0xB8BDA50F
dd 0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924, 0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D
dd 0x76DC4190, 0x01DB7106, 0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433
dd 0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D, 0x91646C97, 0xE6635C01
dd 0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E, 0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457
dd 0x65B0D9C6, 0x12B7E950, 0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65
dd 0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, 0x3DD895D7, 0xA4D1C46D, 0xD3D6F4FB
dd 0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0, 0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9
dd 0x5005713C, 0x270241AA, 0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F
dd 0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81, 0xB7BD5C3B, 0xC0BA6CAD
dd 0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A, 0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683
dd 0xE3630B12, 0x94643B84, 0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1
dd 0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB, 0x196C3671, 0x6E6B06E7
dd 0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC, 0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5
dd 0xD6D6A3E8, 0xA1D1937E, 0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B
dd 0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55, 0x316E8EEF, 0x4669BE79
dd 0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236, 0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F
dd 0xC5BA3BBE, 0xB2BD0B28, 0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D
dd 0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F, 0x72076785, 0x05005713
dd 0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38, 0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21
dd 0x86D3D2D4, 0xF1D4E242, 0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777
dd 0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69, 0x616BFFD3, 0x166CCF45
dd 0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2, 0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB
dd 0xAED16A4A, 0xD9D65ADC, 0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9
dd 0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD70693, 0x54DE5729, 0x23D967BF
dd 0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94, 0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D



PrintSerial:
	; Prints an ASCIIZ string as a series of characters to serial port 1
	; Note: primarily for debugging
	;
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

		mov cl, [tSystem.ticks]
		.timerloop:
			mov ch, [tSystem.ticks]
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



SetSystemCPUID:
	; Probes the CPU using CPUID instruction and saves results to the tSystem structure
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a

	; get vendor ID
	mov eax, 0x00000000
	cpuid
	mov esi, tSystem.CPUIDVendor$
	mov [tSystem.CPUIDLargestBasicQuery], eax
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
	mov [tSystem.CPUIDLargestExtendedQuery], eax

	mov eax, 0x80000002
	cpuid
	mov esi, tSystem.CPUIDBrand$
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



SetSystemCPUSpeed:
	; Writes CPU speed info to the tSystem structure
	;
	;  input:
	;   n/a
	;
	;  output:
	;   n/a
	;
	;  changes: eax

	; save the flags
	pushf

	; make sure interrupts are on so we have a timer to use
	sti
	
	; check the speed
	call CPUSpeedDetect
	pop eax
	mov [tSystem.delayValue], eax
	
	; restore the flags and exit
	popf
ret



SetSystemRTC:
	; Copies the RTC time and date into the tSystem structure
	;
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
	mov byte [tSystem.century], al
	
	; get the year
	mov al, 0x09
	out 0x70, al
	mov eax, 0x00000000
	in al, 0x71
	mov byte [tSystem.year], al
	
	; get the month
	mov al, 0x08
	out 0x70, al
	mov eax, 0x00000000
	in al, 0x71
	mov byte [tSystem.month], al
	
	; get the day
	mov al, 0x07
	out 0x70, al
	mov eax, 0x00000000
	in al, 0x71
	mov byte [tSystem.day], al
	
	; get the hour
	mov al, 0x04
	out 0x70, al
	mov eax, 0x00000000
	in al, 0x71
	mov byte [tSystem.hours], al
	
	; get the minutes
	mov al, 0x02
	out 0x70, al
	mov eax, 0x00000000
	in al, 0x71
	mov byte [tSystem.minutes], al
	
	; get the seconds
	mov al, 0x00
	out 0x70, al
	mov eax, 0x00000000
	in al, 0x71
	mov byte [tSystem.seconds], al
ret



TimerWait:
	; Waits the specified number of ticks
	;
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
		mov dl, [tSystem.ticks]
		mov dh, dl

		.timerLoop:
			mov dl, [tSystem.ticks]
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
