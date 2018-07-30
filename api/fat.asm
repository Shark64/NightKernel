; Night Kernel
; Copyright 1995 - 2018 by mercury0x0d
; FAT.asm is a part of the Night Kernel

; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.



; 32-bit function listing:



bits 32



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
