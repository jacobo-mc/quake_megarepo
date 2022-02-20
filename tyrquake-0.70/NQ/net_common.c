/*
Copyright (C) 1996-1997 Id Software, Inc.

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

#include "common.h"
#include "net.h"

int
NET_AddrCompare(const netadr_t *addr1, const netadr_t *addr2)
{
    if (addr1->ip.l != addr2->ip.l || addr1->port != addr2->port)
	return -1;

    return 0;
}

int
NET_GetSocketPort(const netadr_t *addr)
{
    return (unsigned short)BigShort(addr->port);
}

int
NET_SetSocketPort(netadr_t *addr, int port)
{
    addr->port = BigShort(port);
    return 0;
}

/*
 * ============
 * PartialIPAddress
 *
 * this lets you type only as much of the net address as required,
 * using the local network components to fill in the rest
 * ============
 */
int
NET_PartialIPAddress(const char *in, const netadr_t *myaddr, netadr_t *addr)
{
    char buffer[256];
    char *pos;
    int ip;
    int num;
    int mask;
    int run;
    int octets;
    int port;

    buffer[0] = '.';
    pos = buffer;
    qstrncpy(buffer + 1, in, sizeof(buffer) - 1);
    if (buffer[1] == '.')
	pos++;

    ip = 0;
    mask = -1;
    octets = 0;
    while (*pos == '.') {
	pos++;
	num = 0;
	run = 0;
	while (*pos >= '0' && *pos <= '9') {
            num = num * 10 + *pos++ - '0';
	    if (++run > 3)
		return -1;
	}
	if (*pos != '.' && *pos != ':' && *pos != 0)
	    return -1;
	if (num < 0 || num > 255)
	    return -1;
	mask <<= 8;
	ip = (ip << 8) + num;
        octets++;
    }

    if (*pos++ == ':')
	port = Q_atoi(pos);
    else
	port = net_hostport;

    addr->port = BigShort(port);

    /* If we aren't bound to an address, we need the full IP address */
    if (!myaddr) {
        addr->ip.l = BigLong(ip);
        return (octets == 4) ? 0 : -1;
    }

    addr->ip.l = (myaddr->ip.l & BigLong(mask)) | BigLong(ip);

    return 0;
}
