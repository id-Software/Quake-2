#include <sys/types.h>
#include <cdaudio.h>

#include "../client/client.h"

void CDAudio_Play(int track, qboolean looping)
{
        Com_Printf("XXX - CDAudio_Play %i (%i)\n", track, looping);
}


void CDAudio_Stop(void)
{
        Com_Printf("XXX - CDAudio_Stop\n");
}


void CDAudio_Resume(void)
{
        Com_Printf("XXX - CDAudio_Resume\n");
}


void CDAudio_Update(void)
{
/*         Com_Printf("XXX - CDAudio_Update\n"); */
}


int CDAudio_Init(void)
{
        Com_Printf("XXX - CDAudio_Init\n");
	return 0;
}


void CDAudio_Shutdown(void)
{
        Com_Printf("XXX - CDAudio_Shutdown\n");
}
