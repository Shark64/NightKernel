/*
 * gdt.h
 *
 *  Created on: Aug 20, 2015
 *      Author: agordon
 */

#ifndef __GDT_H
#define __GDT_H

/**
 *
 * Required headers
 *
 */

#include <stdint.h>


#define MAX_DESCRIPTORS			3

/* Descriptor access bit flags */
#define GDT_ACCESS				0x0001
#define GDT_RW					0x0002
#define GDT_EXPANSION			0x0004
#define GDT_EXEC_CODE			0x0008
#define GDT_CODEDATA			0x0010

/* DPL bits */
#define GDT_DPL					0x0060
#define GDT_MEMORY				0x0080

/* GDT descriptor granularity bit */
#define GDT_LIMITHI_MASK		0x0F
#define GDT_GRAND_OS			0x10
#define GDT_GRAND_32BIT			0x40
#define GDT_GRAND_4K			0x80

#pragma pack (push, 1)

struct gdt_descriptor {

	uint16_t	limit;

	uint16_t	baseLo;
	uint8_t		baseMid;

	uint8_t		flags;
	uint8_t		grand;

	uint8_t		baseHi;
};

/* Setup a descriptor in the Global Descriptor Table */
extern void gdt_set_descriptor(uint32_t i, uint64_t base, uint64_t limit, uint8_t access, uint8_t grand);

/* returns descriptor */
extern struct gdt_descriptor* gdt_get_descriptor (int i);

/* initializes gdt */
extern	int gdt_initialize ();
#pragma pack (pop)


#endif /* __GDT_H */
