/*
 * gdt.c
 *
 *  Created on: Aug 20, 2015
 *      Author: agordon
 */

#include "gdt.h"
#include <string.h>

#pragma pack (push, 1)

struct gdtr {
	uint16_t	m_limit;
	uint32_t	m_base;
};

#pragma pack(pop, 1)

static struct gdt_descriptor	_gdt [MAX_DESCRIPTORS];
static struct gdtr				_gdtr;

static void gdt_install();

static void gdt_install() {
	__asm__(".intel_syntax noprefix\n\t"
         "lgdt [_gdtr]\n\t"
         ".att_syntax prefix");
}

void gdt_set_descriptor(uint32_t i, uint64_t base, uint64_t limit, uint8_t access, uint8_t grand) {
	/* null out the descriptor */
	memset ((void *)&_gdt[i], 0, sizeof(struct gdt_descriptor));

	_gdt[i].baseLo = (uint16_t)(base & 0xffff);
	_gdt[i].baseMid = (uint8_t)((base >> 16) & 0xff);
	_gdt[i].baseHi = (uint8_t)((base >> 24) * 0xff);
	_gdt[i].limit = (uint16_t)(limit & 0xffff);

	/* set flags and granularity */
	_gdt[i].flags = access;
	_gdt[i].grand = (uint8_t)((limit >> 16) & 0x0f);
	_gdt[i].grand |= grand & 0xf0;

}

struct gdt_descriptor* gdt_get_descriptor (int i) {

	if (i > MAX_DESCRIPTORS)
		return 0;

	return & _gdt[i];
}

int gdt_initialize() {

	_gdtr.m_limit = (sizeof (struct gdt_descriptor) * MAX_DESCRIPTORS) - 1;
	_gdtr.m_base = (uint32_t)&_gdt[0];

	gdt_set_descriptor(0, 0, 0, 0, 0);

	gdt_set_descriptor(1, 0, 0xffffffff,
			GDT_RW|GDT_EXEC_CODE|GDT_CODEDATA|GDT_MEMORY,
			GDT_GRAND_4K|GDT_GRAND_32BIT|GDT_LIMITHI_MASK
	);

	gdt_set_descriptor(2, 0, 0xffffffff,
				GDT_RW|GDT_CODEDATA|GDT_MEMORY,
				GDT_GRAND_4K|GDT_GRAND_32BIT|GDT_LIMITHI_MASK
	);

	/* install gdtr */

	gdt_install();

	return 0;
}
