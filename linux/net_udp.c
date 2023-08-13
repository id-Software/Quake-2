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
// net_wins.c

#include "../qcommon/qcommon.h"

#include <unistd.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <netdb.h>
#include <sys/param.h>
#include <sys/ioctl.h>
#include <sys/uio.h>
#include <errno.h>

#ifdef NeXT
#include <libc.h>
#endif

netadr_t	net_local_adr;

#define	LOOPBACK	0x7f000001

#define	MAX_LOOPBACK	4

typedef struct
{
	byte	data[MAX_MSGLEN];
	int		datalen;
} loopmsg_t;

typedef struct
{
	loopmsg_t	msgs[MAX_LOOPBACK];
	int			get, send;
} loopback_t;

loopback_t	loopbacks[2];
int			ip_sockets[2];
int			ipx_sockets[2];

int NET_Socket (char *net_interface, int port);
char *NET_ErrorString (void);

//=============================================================================

void NetadrToSockadr (netadr_t *a, struct sockaddr_in *s)
{
	memset (s, 0, sizeof(*s));

	if (a->type == NA_BROADCAST)
	{
		s->sin_family = AF_INET;

		s->sin_port = a->port;
		*(int *)&s->sin_addr = -1;
	}
	else if (a->type == NA_IP)
	{
		s->sin_family = AF_INET;

		*(int *)&s->sin_addr = *(int *)&a->ip;
		s->sin_port = a->port;
	}
}

void SockadrToNetadr (struct sockaddr_in *s, netadr_t *a)
{
	*(int *)&a->ip = *(int *)&s->sin_addr;
	a->port = s->sin_port;
	a->type = NA_IP;
}


qboolean	NET_CompareAdr (netadr_t a, netadr_t b)
{
	if (a.ip[0] == b.ip[0] && a.ip[1] == b.ip[1] && a.ip[2] == b.ip[2] && a.ip[3] == b.ip[3] && a.port == b.port)
		return true;
	return false;
}

/*
===================
NET_CompareBaseAdr

Compares without the port
===================
*/
qboolean	NET_CompareBaseAdr (netadr_t a, netadr_t b)
{
	if (a.type != b.type)
		return false;

	if (a.type == NA_LOOPBACK)
		return true;

	if (a.type == NA_IP)
	{
		if (a.ip[0] == b.ip[0] && a.ip[1] == b.ip[1] && a.ip[2] == b.ip[2] && a.ip[3] == b.ip[3])
			return true;
		return false;
	}

	if (a.type == NA_IPX)
	{
		if ((memcmp(a.ipx, b.ipx, 10) == 0))
			return true;
		return false;
	}
}

char	*NET_AdrToString (netadr_t a)
{
	static	char	s[64];
	
	Com_sprintf (s, sizeof(s), "%i.%i.%i.%i:%i", a.ip[0], a.ip[1], a.ip[2], a.ip[3], ntohs(a.port));

	return s;
}

char	*NET_BaseAdrToString (netadr_t a)
{
	static	char	s[64];
	
	Com_sprintf (s, sizeof(s), "%i.%i.%i.%i", a.ip[0], a.ip[1], a.ip[2], a.ip[3]);

	return s;
}

/*
=============
NET_StringToAdr

localhost
idnewt
idnewt:28000
192.246.40.70
192.246.40.70:28000
=============
*/
qboolean	NET_StringToSockaddr (char *s, struct sockaddr *sadr)
{
	struct hostent	*h;
	char	*colon;
	char	copy[128];
	
	memset (sadr, 0, sizeof(*sadr));
	((struct sockaddr_in *)sadr)->sin_family = AF_INET;
	
	((struct sockaddr_in *)sadr)->sin_port = 0;

	strcpy (copy, s);
	// strip off a trailing :port if present
	for (colon = copy ; *colon ; colon++)
		if (*colon == ':')
		{
			*colon = 0;
			((struct sockaddr_in *)sadr)->sin_port = htons((short)atoi(colon+1));	
		}
	
	if (copy[0] >= '0' && copy[0] <= '9')
	{
		*(int *)&((struct sockaddr_in *)sadr)->sin_addr = inet_addr(copy);
	}
	else
	{
		if (! (h = gethostbyname(copy)) )
			return 0;
		*(int *)&((struct sockaddr_in *)sadr)->sin_addr = *(int *)h->h_addr_list[0];
	}
	
	return true;
}

/*
=============
NET_StringToAdr

localhost
idnewt
idnewt:28000
192.246.40.70
192.246.40.70:28000
=============
*/
qboolean	NET_StringToAdr (char *s, netadr_t *a)
{
	struct sockaddr_in sadr;
	
	if (!strcmp (s, "localhost"))
	{
		memset (a, 0, sizeof(*a));
		a->type = NA_LOOPBACK;
		return true;
	}

	if (!NET_StringToSockaddr (s, (struct sockaddr *)&sadr))
		return false;
	
	SockadrToNetadr (&sadr, a);

	return true;
}


qboolean	NET_IsLocalAddress (netadr_t adr)
{
	return NET_CompareAdr (adr, net_local_adr);
}

/*
=============================================================================

LOOPBACK BUFFERS FOR LOCAL PLAYER

=============================================================================
*/

qboolean	NET_GetLoopPacket (netsrc_t sock, netadr_t *net_from, sizebuf_t *net_message)
{
	int		i;
	loopback_t	*loop;

	loop = &loopbacks[sock];

	if (loop->send - loop->get > MAX_LOOPBACK)
		loop->get = loop->send - MAX_LOOPBACK;

	if (loop->get >= loop->send)
		return false;

	i = loop->get & (MAX_LOOPBACK-1);
	loop->get++;

	memcpy (net_message->data, loop->msgs[i].data, loop->msgs[i].datalen);
	net_message->cursize = loop->msgs[i].datalen;
	*net_from = net_local_adr;
	return true;

}


void NET_SendLoopPacket (netsrc_t sock, int length, void *data, netadr_t to)
{
	int		i;
	loopback_t	*loop;

	loop = &loopbacks[sock^1];

	i = loop->send & (MAX_LOOPBACK-1);
	loop->send++;

	memcpy (loop->msgs[i].data, data, length);
	loop->msgs[i].datalen = length;
}

//=============================================================================

qboolean	NET_GetPacket (netsrc_t sock, netadr_t *net_from, sizebuf_t *net_message)
{
	int 	ret;
	struct sockaddr_in	from;
	int		fromlen;
	int		net_socket;
	int		protocol;
	int		err;

	if (NET_GetLoopPacket (sock, net_from, net_message))
		return true;

	for (protocol = 0 ; protocol < 2 ; protocol++)
	{
		if (protocol == 0)
			net_socket = ip_sockets[sock];
		else
			net_socket = ipx_sockets[sock];

		if (!net_socket)
			continue;

		fromlen = sizeof(from);
		ret = recvfrom (net_socket, net_message->data, net_message->maxsize
			, 0, (struct sockaddr *)&from, &fromlen);

		SockadrToNetadr (&from, net_from);

		if (ret == -1)
		{
			err = errno;

			if (err == EWOULDBLOCK || err == ECONNREFUSED)
				continue;
			Com_Printf ("NET_GetPacket: %s from %s\n", NET_ErrorString(),
						NET_AdrToString(*net_from));
			continue;
		}

		if (ret == net_message->maxsize)
		{
			Com_Printf ("Oversize packet from %s\n", NET_AdrToString (*net_from));
			continue;
		}

		net_message->cursize = ret;
		return true;
	}

	return false;
}

//=============================================================================

void NET_SendPacket (netsrc_t sock, int length, void *data, netadr_t to)
{
	int		ret;
	struct sockaddr_in	addr;
	int		net_socket;

	if ( to.type == NA_LOOPBACK )
	{
		NET_SendLoopPacket (sock, length, data, to);
		return;
	}

	if (to.type == NA_BROADCAST)
	{
		net_socket = ip_sockets[sock];
		if (!net_socket)
			return;
	}
	else if (to.type == NA_IP)
	{
		net_socket = ip_sockets[sock];
		if (!net_socket)
			return;
	}
	else if (to.type == NA_IPX)
	{
		net_socket = ipx_sockets[sock];
		if (!net_socket)
			return;
	}
	else if (to.type == NA_BROADCAST_IPX)
	{
		net_socket = ipx_sockets[sock];
		if (!net_socket)
			return;
	}
	else
		Com_Error (ERR_FATAL, "NET_SendPacket: bad address type");

	NetadrToSockadr (&to, &addr);

	ret = sendto (net_socket, data, length, 0, (struct sockaddr *)&addr, sizeof(addr) );
	if (ret == -1)
	{
		Com_Printf ("NET_SendPacket ERROR: %s to %s\n", NET_ErrorString(),
				NET_AdrToString (to));
	}
}


//=============================================================================




/*
====================
NET_OpenIP
====================
*/
void NET_OpenIP (void)
{
	cvar_t	*port, *ip;

	port = Cvar_Get ("port", va("%i", PORT_SERVER), CVAR_NOSET);
	ip = Cvar_Get ("ip", "localhost", CVAR_NOSET);

	if (!ip_sockets[NS_SERVER])
		ip_sockets[NS_SERVER] = NET_Socket (ip->string, port->value);
	if (!ip_sockets[NS_CLIENT])
		ip_sockets[NS_CLIENT] = NET_Socket (ip->string, PORT_ANY);
}

/*
====================
NET_OpenIPX
====================
*/
void NET_OpenIPX (void)
{
}


/*
====================
NET_Config

A single player game will only use the loopback code
====================
*/
void	NET_Config (qboolean multiplayer)
{
	int		i;

	if (!multiplayer)
	{	// shut down any existing sockets
		for (i=0 ; i<2 ; i++)
		{
			if (ip_sockets[i])
			{
				close (ip_sockets[i]);
				ip_sockets[i] = 0;
			}
			if (ipx_sockets[i])
			{
				close (ipx_sockets[i]);
				ipx_sockets[i] = 0;
			}
		}
	}
	else
	{	// open sockets
		NET_OpenIP ();
		NET_OpenIPX ();
	}
}


//===================================================================


/*
====================
NET_Init
====================
*/
void NET_Init (void)
{
}


/*
====================
NET_Socket
====================
*/
int NET_Socket (char *net_interface, int port)
{
	int newsocket;
	struct sockaddr_in address;
	qboolean _true = true;
	int	i = 1;

	if ((newsocket = socket (PF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
	{
		Com_Printf ("ERROR: UDP_OpenSocket: socket: %s", NET_ErrorString());
		return 0;
	}

	// make it non-blocking
	if (ioctl (newsocket, FIONBIO, &_true) == -1)
	{
		Com_Printf ("ERROR: UDP_OpenSocket: ioctl FIONBIO:%s\n", NET_ErrorString());
		return 0;
	}

	// make it broadcast capable
	if (setsockopt(newsocket, SOL_SOCKET, SO_BROADCAST, (char *)&i, sizeof(i)) == -1)
	{
		Com_Printf ("ERROR: UDP_OpenSocket: setsockopt SO_BROADCAST:%s\n", NET_ErrorString());
		return 0;
	}

	if (!net_interface || !net_interface[0] || !stricmp(net_interface, "localhost"))
		address.sin_addr.s_addr = INADDR_ANY;
	else
		NET_StringToSockaddr (net_interface, (struct sockaddr *)&address);

	if (port == PORT_ANY)
		address.sin_port = 0;
	else
		address.sin_port = htons((short)port);

	address.sin_family = AF_INET;

	if( bind (newsocket, (void *)&address, sizeof(address)) == -1)
	{
		Com_Printf ("ERROR: UDP_OpenSocket: bind: %s\n", NET_ErrorString());
		close (newsocket);
		return 0;
	}

	return newsocket;
}


/*
====================
NET_Shutdown
====================
*/
void	NET_Shutdown (void)
{
	NET_Config (false);	// close sockets
}


/*
====================
NET_ErrorString
====================
*/
char *NET_ErrorString (void)
{
	int		code;

	code = errno;
	return strerror (code);
}

// sleeps msec or until net socket is ready
void NET_Sleep(int msec)
{
    struct timeval timeout;
	fd_set	fdset;
	extern cvar_t *dedicated;
	extern qboolean stdin_active;

	if (!ip_sockets[NS_SERVER] || (dedicated && !dedicated->value))
		return; // we're not a server, just run full speed

	FD_ZERO(&fdset);
	if (stdin_active)
		FD_SET(0, &fdset); // stdin is processed too
	FD_SET(ip_sockets[NS_SERVER], &fdset); // network socket
	timeout.tv_sec = msec/1000;
	timeout.tv_usec = (msec%1000)*1000;
	select(ip_sockets[NS_SERVER]+1, &fdset, NULL, NULL, &timeout);
}

