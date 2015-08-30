/*
 * cpu.c
 *
 *  Created on: Aug 20, 2015
 *      Author: agordon
 */

#include "cpu.h"
#include "gdt.h"
#include "idt.h"

int cpu_initialize () {

	//! initialize processor tables
	gdt_initialize ();
	idt_initialize (0x8);

	return 0;
}

void cpu_shutdown () {


}
