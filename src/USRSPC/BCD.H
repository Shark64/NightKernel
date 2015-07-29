/*
        BCD.H - Functions for dealing with BCD representations.
                Based on code written by J. Pyle in DOS 6 Developer's
                Guide. The original source code is copyrighted by
                SAMS Publishing and/or J. Pyle
				
			

*/

#ifndef BCD_UTL_
#define BCD_UTL_
#include "../h/stdint.h"

uint16_t BCD_ASC ( uint8_t bcd );
uint16_t BCD_Bin ( uint8_t bcd );
uint8_t ASC_BCD ( uint8_t hi, uint8_t lo);
uint8_t Bin_BCD ( uint8_t bin );

#endif
