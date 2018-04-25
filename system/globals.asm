; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; globals.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



; vars 'n' such
kTrue											dd 0x00000001
kFalse											dd 0x00000000
kCRLF											db 0x0d, 0x0a, 0x00
kHexDigits										db '0123456789ABCDEF'
kKeyBufferWrite									db 0x00
kKeyBufferRead									db 0x00
kKeyBuffer										times 256 db 0x00
kSadThing$										db 0x27, 'Tis a sad thing that your process has ended here!', 0x00
kPrintText$										times 256 db 0x00



; structures
tSystem:
	.versionMajor								dw 0x0000
	.versionMinor								dw 0x000E
	.copyright$									db 'Night Kernel, copyright 1995 - 2018', 0x00
	.memoryTotalKB								dd 0x00000000
	.memoryAvailableKB							dd 0x00000000
	.memoryBlockPointer							dd 0x00000000
	.hours										db 0x00
	.minutes									db 0x00
	.seconds									db 0x00
	.ticks										db 0x00
	.century									db 0x00
	.year										db 0x00
	.month										db 0x00
	.day										db 0x00
	.secondsSinceBoot							dd 0x00000000
	.ticksSinceBoot								dd 0x00000000
	.delayValue									dd 0x00000000
	.lastError									dd 0x00000000
	.keyboardType								dw 0x0000
	.PCITableAddress							dd 0x00000000				; will be zero if no PCI support
	.PCIDeviceCount								dd 0x00000000
	.multicoreAvailable							db 0x00
	.CPUIDVendor$								times 16 db 0x00
	.CPUIDBrand$								times 64 db 0x00
	.CPUIDLargestBasicQuery						dd 0x00000000
	.CPUIDLargestExtendedQuery					dd 0x00000000
	.APMVersionMajor							db 0x00
	.APMVersionMinor							db 0x00
	.APMFeatures								dw 0x0000
	.VESAVersionMajor							db 0x00
	.VESAVersionMinor							db 0x00
	.VESAOEMStringPointer						dd 0x00000000
	.VESACapabilities							dd 0x00000000
	.VESAWidth									dw 0x0000
	.VESAHeight									dw 0x0000
	.VESAColorDepth								db 0x00
	.VESAVideoRAMKB								dd 0x00000000
	.VESAOEMSoftwareRevision					dw 0x0000
	.VESAOEMVendorNamePointer					dd 0x00000000
	.VESAOEMProductNamePointer					dd 0x00000000
	.VESAOEMProductRevisionPointer				dd 0x00000000
	.VESAOEMDataStringsPointer					dd 0x00000000
	.VESALFBAddress								dd 0x00000000
	.mouseAvailable								db 0x00
	.mouseButtonCount							db 0x00
	.mouseID									db 0x00
	.mouseWheelPresent							db 0x00
	.mouseButtons								db 0x00
	.mouseX										dw 0x0000
	.mouseY										dw 0x0000
	.mouseZ										dw 0x0000
	.mousePacketByteSize						db 0x00
	.mousePacketByteCount						db 0x00
	.mousePacketByte1							db 0x00
	.mousePacketByte2							db 0x00
	.mousePacketByte3							db 0x00
	.mousePacketByte4							db 0x00
	.configBitsHint$							db 'ConfigBits'
	.configBits									dd 0x00000002

tVESAInfoBlock:
	.VBESignature$								db 'VBE2'
	.VBEVersionMinor							db 0x00
	.VBEVersionMajor							db 0x00
	.OEMStringOffset							dw 0x0000
	.OEMStringSegment							dw 0x0000
	.Capabilities								times 4 db 0x00
	.VideoModeListOffset						dw 0x0000
	.VideoModeListSegment						dw 0x0000
	.TotalMemory								dw 0x0000
	.OEMSoftwareRev								dw 0x0000
	.OEMVendorNameOffset						dw 0x0000
	.OEMVendorNameSegment						dw 0x0000
	.OEMProductNameOffset						dw 0x0000
	.OEMProductNameSegment						dw 0x0000
	.OEMProductRevOffset						dw 0x0000
	.OEMProductRevSegment						dw 0x0000
	.Reserved									times 222 db 0x00
	.OEMData									times 256 db 0x00

tVESAModeInfo:
	.ModeAttributes								dw 0x0000
	.WinAAttributes								db 0x00
	.WinBAttributes								db 0x00
	.WinGranularity								dw 0x0000
	.WinSize									dw 0x0000
	.WinASegment								dw 0x0000
	.WinBSegment								dw 0x0000
	.WinFuncPtr									dd 0x00000000
	.BytesPerScanline							dw 0x0000
	.XResolution								dw 0x0000
	.YResolution								dw 0x0000
	.XCharSize									db 0x00
	.YCharSize									db 0x00
	.NumberOfPlanes								db 0x00
	.BitsPerPixel								db 0x00
	.NumberOfBanks								db 0x00
	.MemoryModel								db 0x00
	.BankSize									db 0x00
	.NumberOfImagePages							db 0x00
	.ReservedA									db 0x00
	.RedMaskSize								db 0x00
	.RedFieldPosition							db 0x00
	.GreenMaskSize								db 0x00
	.GreenFieldPosition							db 0x00
	.BlueMaskSize								db 0x00
	.BlueFieldPosition							db 0x00
	.RsvdMaskSize								db 0x00
	.RsvdFieldPosition							db 0x00
	.DirectColorModeInfo						db 0x00
	.PhysBasePtr								dd 0x00000000
	.OffScreenMemOffset							dd 0x00000000
	.OffScreenMemSize							dw 0x0000
	.ReservedB									times 206 db 0x00

tMBR:
	.BootCode									times 446 db 0x00
	.Partiton1Status							db 0x00
	.Partition1FirstSectorCHS					db 0x00, 0x00, 0x00
	.Partition1Type								db 0x00
	.Partition1LastSectorCHS					db 0x00, 0x00, 0x00
	.Partition1FirstSectorLBA					dd 0x00000000
	.Partition1SectorCount						dd 0x00000000
	.Partition2Status							db 0x00
	.Partition2FirstSectorCHS					db 0x00, 0x00, 0x00
	.Partition2Type								db 0x00
	.Partition2LastSectorCHS					db 0x00, 0x00, 0x00
	.Partition2FirstSectorLBA					dd 0x00000000
	.Partition2SectorCount						dd 0x00000000
	.Partition3Status							db 0x00
	.Partition3FirstSectorCHS					db 0x00, 0x00, 0x00
	.Partition3Type								db 0x00
	.Partition3LastSectorCHS					db 0x00, 0x00, 0x00
	.Partition3FirstSectorLBA					dd 0x00000000
	.Partition3SectorCount						dd 0x00000000
	.Partition4Status							db 0x00
	.Partition4FirstSectorCHS					db 0x00, 0x00, 0x00
	.Partition4Type								db 0x00
	.Partition4LastSectorCHS					db 0x00, 0x00, 0x00
	.Partition4FirstSectorLBA					dd 0x00000000
	.Partition4SectorCount						dd 0x00000000
	.Signature									db 0x55, 0xAA

tFAT16BootSector:
	.JumpOpcode									db 0x00, 0x00, 0x00
	.OEMName$									times 8 db 0x00
	.BytesPerSector								dw 0x0000
	.SectorsPerCluster							db 0x00
	.ReservedSectors							dw 0x0000
	.FATCount									db 0x00
	.MaxRootEntries								dw 0x0000
	.TotalSectors								dw 0x0000
	.MediaDescriptor							db 0x00
	.SectorsPerFAT								dw 0x0000
	.SectorsPerTrack							dw 0x0000
	.HeadCount									dw 0x0000
	.HiddenSectors								dd 0x00000000
	.TotalSectorsAndHidden						dw 0x00000000
	.PhysicalDriveNumber						db 0x00
	.Reserved									db 0x00
	.ExtendedSignature							db 0x00
	.VolumeSerial								dd 0x00000000
	.PartitionVolumeLabel$						times 11 db 0x00
	.FileSystemType$							times 8 db 0x00
	.BootCode									times 448 db 0x00
	.Signature									db 0x55, 0xAA



; arrays
kKeyTable:										db '  1234567890-=  qwertyuiop[]  asdfghjkl; ` \zxcvbnm,0/ *               789-456+1230.  '



tEvent:



; random kernel infos follow...



; Memory Map
; Start				End				Size						Description
; 0x00000000		0x000003FF		1 KB						interrupt vector table
; 0x00000400		0x000004FF		256 bytes					BIOS data area (remapped here from CMOS)
; 0x00000500		0x000005FF		256 bytes					unused
; 0x00000600		0x00007BFF		30207 bytes (29.49 KB)		kernel space (kernel is loaded here by freeDOS bootloader)
; 0x00007C00		0x00007DFF		512 bytes					bootloader (copied here by BIOS, can be overwritten)
; 0x00007E00		0x0008F7FF		555520 bytes (542.50 KB)	available, unused
; 0x0008F800		0x0009F7FF		64 KB						IDT
; 0x0009F800		0x0009FBFF		1 KB						stack
; 0x0009FC00		0x0009FFFF		1 KB						extended BIOS data area
; 0x000A0000		0x000AFFFF		64 KB						video buffer for EGA/VGA graphics modes
; 0x000B0000		0x000B7FFF		32 KB						video buffer for EGA/VGA graphics modes
; 0x000B8000		0x000BFFFF		32 KB						video buffer for color text and CGA graphics
; 0x000C0000		0x000DFFFF		128 KB						device-mounted ROMs
; 0x000E0000		0x0010FFEF		196591 bytes (191.98 KB)	BIOS ROM
; 0x0010FFF0		0x001FFFFF		983055 bytes (960.01 KB)    applications use
; 0x00200000		0xFFFFFFFF		?							application use



; Result Codes
; 0xF000			Success, no error
; 0xF001			Value specified is too low
; 0xF002			Value specified is too high
; 0xFF00			PS2 Controller write command timeout
; 0xFF01			PS2 Controller write data timeout
; 0xFF02			PS2 Controller read data timeout



; ConfigBits options
; 0					Show boot logo
; 1					Play startup sound
; 2					Enable debugging menu
; 3					reserved
; 4					reserved
; 5					reserved
; 6					reserved
; 7					reserved
; 8					reserved
; 9					reserved
; 10				reserved
; 11				reserved
; 12				reserved
; 13				reserved
; 14				reserved
; 15				reserved
; 16				reserved
; 17				reserved
; 18				reserved
; 19				reserved
; 20				reserved
; 21				reserved
; 22				reserved
; 23				reserved
; 24				reserved
; 25				reserved
; 26				reserved
; 27				reserved
; 28				reserved
; 29				reserved
; 30				reserved
; 31				reserved



; Event Codes
; Note - Event codes 80 - FF are reserved for software and interprocess communication
; 00				Null (nothing is waiting in the queue)
; 01				Key down
; 02				Key up
; 03				Mouse move
; 04				Mouse button down
; 05				Mouse button up
; 06				Mouse wheel move
; 20				Serial input received
; 40				Application is losing focus
; 41				Application is gaining focus
