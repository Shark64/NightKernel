/*
 Night DOS Kernel (kernel.asm) version 0.03
 Copyright 1995-2015 by mercury0x000d

 Kernel.asm is a part of the Night DOS Kernel

 The Night DOS Kernel is free software: you can redistribute it and/or
 modify it under the terms of the GNU General Public License as published
 by the Free Software Foundation, either version 3 of the License, or (at
 your option) any later version.

 The Night DOS Kernel is distributed in the hope that it will be useful, but
 WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 for more details.

 You should have received a copy of the GNU General Public License along
 with the Night DOS Kernel. If not, see <http://www.gnu.org/licenses/>.

 See the included file <GPL License.txt> for the complete text of the
 GPL License by which this program is covered.
 */

// Note: Any call to a kernel or system library function may destroy eax, ebx, ecx, edx, edi and esi.

// function declarations
void X86ProtectedModeEnter(void);

// structs
typedef struct {
	unsigned char baseC;
	unsigned char G_D_X_U_LimitB;
	unsigned char P_DPL_Type_A;
	unsigned char baseB;
	unsigned short baseA;
	unsigned short limitA;
} descriptor;

// globals
unsigned long kIDTPtr = 0x00008000;
unsigned long kGDTPtr = 0x00018000;
unsigned long kVideoText = 0x000B8000;
unsigned char kCopyright[64] =
		"Night DOS Kernel     2015 by mercury0x000d, Maarten Vermeulen\0";

// here's where all the magic happens :)

void main(void) {

	// disable interrupts, load the IDT and GDT addresses, enter protected mode
	asm
	(
			"cli;"
			"mov eax, 0x00008000;"
			"lidt [eax];"
			"mov eax, 0x00018000;"
			"lgdt [eax];"
			"mov %eax, %cr0;"
			"or %eax, 0x00000001;"
			"mov %cr0, %eax;"
	);

	oneBigInfiniteLoop:
	// Nowhere near Cupertino...
	goto oneBigInfiniteLoop;
}

void X86ProtectedModeEnter(void) {
}

