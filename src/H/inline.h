/**********************************************************

		Inline assembly kludge fix for various C
		Compilers

***********************************************************/

#ifdef _MSC_VER
	#define ASM _asm
#else
	#ifdef __TURBO_C__
		#define ASM asm
	#else
		#ifdef __GNUC__
			#define ASM __asm__
		#endif
	#endif
#endif

/*
	End of inline defines
	
*/

