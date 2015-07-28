/*

	NightDOS
	Version 1.0

	FILENAME: CMOS.C

	DESCRIPTION: This file contains routines for manipulating values
		     from the CMOS. It simply contains read and write
		     routines.

	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	!!!!                                                  !!!!
	!!!!                                                  !!!!
	!!!!            W  A  R  N  I  N  G                   !!!!
	!!!!                                                  !!!!
	!!!!                                                  !!!!
	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	This routine can be very dangerous if used improperly. There
	is usually no reason for an application program to directly
	modify the CMOS contents as the SETUP program maintains a
	sanity check through CRC to verify contents. Changing values
	with these routines without writing the CRC can produce
	damaging results.

*/

uint8_t GetCMOS( int8_t i )

/* reads value from a cell */

{
	uint8_t result;
	outportb( 0x70, i );
	result = inportb( 0x71 );
	return result;
}

void PutCMOS( int8_t i, int8_t v )

/* writes value v to cell i */

{
	outportb( 0x70, i);
	outportb( 0x71, v);
}
