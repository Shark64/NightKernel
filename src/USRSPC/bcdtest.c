/*
 *  BCDTEST.C - demo BCD decoding action
 */
#include <stdio.h>
#include "bcd.h"

void main( void )
{ int i, j;
  char c[3];

  c[2] = 0;
  for(j=0; j<10; j++ )
    for( i=0; i<10; i++ )
      { *(int *)c = BCD_ASC((char)(( j << 4 ) + i ));
        printf( "%5s%3d", c, BCD_Bin((char)(( j << 4 ) + i )));
      }
}

