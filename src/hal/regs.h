/*
 * regs.h
 *
 *  Created on: Aug 19, 2015
 *      Author: agordon
 *
 *  PURPOSE: Abstracts the register names
 *
 */

#ifndef SRC_HAL_REGS_H_
#define SRC_HAL_REGS_H_

#include <stdint.h>

/**
 *
 * Structure definitions
 *
 */

// 32-bit registers

struct _REGS32BIT {
	uint32_t eax, ebx, ecx, edx, esi, edi, ebp, esp, eflag;
	uint8_t cflag;
};

struct _REGS16BIT {
	uint16_t ax, bx, cx, dx, si, di, bp, sp, es, cs, ss, ds, flags;
	uint8_t cflag;
};

struct _REGS16BIT32 {
	uint16_t ax, axh, bx, bxh, cx, cxh, dx, dxh;
	uint16_t si, di, bp, sp, es, cs, ss, ds, flags;
	uint8_t cflags;
};

struct _REGS8BIT {
	uint8_t al, ah, bl, bh, cl, ch, dl, dh;
};

struct _REGS8BIT32 {
	uint8_t al, ah; uint16_t axh;
	uint8_t bl, bh; uint16_t bxh;
	uint8_t cl, ch; uint16_t cxh;
	uint8_t dl, dh; uint16_t dxh;
};

union _INTR16 {
	struct _REGS16BIT x;
	struct _REGS8BIT h;
};

union _INTR32 {
	struct _REGS32BIT x;
	struct _REGS16BIT32 l;
	struct _REGS8BIT32 h;
};

/**
 *
 * End regs.h
 *
 */

#endif /* SRC_HAL_REGS_H_ */
