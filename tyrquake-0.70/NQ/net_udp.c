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

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/param.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <unistd.h>
#include <net/if.h>
#include <ifaddrs.h>

#include "common.h"
#include "console.h"
#include "net.h"
#include "net_udp.h"
#include "quakedef.h"
#include "sys.h"

/* socket for fielding new connections */
static int net_acceptsocket = -1;
static int net_controlsocket;
static int net_broadcastsocket = 0;

/*
 * There a couple of options we can use to force specific behaviour of the network addresses:
 *
 * localip_address
 *
 *   If set via the "-localip" command line option, this address will be
 *   forced in the CCREP_SERVER_INFO and CCREP_ACCEPT response packets,
 *   regardless of what our address we actually have.  This may be required if
 *   running behind a NAT or similar.
 *
 * bind_address
 *
 *   The address to which we bind our network socket. The default is
 *   INADDR_ANY, but in some cases we may want to only listen on a particular
 *   address, in which case, specify on the command line using the "-ip"
 *   option.
 *
 * broadcast_address
 *
 *   This is only set if bind_address has been set.  We set it to the
 *   broadcast address that matches the given IP.
 */
static netadr_t localip_address;
static netadr_t bind_address;
static netadr_t broadcast_address;

/*
 * Keep a list of local addresses we use for sending out packets.  If
 * this machine has multiple interfaces, different sending addresses
 * may be used for sending to different networks.
 */
struct local_address {
    struct in_addr address;
    struct in_addr broadcast;
    char interface_name[IFNAMSIZ];
};

static struct local_address *local_addresses;
static int num_local_addresses;

static void
UDP_PrintLocalAddresses()
{
#ifdef DEBUG
    struct local_address *local = local_addresses;
    for (int i = 0; i < num_local_addresses; i++, local++) {
        const char *address = va("%s", inet_ntoa(local->address));
        const char *broadcast = va("%s", inet_ntoa(local->broadcast));
        Sys_Printf("UDP %*s: %s/%s\n", IFNAMSIZ, local->interface_name, address, broadcast);
    }
#endif
}

static int
UDP_InitLocalAddresses(int socket_fd)
{
    int result, count;
    struct ifaddrs *interfaces, *interface;

    if (local_addresses) {
        Z_Free(mainzone, local_addresses);
        local_addresses = NULL;
        num_local_addresses = 0;
    }

    /* Query all network addresses and copy all IPv4 ones we can use */
    result = getifaddrs(&interfaces);
    if (result == -1) {
        NET_Debug("%s: Failed to query network interface configuration\n", __func__);
        return -1;
    }
    count = 0;
    for (interface = interfaces; interface; interface = interface->ifa_next) {
	if (!(interface->ifa_flags & IFF_UP))
	    continue;
	if (!interface->ifa_addr || interface->ifa_addr->sa_family != AF_INET)
	    continue;
	count++;
    }
    if (!count) {
        NET_Debug("%s: No network interfaces/addresses to query\n", __func__);
	freeifaddrs(interfaces);
        return -1;
    }

    NET_Debug("%s: Found %d addresses\n", __func__, count);
    local_addresses = Z_Malloc(mainzone, count * sizeof(*local_addresses));
    if (!local_addresses) {
        NET_Debug("Not enough memory for UDP configuration.\n");
        freeifaddrs(interfaces);
        return -1;
    }

    struct local_address *local_address = local_addresses;
    for (interface = interfaces; interface; interface = interface->ifa_next) {
	if (!(interface->ifa_flags & IFF_UP))
	    continue;
	if (!interface->ifa_addr || interface->ifa_addr->sa_family != AF_INET)
	    continue;
        local_address->address = ((struct sockaddr_in *)interface->ifa_addr)->sin_addr;

        /* Check if the address has a valid broadcast address */
	if ((interface->ifa_flags & IFF_BROADCAST) && interface->ifa_dstaddr) {
            local_address->broadcast = ((struct sockaddr_in *)interface->ifa_dstaddr)->sin_addr;
        } else {
            /* Fallback to the generic broadcast address */
            local_address->broadcast.s_addr = INADDR_BROADCAST;
        }

        /* If this address was specifically bound to, then save the broadcast address */
        if (local_address->address.s_addr == bind_address.ip.l) {
            broadcast_address.ip.l = local_address->broadcast.s_addr;
            broadcast_address.port = htons(net_hostport);
        }

        /* Save the interface name */
        qstrncpy(local_address->interface_name, interface->ifa_name, sizeof(local_address->interface_name));
	local_address++;
    }
    num_local_addresses = local_address - local_addresses;
    freeifaddrs(interfaces);

    UDP_PrintLocalAddresses();

    return 0;
}

static void
NetadrToSockadr(const netadr_t *a, struct sockaddr_in *s)
{
    memset(s, 0, sizeof(*s));
    s->sin_family = AF_INET;
    s->sin_addr.s_addr = a->ip.l;
    s->sin_port = a->port;
}

static void
SockadrToNetadr(const struct sockaddr_in *s, netadr_t *a)
{
    a->ip.l = s->sin_addr.s_addr;
    a->port = s->sin_port;
}

int
UDP_Init(void)
{
    int i;

    if (COM_CheckParm("-noudp"))
	return -1;

    bind_address.ip.l = INADDR_ANY;
    i = COM_CheckParm("-ip");
    if (i && i < com_argc - 1) {
	bind_address.ip.l = inet_addr(com_argv[i + 1]);
	if (bind_address.ip.l == INADDR_NONE)
	    Sys_Error("%s: %s is not a valid IP address", __func__, com_argv[i + 1]);
	Con_Printf("%s: requested bind to %s via command line\n", __func__, com_argv[i + 1]);
    }

    localip_address.ip.l = INADDR_NONE;
    i = COM_CheckParm("-localip");
    if (i && i < com_argc - 1) {
	localip_address.ip.l = inet_addr(com_argv[i + 1]);
	if (localip_address.ip.l == INADDR_NONE)
	    Sys_Error("%s: %s is not a valid IP address", __func__, com_argv[i + 1]);
	Con_Printf("%s: will advertise %s as the local IP in response packets\n", __func__, com_argv[i + 1]);
    }

    net_controlsocket = UDP_OpenSocket(0);
    if (net_controlsocket == -1) {
	Con_Printf("%s: Unable to open control socket, UDP disabled\n", __func__);
	return -1;
    }

    UDP_InitLocalAddresses(net_controlsocket);

    Con_Printf("%s: Success\n",  __func__);
    tcpipAvailable = true;

    return net_controlsocket;
}


void
UDP_Shutdown(void)
{
    UDP_Listen(false);
    UDP_CloseSocket(net_controlsocket);
}


void
UDP_Listen(qboolean state)
{
    /* enable listening */
    if (state) {
	if (net_acceptsocket != -1)
	    return;
	if ((net_acceptsocket = UDP_OpenSocket(net_hostport)) == -1)
	    Sys_Error("%s: Unable to open accept socket", __func__);
	return;
    }
    /* disable listening */
    if (net_acceptsocket == -1)
	return;
    UDP_CloseSocket(net_acceptsocket);
    net_acceptsocket = -1;
}


int
UDP_OpenSocket(int port)
{
    int newsocket;
    struct sockaddr_in address;
    int _true = 1;

    if ((newsocket = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
	return -1;
    if (ioctl(newsocket, FIONBIO, &_true) == -1)
	goto ErrorReturn;

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = bind_address.ip.l;
    address.sin_port = htons((unsigned short)port);
    if (bind(newsocket, (struct sockaddr *)&address, sizeof(address)) == -1)
	goto ErrorReturn;

    return newsocket;

  ErrorReturn:
    close(newsocket);
    return -1;
}


int
UDP_CloseSocket(int socket)
{
    if (socket == net_broadcastsocket)
	net_broadcastsocket = 0;
    return close(socket);
}


int
UDP_CheckNewConnections(void)
{
    unsigned long available;
    struct sockaddr_in from;
    socklen_t fromlen;
    char buff[1];

    if (net_acceptsocket == -1)
	return -1;

    if (ioctl(net_acceptsocket, FIONREAD, &available) == -1)
	Sys_Error("%s: ioctlsocket (FIONREAD) failed", __func__);
    if (available)
	return net_acceptsocket;

    /* quietly absorb empty packets */
    recvfrom (net_acceptsocket, buff, 0, 0, (struct sockaddr *)&from, &fromlen);
    return -1;
}

int
UDP_IsMyAddress(const netadr_t *address)
{
    for (int i = 0; i < num_local_addresses; i++) {
        struct local_address *local_address = &local_addresses[i];
        if (local_address->address.s_addr == address->ip.l)
            return true;
    }

    return false;
}

int
UDP_Read(int socket, void *buf, int len, netadr_t *addr)
{
    struct sockaddr_in saddr;
    socklen_t addrlen = sizeof(saddr);
    int ret;

    ret = recvfrom(socket, buf, len, 0, (struct sockaddr *)&saddr, &addrlen);
    SockadrToNetadr(&saddr, addr);
    if (ret == -1 && (errno == EWOULDBLOCK || errno == ECONNREFUSED))
	return 0;
    return ret;
}


static int
UDP_MakeSocketBroadcastCapable(int socket)
{
    int i = 1;

    /* make this socket broadcast capable */
    if (setsockopt(socket, SOL_SOCKET, SO_BROADCAST, &i, sizeof(i)) < 0)
	return -1;
    net_broadcastsocket = socket;

    return 0;
}


int
UDP_Broadcast(int socket, const void *buf, int len)
{
    if (socket != net_broadcastsocket) {
	if (net_broadcastsocket != 0)
	    Sys_Error("Attempted to use multiple broadcasts sockets");
	int ret = UDP_MakeSocketBroadcastCapable(socket);
	if (ret == -1) {
	    Con_Printf("Unable to make socket broadcast capable\n");
	    return ret;
	}
    }

    /* If bound to a specific IP, then just broadcast to that one network */
    if (bind_address.ip.l != INADDR_ANY) {
        NET_Debug("%s: Broadcasting to %s\n", __func__, StrAddr(&broadcast_address));
        return UDP_Write(socket, buf, len, &broadcast_address);
    }

    /* Otherwise, we broadcast to all networks */
    int written = 0;
    for (int i = 0; i < num_local_addresses; i++) {
        const netadr_t broadcast = {
            .ip.l = local_addresses[i].broadcast.s_addr,
            .port = htons(net_hostport),
        };
        NET_Debug("%s: Broadcasting to %s\n", __func__, StrAddr(&broadcast));
        int result = UDP_Write(socket, buf, len, &broadcast);
        if (result > 0)
            written += result;
    }

    return written;
}


int
UDP_Write(int socket, const void *buf, int len, const netadr_t *addr)
{
    struct sockaddr_in saddr;
    int ret;

    NetadrToSockadr(addr, &saddr);
    ret = sendto(socket, buf, len, 0, (struct sockaddr *)&saddr, sizeof(saddr));
    if (ret == -1 && errno == EWOULDBLOCK)
	return 0;
    return ret;
}


int
UDP_GetSocketAddr(int socket_fd, netadr_t *addr, const netadr_t *remote)
{
    int result, dummy;
    socklen_t length;
    struct sockaddr_in saddr;

    /* Get socket info.  We will at least use the port part */
    length = sizeof(saddr);
    result = getsockname(socket_fd, (struct sockaddr *)&saddr, &length);
    if (result == -1) {
        NET_Debug("%s: getsockname failed\n", __func__);
        goto fail;
    }
    if (length != sizeof(saddr)) {
        NET_Debug("%s: getsockname returned wrong length (expected %d, got %d)\n",
                  __func__, (int)sizeof(saddr), (int)length);
        goto fail;
    }
    addr->port = saddr.sin_port;

    /* If we are faking our IP address, then we return that instead of the real address */
    if (localip_address.ip.l != INADDR_NONE) {
        addr->ip.l = localip_address.ip.l;
        return 0;
    }

    /* If we have bound to a specific IP, then we can return the result from getsockname */
    if (bind_address.ip.l != INADDR_ANY) {
        addr->ip.l = saddr.sin_addr.s_addr;
        return 0;
    }

    /*
     * To find out what address we would send from to this remote address,
     * open a dummy connection and query the socket address.
     */
    dummy = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (dummy == -1) {
        NET_Debug("%s: couldn't create a dummy socket!\n", __func__);
        goto fail;
    }

    NetadrToSockadr(remote, &saddr);
    result = connect(dummy, (struct sockaddr *)&saddr, sizeof(saddr));
    if (result == -1) {
        NET_Debug("%s: unable to connect to remote\n", __func__);
        goto close_fail;
    }

    length = sizeof(saddr);
    result = getsockname(dummy, (struct sockaddr *)&saddr, &length);
    close(dummy);
    if (result == -1) {
        NET_Debug("%s: getsockname failed on dummy socket\n", __func__);
        goto fail;
    }
    if (length != sizeof(saddr)) {
        NET_Debug("%s: getsockname on dummy socket returned wrong length (expected %d, got %d)\n",
                  __func__, (int)sizeof(saddr), (int)length);
        goto fail;
    }

    addr->ip.l = saddr.sin_addr.s_addr;
    return 0;

 close_fail:
    close(dummy);
 fail:
    addr->ip.l = INADDR_ANY;
    addr->port = htons(net_hostport);
    return -1;
}


int
UDP_GetNameFromAddr(const netadr_t *addr, char *name)
{
    struct hostent *hostentry;

    hostentry = gethostbyaddr(&addr->ip.l, sizeof(addr->ip.l), AF_INET);
    if (hostentry) {
	strncpy(name, (char *)hostentry->h_name, NET_NAMELEN - 1);
	return 0;
    }
    strcpy(name, NET_AdrToString(addr));

    return 0;
}


int
UDP_GetAddrFromName(const char *name, netadr_t *addr)
{
    struct hostent *hostentry;

    if (name[0] >= '0' && name[0] <= '9') {
        const netadr_t *my_address = (bind_address.ip.l != INADDR_ANY) ? &bind_address : NULL;
	return NET_PartialIPAddress(name, my_address, addr);
    }

    hostentry = gethostbyname(name);
    if (!hostentry)
	return -1;

    addr->ip.l = *(int *)hostentry->h_addr_list[0];
    addr->port = htons(net_hostport);

    return 0;
}


int
UDP_GetDefaultMTU(void)
{
    return 1400;
}
