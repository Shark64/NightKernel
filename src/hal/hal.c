/*
 * NightDOS Kernel
 *
 * hal.c
 *
 *  Created on: Aug 19, 2015
 *      Author: agordon
 *
 *	PURPOSE: The hardware abstraction layer provides a means to access hardware
 *	in a generic manner. All the hardware dependencies are behind this
 *	interface
 */

/**
 *
 * Header files
 *
 */
#include <hal.h>
#include "cpu.h"
#include "idt.h"

/**
 *
 * Functions
 *
 */

// Initialize hardware devices
int __cdecl hal_init() {

	cpu_initialize();
	return 0;

}

// Shutdown hardware devices
int __cdecl hal_done() {

	cpu_shutdown();
	return 0;
}

// Generate interrupt call

void __cdecl geninterrupt(int n) {
	asm(".intel_syntax noprefix\n\t"
			"mov al, byte ptr [n]\n"
			"mov byte ptr [genint+1], al\n"
			"jmp genint\n"
		"genint:\n"
			"int 0\n"	// above code modifies the 0 to int number to generate
		".att_syntax prefix");

}

/**
 *
 * End hal.c
 *
 */
