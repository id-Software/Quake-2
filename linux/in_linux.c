// in_null.c -- for systems without a mouse

#include "../client/client.h"

cvar_t	*in_mouse;
cvar_t	*in_joystick;

void IN_Init (void)
{
    in_mouse = Cvar_Get ("in_mouse", "1", CVAR_ARCHIVE);
    in_joystick = Cvar_Get ("in_joystick", "0", CVAR_ARCHIVE);
}

void IN_Shutdown (void)
{
}

void IN_Commands (void)
{
}

void IN_Move (usercmd_t *cmd)
{
}

void IN_Activate (qboolean active)
{
}

