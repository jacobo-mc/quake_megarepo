/* hwrcon.c - HWRCON 1.2 HexenWorld Remote CONsole
 * Idea based on RCon 1.1 by Michael Dwyer/N0ZAP (18-May-1998).
 * Made to work with HexenWorld using code from the HexenWorld
 * engine (C) Raven Software and ID Software.
 * Copyright (C) 1998 Michael Dwyer <mdwyer@holly.colostate.edu>
 * Copyright (C) 2006-2011 O. Sezer <sezero@users.sourceforge.net>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include "arch_def.h"
#include "compiler.h"

#define	COMPILE_TIME_ASSERT(name, x)	\
	typedef int dummy_ ## name[(x) * 2 - 1]

#include "net_sys.h"
#include "qsnprint.h"

/*****************************************************************************/

typedef struct
{
	unsigned char	ip[4];
	unsigned short	port;
	unsigned short	pad;
} netadr_t;

#if defined(PLATFORM_AMIGA)
struct Library	*SocketBase;
#endif
#if defined(PLATFORM_WINDOWS)
#include "wsaerror.h"
static WSADATA	winsockdata;
#endif
static sys_socket_t	socketfd = INVALID_SOCKET;

FUNC_NORETURN void Sys_Error (const char *error, ...) FUNC_PRINTF(1,2);
#ifdef __WATCOMC__
#pragma aux Sys_Error aborts;
#endif

/*****************************************************************************/

static void NetadrToSockadr (const netadr_t *a, struct sockaddr_in *s)
{
	memset (s, 0, sizeof(*s));
	s->sin_family = AF_INET;

	memcpy (&s->sin_addr, a->ip, 4);
	s->sin_port = a->port;
}

static void SockadrToNetadr (const struct sockaddr_in *s, netadr_t *a)
{
	memcpy (a->ip, &s->sin_addr, 4);
	a->port = s->sin_port;
}

const char *NET_AdrToString (const netadr_t *a)
{
	static	char	s[64];

	sprintf (s, "%i.%i.%i.%i:%i", a->ip[0], a->ip[1], a->ip[2], a->ip[3],
							ntohs(a->port));

	return s;
}

static int NET_StringToAdr (const char *s, netadr_t *a)
{
	struct hostent		*h;
	struct sockaddr_in	sadr;
	char	*colon;
	char	copy[128];

	memset (&sadr, 0, sizeof(sadr));
	sadr.sin_family = AF_INET;
	sadr.sin_port = 0;

	strncpy (copy, s, sizeof(copy) - 1);
	copy[sizeof(copy) - 1] = '\0';
	/* strip off a trailing :port if present */
	for (colon = copy; *colon; colon++)
	{
		if (*colon == ':')
		{
			*colon = 0;
			sadr.sin_port = htons((short)atoi(colon+1));
		}
	}

	if (copy[0] >= '0' && copy[0] <= '9')
	{
		sadr.sin_addr.s_addr = inet_addr(copy);
	}
	else
	{
		h = gethostbyname (copy);
		if (!h)
			return 0;
		sadr.sin_addr.s_addr = *(in_addr_t *)h->h_addr_list[0];
	}

	SockadrToNetadr (&sadr, a);

	return 1;
}

static void NET_Init (void)
{
#if defined(PLATFORM_WINDOWS)
	int err = WSAStartup(MAKEWORD(1,1), &winsockdata);
	if (err != 0)
		Sys_Error ("Winsock initialization failed (%s)", socketerror(err));
#endif	/* PLATFORM_WINDOWS */
#if defined(PLATFORM_OS2) && !defined(__EMX__)
	if (sock_init() < 0)
		Sys_Error ("Can't initialize IBM OS/2 sockets");
#endif	/* OS/2 */
#ifdef PLATFORM_AMIGA
	SocketBase = OpenLibrary("bsdsocket.library", 0);
	if (!SocketBase)
		Sys_Error ("Can't open bsdsocket.library.");
#endif	/* PLATFORM_AMIGA */
#if defined(PLATFORM_DOS) && defined(USE_WATT32)
	int i, err;

/*	dbug_init();*/
	i = _watt_do_exit;
	_watt_do_exit = 0;
	err = sock_init();
	_watt_do_exit = i;
	if (err != 0)
		Sys_Error ("WATTCP initialization failed (%s)", sock_init_err(err));
#endif	/* WatTCP  */
}

static void NET_Shutdown (void)
{
	if (socketfd != INVALID_SOCKET)
	{
		closesocket (socketfd);
		socketfd = INVALID_SOCKET;
	}
#if defined(PLATFORM_WINDOWS)
	WSACleanup ();
#endif
#ifdef PLATFORM_AMIGA
	if (SocketBase)
	{
		CloseLibrary(SocketBase);
		SocketBase = NULL;
	}
#endif
}

/*****************************************************************************/

void Sys_Error (const char *error, ...)
{
	va_list		argptr;
	char		text[1024];

	va_start (argptr,error);
	q_vsnprintf (text, sizeof (text), error,argptr);
	va_end (argptr);

	NET_Shutdown ();

	printf ("\nERROR: %s\n\n", text);

	exit (1);
}

/*****************************************************************************/

#define	VER_HWRCON_MAJ		1
#define	VER_HWRCON_MID		2
#define	VER_HWRCON_MIN		7

#define	PORT_SERVER		26950

#define	MAX_RCON_PACKET		256

static const unsigned char rcon_hdr[10] =
	{ 255, 255, 255, 255,
	  'r', 'c', 'o', 'n', ' ', '\0' };

static unsigned char	packet[MAX_RCON_PACKET];

int main (int argc, char *argv[])
{
	int		i;
	int		len, size;
	netadr_t		ipaddress;
	struct sockaddr_in	hostaddress;
	int		err;
	unsigned char	*p;

	printf ("HWRCON %d.%d.%d\n", VER_HWRCON_MAJ, VER_HWRCON_MID, VER_HWRCON_MIN);

/* command line sanity checking */
	if (argc < 3)
	{
		printf ("Usage: %s <address>[:port] <password> commands ...\n", argv[0]);
		exit (1);
	}

/* init OS-specific network stuff */
	NET_Init ();

/* decode the address and port */
	if (!NET_StringToAdr(argv[1], &ipaddress))
		Sys_Error ("Unable to resolve address %s", argv[1]);
	if (ipaddress.port == 0)
		ipaddress.port = htons(PORT_SERVER);
	NetadrToSockadr(&ipaddress, &hostaddress);
	printf ("Using address %s\n", NET_AdrToString(&ipaddress));

/* prepare the header: \377\377\377\377rcon<space> */
	p = &packet[0];

/* we need not use HuffEncode, therefore we must put an additional
 * 0xff at the beginning for our message to be read by server.  */
	*p++ = 0xff;

	memcpy (p, rcon_hdr, sizeof(rcon_hdr));
	p += sizeof(rcon_hdr) - 1;

/* concat all the excess command line stuff into a single string */
	for (i = 2; i < argc; i++)
	{
		len = strlen(argv[i]);
		if (p - &packet[0] + len + 1 > MAX_RCON_PACKET - 1)
			Sys_Error ("Command too long");
		memcpy (p, argv[i], len);
		p += len;
		*p++ = ' ';
	}
/* kill the trailing space */
	p[-1] = '\0';

	len = p - &packet[0];

/* open the socket */
	socketfd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (socketfd == INVALID_SOCKET)
	{
		err = SOCKETERRNO;
		Sys_Error ("Couldn't open socket: %s", socketerror(err));
	}

/* send the packet */
	size = sendto(socketfd, (char *)packet, len, 0,
			(struct sockaddr *)&hostaddress, sizeof(hostaddress));

/* see if it worked */
	if (size != len)
	{
		err = SOCKETERRNO;
		Sys_Error ("Sendto failed: %s", socketerror(err));
	}

/* clean up */
	NET_Shutdown ();
	return 0;
}
