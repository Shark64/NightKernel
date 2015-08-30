/*
 * idt.h
 *
 *  Created on: Aug 20, 2015
 *      Author: agordon
 */

#ifndef __IDT_H
#define __IDT_H

#include <stdint.h>

#pragma pack (push, 1)


#define MAX_INTERRUPTS		256


#define IDT_DESC_BIT16		0x06	//00000110
#define IDT_DESC_BIT32		0x0E	//00001110
#define IDT_DESC_RING1		0x40	//01000000
#define IDT_DESC_RING2		0x20	//00100000
#define IDT_DESC_RING3		0x60	//01100000
#define IDT_DESC_PRESENT	0x80	//10000000

typedef void (*IRQ_HANDLER)(void);

/* interrupt descriptor */
struct idt_descriptor {

	/* bits 0-16 of interrupt routine (ir) address */
	uint16_t		baseLo;
	uint16_t		sel;
	uint8_t			reserved;
	uint8_t			flags;
	uint16_t		baseHi;
};

#pragma pack (pop)

extern struct idt_descriptor* get_ir (uint32_t i);
extern int install_ir (uint32_t i, uint16_t flags, uint16_t sel, IRQ_HANDLER);
extern int idt_initialize (uint16_t codeSel);
#endif /* __IDT_H */
