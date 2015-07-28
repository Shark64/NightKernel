/*
	NightDOS
	Version 1.0

	FILENAME: CMOS.H

	DESCRIPTION: This is the header file for CMOS.C

*/


#ifndef CMOS_UTL
#define CMOS_UTL
#include <stdint.h>

uint8_t GetCMOS ( int8_t i );
void PutCMOS ( int8_t i, int8_t v );

#endif
