/*
Copyright (C) 1997-2001 Id Software, Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/
#include <stdlib.h>
#include "client.h"

#if id386

static unsigned long bias;
static unsigned long *histogram;
static unsigned long start, range;
static unsigned long bias;

__declspec( naked ) void x86_TimerStart( void )
{
	__asm _emit 0fh
	__asm _emit 31h
	__asm mov  start, eax
	__asm ret
}

__declspec( naked ) void x86_TimerStop( void )
{
	__asm push edi
	__asm mov edi, histogram
	__asm _emit 0fh
	__asm _emit 31h
	__asm sub eax, start
	__asm sub eax, bias
	__asm js discard
	__asm cmp eax, range
	__asm jge  discard
	__asm lea edi, [edi + eax*4]
	__asm inc dword ptr [edi]
discard:
	__asm pop edi
	__asm ret
}

#pragma warning( disable: 4035 )
static __declspec( naked ) unsigned long x86_TimerStopBias( void )
{
	__asm push edi
	__asm mov edi, histogram
	__asm _emit 0fh
	__asm _emit 31h
	__asm sub eax, start
	__asm pop edi
	__asm ret
}
#pragma warning( default:4035 )

void x86_TimerInit( unsigned long smallest, unsigned length )
{
	int i;
	unsigned long biastable[100];

	range = length;
	bias = 10000;

	for ( i = 0; i < 100; i++ )
	{
		x86_TimerStart();
		biastable[i] = x86_TimerStopBias();

		if ( bias > biastable[i] )
			bias = biastable[i];
	}

	bias += smallest;
	histogram = Z_Malloc( range * sizeof( unsigned long ) );
}

unsigned long *x86_TimerGetHistogram( void )
{
	return histogram;
}

#endif
