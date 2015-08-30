/*
 * NightDOS Kernel
 *
 * hal.h
 *
 *	Hardware Abstraction Layer Interface
 *  Created on: Aug 18, 2015
 *      Author: agordon
 *
 *
 *	PURPOSE: The hardware abstraction layer provides a means to access hardware
 *	in a generic manner. All the hardware dependencies are behind this interface
 *
 *	All routines and types are declared extern and must be defined within
 *	external libraries to define specific HAL implementations
 *
 */

#ifndef __HAL_H
#define __HAL_H

/**
 *
 * Required headers
 *
 */

#include <stdint.h>

/**
 *
 * Typedefs and such
 *
 */

#define interrupt

#define far
#define near
//#ifdef __GNUC__
	#ifndef __cdecl
		#define __cdecl __attribute__((__cdecl__))
	#endif
//#endif

/**
 *
 * Function prototypes
 *
 *
 */

// Initialize the abstraction layer
extern int		__cdecl hal_init();

// shutdown the abstraction layer
extern int		__cdecl hal_done();

// generate interrupt
extern int		__cdecl geninterrupt(int n);

/**
 *
 * End of hal.h
 *
 */
#endif /* __HAL_H */
