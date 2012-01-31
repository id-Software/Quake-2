
// snddma_null.c
// all other sound mixing is portable

#include "../client/client.h"
#include "../client/snd_loc.h"

qboolean SNDDMA_Init(void)
{
	return false;
}

int	SNDDMA_GetDMAPos(void)
{
	return 0;
}

void SNDDMA_Shutdown(void)
{
}

void SNDDMA_BeginPainting (void)
{
}

void SNDDMA_Submit(void)
{
}
