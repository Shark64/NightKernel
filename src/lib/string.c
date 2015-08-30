/*

 NightDOS

 String implementation routines

 */

#include <string.h>

size_t strlen(const char* str) {

	size_t len = 0;
	while (str[len++])
		;
	return len;
}

char *strcpy(char *s1, const char *s2) {
	char *s1_p = s1;
	while (*s1++ = *s2++)
		;
	return s1_p;
}

void *memcpy(void *dest, const void *src, size_t count) {
	const char *sp = (const char *) src;
	char *dp = (char *) dest;
	for (; count != 0; count--)
		*dp++ = *sp++;
	return dest;
}

void *memset(void *dest, char val, size_t count) {
	unsigned char *temp = (unsigned char *) dest;
	for (; count != 0; count--, temp[count] = val)
		;
	return dest;
}

unsigned short *memsetw(unsigned short *dest, unsigned short val, size_t count) {
	unsigned short *temp = (unsigned short *) dest;
	for (; count != 0; count--)
		*temp++ = val;
	return dest;
}
