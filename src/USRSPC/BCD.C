/*
        BCD.C - Functions for dealing with BCD representations.
                Based on code written by J. Pyle in DOS 6 Developer's
                Guide. The original source code is copyrighted by
                SAMS Publishing and/or J. Pyle

                The code was slightly modified from it's original form
                to improve clarity and to add constant declarations.

*/

#include <bcd.h>


uint16_t BCD_ASC ( uint8_t bcd )
{
  uint16_t retval;

        asm xor ah, ah;
        asm mov al, bcd;
        asm mov cl, 4;
        asm shl ax, cl;
        asm shr al, cl;
        asm xchg ah, al;
        asm add ax, 0x3030;
        asm mov retval, ax;
        return (retval);
}

uint16_t BCD_Bin ( uint8_t bcd )
{
  uint16_t retval;

        asm xor ah, ah;
        asm mov al, bcd;
        asm mov cl, 4;
        asm shl ax, cl;
        asm shr al, cl;
        asm xor bx, bx;
        asm xchg ah, al;
        asm mov ch, 10;
        asm mul ch;
        asm add ax, bx;
        asm mov retval, ax;
        return (retval);
}

uint16_t ASC_BCD ( uint8_t hi, uint8_t lo)
{
   uint16_t retval;

        asm mov ah, hi;                  /* convert to unpacked BCD */
        asm mov al, lo;
        asm and ax, 0x0F0F;
        asm mov cl, 4;                   /* pack up the BCD         */
        asm shl al, cl;
        asm shr ax, cl;
        asm mov retval, ax;
        return (retval);
}

uint16_t Bin_BCD ( uint8_t bin )
{
  uint16_t retval;

        asm mov al, bin;                /* convert to unpacked BCD */
        asm aam;
        asm mov cl, 4;                  /* pack up the BCD         */
        asm shl al, cl;
        asm shr ax, cl;
        asm mov retval, ax;
        return ( retval );
}