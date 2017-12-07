; Night Kernel
; Copyright 1995 - 2018 by mercury0x000d
; pci.asm is a part of the Night Kernel

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



;// for PCI bus access
;#define PCIAddress								0x0CF8
;#define PCIData								0x0CFC



;static int PCIDetect()
;{
;	// poke 32-bit I/O register at 0xCF8 to see if there's a PCI controller there
;	outpd(PCIAddress, 0x80000000L);
;	if(inpd(PCIAddress) != 0x80000000L)
;	{
;		return false;
;	}
;	return true;
;}



;static unsigned PCIReadByte(unsigned bdf, unsigned reg)
;{
;	unsigned long i = bdf;
;
;	i <<= 8;
;	i |= 0x80000000L; /* "enable configuration space mapping" */
;	i |= (reg & ~3);
;	outpd(PCIAddress, i);
;
;	return inp(PCIData + (reg & 3));
;}



;static unsigned PCIReadWord(unsigned bdf, unsigned reg)
;{
;	unsigned long i = bdf;
;
;	i <<= 8;
;	i |= 0x80000000L;
;	i |= (reg & ~3);
;	outpd(PCIAddress, i);
;	return inpw(PCIData + (reg & 2));
;}



;unsigned long PCIReadDWord(unsigned long PCIBus, unsigned long PCIDevice, unsigned long PCIFunction, unsigned long PCIRegister)
;{
;	unsigned long PCIBDF = 0;
;
;	PCIBDF = PCIBDF | (PCIBus << 16);
;	PCIBDF = PCIBDF | (PCIDevice << 11);
;	PCIBDF = PCIBDF | (PCIFunction << 8);
;	PCIBDF = PCIBDF | (PCIRegister << 2);
;	PCIBDF = PCIBDF | (0x80000000);
;
;	outpd(PCIAddress, PCIBDF);
;	return inpd(PCIData);
;}



;static void PCIWriteByte(unsigned bdf, unsigned reg, unsigned val)
;{
;	unsigned long i = bdf;
;
;	i <<= 8;
;	i |= 0x80000000L;
;	i |= (reg & ~3);
;	outpd(PCIAddress, i);
;	// xxx - is this right?
;	outp(PCIData + (reg & 3), val);
;}



;static void PCIWriteWord(unsigned bdf, unsigned reg, unsigned val)
;{
;	unsigned long i = bdf;
;
;	i <<= 8;
;	i |= 0x80000000L;
;	i |= (reg & ~3);
;	outpd(PCIAddress, i);
;	outpw(PCIData + (reg & 2), val);
;}



;static void PCIWriteDWord(unsigned bdf, unsigned reg, unsigned long val)
;{
;	unsigned long i = bdf;
;
;	i <<= 8;
;	i |= 0x80000000L;
;	i |= (reg & ~3);
;	outpd(PCIAddress, i);
;	outpd(PCIData, val);
;}



;sprintf(&printString, "Checking for PCI support...\0"); VESAPrint(0, y, 0x00777777, printString, 0); y = y + 16;
;gComputer.PCISupport = PCIDetect();
;if (gComputer.PCISupport == true)
;{
;	sprintf(&printString, "PCI controller detected, probing busses...\0"); VESAPrint(0, y, 0x00777777, printString, 0); y = y + 16;
;	sprintf(&printString, "Bus     Device     Function     Vendor     Device\0"); VESAPrint(0, y, 0x00777777, printString, 0); y = y + 16;
;	for (PCIBus = 0; PCIBus <= 255; PCIBus++)
;	{
;		for (PCIDevice = 0; PCIDevice <= 31; PCIDevice++)
;		{
;			for (PCIFunction = 0; PCIFunction <= 7; PCIFunction++)
;			{
;				i = PCIReadDWord(PCIBus, PCIDevice, PCIFunction, 0x00);
;				PCIDeviceCode = i >> 16;
;				PCIVendorCode = i & 0xffff;
;				if (PCIVendorCode != 0xffff)
;				{
;					i = PCIReadDWord(PCIBus, PCIDevice, PCIFunction, 0x02);
;					PCIClassCode = (i >> 24) & 0xff;
;					PCISubclassCode = (i >> 16) & 0xff;
;					sprintf(&printString, "%3d     %6d     %8d     %6x     %6x     \0", PCIBus, PCIDevice, PCIFunction, PCIVendorCode, PCIDeviceCode); VESAPrint(0, y, 0x00777777, printString, 0);
;
;					sprintf(&printString, "Reserved\0");
;					if (PCIClassCode == 0x00) sprintf(&printString, "<none>\0");
;					if (PCIClassCode == 0x01) sprintf(&printString, "Mass Storage Controller\0");
;					if (PCIClassCode == 0x02) sprintf(&printString, "Network Controller\0");
;					if (PCIClassCode == 0x03) sprintf(&printString, "Display Controller\0");
;					if (PCIClassCode == 0x04) sprintf(&printString, "Multimedia Controller\0");
;					if (PCIClassCode == 0x05) sprintf(&printString, "Memory Controller\0");
;					if (PCIClassCode == 0x06) sprintf(&printString, "Bridge Device\0");
;					if (PCIClassCode == 0x07) sprintf(&printString, "Simple Communication Controller\0");
;					if (PCIClassCode == 0x08) sprintf(&printString, "Base System Peripheral\0");
;					if (PCIClassCode == 0x09) sprintf(&printString, "Input Device\0");
;					if (PCIClassCode == 0x0a) sprintf(&printString, "Docking Station\0");
;					if (PCIClassCode == 0x0b) sprintf(&printString, "Processor\0");
;					if (PCIClassCode == 0x0c) sprintf(&printString, "USB Controller\0");
;					if (PCIClassCode == 0x0d) sprintf(&printString, "Wireless Controller\0");
;					if (PCIClassCode == 0x0e) sprintf(&printString, "Intelligent I/O Controller\0");
;					if (PCIClassCode == 0x0f) sprintf(&printString, "Satellite Communication Controller\0");
;					if (PCIClassCode == 0x10) sprintf(&printString, "Encryption/Decryption Controller\0");
;					if (PCIClassCode == 0x11) sprintf(&printString, "Data Acquisition and Signal Processing Controller\0");
;					if (PCIClassCode == 0xff) sprintf(&printString, "Device does not fit any defined class\0");
;					VESAPrint(648, y, 0x00777777, printString, 0); y = y + 16;
;				}
;			}
;		}
;	}
;}
;else
;{
;	sprintf(&printString, "PCI controller not found, continuing boot...\0"); VESAPrint(0, y, 0x00777777, printString, 0);y = y + 32;
;}
