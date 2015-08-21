/*
 * idt.c
 *
 *  Created on: Aug 20, 2015
 *      Author: agordon
 */

#include "idt.h"
#include <string.h>
#include <hal.h>

#pragma pack (push, 1)

/* describes the structure for the processors idtr register */
struct idtr {
	uint16_t limit;
	uint32_t base;
};

#pragma pack (pop, 1)

/* interrupt descriptor table */
static struct idt_descriptor _idt[MAX_INTERRUPTS];

/* idtr structure used to help define the cpu's idtr register */
static struct idtr _idtr;

/* installs idtr into processors idtr register */
static void idt_install();

/* default int handler used to catch unregistered interrupts */
static void default_handler();

static void idt_install() {
	__asm__(".intel_syntax noprefix\n\t"
			"lidt [_idtr]\n\t"
			".att_syntax prefix"
	);
}

static void default_handler() {

#ifdef _DEBUG
#endif

	for (;;);
}

struct idt_descriptor* get_ir(uint32_t i) {

	if (i > MAX_INTERRUPTS)
		return 0;

	return &_idt[i];
}

int install_ir(uint32_t i, uint16_t flags, uint16_t sel, IRQ_HANDLER irq) {

	if (i > MAX_INTERRUPTS)
		return 0;

	if (!irq)
		return 0;

	//! get base address of interrupt handler
	uint64_t uiBase = (uint64_t) &(*irq);

	//! store base address into idt
	_idt[i].baseLo = uint16_t(uiBase & 0xffff);
	_idt[i].baseHi = uint16_t((uiBase >> 16) & 0xffff);
	_idt[i].reserved = 0;
	_idt[i].flags = uint8_t(flags);
	_idt[i].sel = sel;

	return 0;
}

int idt_initialize(uint16_t codeSel) {

	//! set up idtr for processor
	_idtr.limit = sizeof(struct idt_descriptor) * MAX_INTERRUPTS - 1;
	_idtr.base = (uint32_t) &_idt[0];

	//! null out the idt
	memset((void*) &_idt[0], 0, sizeof(struct idt_descriptor) * MAX_INTERRUPTS - 1);

	//! register default handlers
	for (int i = 0; i < MAX_INTERRUPTS; i++)
		i86_install_ir(i, IDT_DESC_PRESENT | IDT_DESC_BIT32, codeSel,
				(IRQ_HANDLER) default_handler);

	//! install our idt
	idt_install();

	return 0;
}
