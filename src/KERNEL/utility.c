/*
 * utility.c
 *
 *  Created on: Aug 20, 2015
 *      Author: agordon
 *
 *  Contains miscellaneous utility functions
 *
 */

#include <stdarg.h>
#include <stdint.h>
#include <string.h>
#include <hal.h>
#include <_null.h>

#define END_OF_KMESS		-1

/* video memory */
uint16_t *video_memory = (uint16_t *)0xB8000;

/* current position */
uint8_t cursor_x = 0;
uint8_t cursor_y = 0;

/* current color */
uint8_t	_color=0;

void kputc (unsigned char c) {

    uint16_t attribute = _color << 8;

    //! backspace character
    if (c == 0x08 && cursor_x)
        cursor_x--;

    //! tab character
    else if (c == 0x09)
        cursor_x = (cursor_x+8) & ~(8-1);

    //! carriage return
    else if (c == '\r')
        cursor_x = 0;

    //! new line
	else if (c == '\n') {
        cursor_x = 0;
        cursor_y++;
	}

    //! printable characters
    else if(c >= ' ') {

		//! display character on screen
        uint16_t* location = video_memory + (cursor_y*80 + cursor_x);
        *location = c | attribute;
        cursor_x++;
    }

    //! if we are at edge of row, go to new line
    if (cursor_x >= 80) {

        cursor_x = 0;
        cursor_y++;
    }
}

char tbuf[32];
char bchars[] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};

void itoa(unsigned i,unsigned base,char* buf) {
   int pos = 0;
   int opos = 0;
   int top = 0;

   if (i == 0 || base > 16) {
      buf[0] = '0';
      buf[1] = '\0';
      return;
   }

   while (i != 0) {
      tbuf[pos] = bchars[i % base];
      pos++;
      i /= base;
   }
   top=pos--;
   for (opos=0; opos<top; pos--,opos++) {
      buf[opos] = tbuf[pos];
   }
   buf[opos] = 0;
}

void itoa_s(int i,unsigned base,char* buf) {
   if (base > 16) return;
   if (i < 0) {
      *buf++ = '-';
      i *= -1;
   }
   itoa(i,base,buf);
}

//============================================================================
//    INTERFACE FUNCTIONS
//============================================================================

//! Sets new font color
unsigned ksetcolor (const unsigned c) {

	unsigned t=_color;
	_color=c;
	return t;
}

//! Sets new position
void kgotoxy (unsigned x, unsigned y) {

	if (cursor_x <= 80)
	    cursor_x = x;

	if (cursor_y <= 25)
	    cursor_y = y;
}

//! Clear screen
void kclearscreen (const uint8_t c) {

	//! clear video memory by writing space characters to it
	for (int i = 0; i < 80*25; i++)
        video_memory[i] = ' ' | (c << 8);

    //! move position back to start
    kgotoxy (0,0);
}

//! Displays a string
void kputs (char* str) {

	if (!str)
		return;

	//! err... displays a string
    for (unsigned int i=0; i<strlen(str); i++)
        kputc (str[i]);
}
int kprintf (const char* str, ...) {


	if(!str)
		return 0;

	va_list		args;
	va_start (args, str);
	size_t i;
	for (i=0; i<strlen(str);i++) {

		switch (str[i]) {

			case '%':

				switch (str[i+1]) {

					/*** characters ***/
					case 'c': {
						char c = va_arg (args, char);
						kputc (c);
						i++;		// go to next character
						break;
					}

					/*** address of ***/
					case 's': {
						int c = (int) va_arg (args, char);
						char str[64];
						strcpy (str,(const char*)c);
						kputs (str);
						i++;		// go to next character
						break;
					}

					/*** integers ***/
					case 'd':
					case 'i': {
						int c = va_arg (args, int);
						char str[32]={0};
						itoa_s (c, 10, str);
						kputs (str);
						i++;		// go to next character
						break;
					}

					/*** display in hex ***/
					case 'X':
					case 'x': {
						int c = va_arg (args, int);
						char str[32]={0};
						itoa_s (c,16,str);
						kputs (str);
						i++;		// go to next character
						break;
					}

					default:
						va_end (args);
						return 1;
				}

				break;

			default:
				kputc (str[i]);
				break;
		}

	}

	va_end (args);
	return i;
}
