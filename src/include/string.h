#ifndef __STRING_H
#define __STRING_H
/*
 * NightDOS Kernel
 *
 * string.h
 *
 *	Standard C String routines
 *  Created on: Aug 19, 2015
 *      Author: agordon
 *
 *
 *
 */

#include <size_t.h>

extern size_t strlen (const char* str );
extern char *strcpy(char *s1, const char *s2);

extern void* memcpy(void *dest, const void *src, size_t count);
extern void *memset(void *dest, char val, size_t count);
extern unsigned short* memsetw(unsigned short *dest, unsigned short val, size_t count);

#endif /* __STRING_H */
