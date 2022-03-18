/*
 * net_dos.c --
 * from quake1 source with minor adaptations for uhexen2.
 *
 * Copyright (C) 1996-1997  Id Software, Inc.
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

#include "quakedef.h"

#include "dos_sock.h"
#include "net_defs.h"
#include "net_dgrm.h"
#include "net_ser.h"
#include "net_loop.h"

net_driver_t net_drivers[] =
{
#if !defined(NO_LOOP_DRIVER)
	{	"Loopback",
		false,
		Loop_Init,
		Loop_Listen,
#if !defined(SERVERONLY)
		Loop_SearchForHosts,
		Loop_Connect,
#endif	/* SERVERONLY */
		Loop_CheckNewConnections,
		Loop_GetMessage,
		Loop_SendMessage,
		Loop_SendUnreliableMessage,
		Loop_CanSendMessage,
		Loop_CanSendUnreliableMessage,
		Loop_Close,
		Loop_Shutdown
	},
#endif	/* NO_LOOP_DRIVER */

	{	"Datagram",
		false,
		Datagram_Init,
		Datagram_Listen,
#if !defined(SERVERONLY)
		Datagram_SearchForHosts,
		Datagram_Connect,
#endif	/* SERVERONLY */
		Datagram_CheckNewConnections,
		Datagram_GetMessage,
		Datagram_SendMessage,
		Datagram_SendUnreliableMessage,
		Datagram_CanSendMessage,
		Datagram_CanSendUnreliableMessage,
		Datagram_Close,
		Datagram_Shutdown
	},

#if defined(NET_USE_SERIAL)
	{	"Serial",
		false,
		Serial_Init,
		Serial_Listen,
#if !defined(SERVERONLY)
		Serial_SearchForHosts,
		Serial_Connect,
#endif	/* SERVERONLY */
		Serial_CheckNewConnections,
		Serial_GetMessage,
		Serial_SendMessage,
		Serial_SendUnreliableMessage,
		Serial_CanSendMessage,
		Serial_CanSendUnreliableMessage,
		Serial_Close,
		Serial_Shutdown
	}
#endif	/* NET_USE_SERIAL */
};

const int net_numdrivers = (sizeof(net_drivers) / sizeof(net_drivers[0]));


#include "net_ipx.h"
#ifdef USE_WATT32
#include "net_udp.h"
#endif

/* be careful about the order of drivers */
net_landriver_t	net_landrivers[] =
{
	{	"IPX",
		false,
		0,
		IPX_Init,
		IPX_Shutdown,
		IPX_Listen,
		IPX_OpenSocket,
		IPX_CloseSocket,
		IPX_Connect,
		IPX_CheckNewConnections,
		IPX_Read,
		IPX_Write,
		IPX_Broadcast,
		IPX_AddrToString,
		IPX_StringToAddr,
		IPX_GetSocketAddr,
		IPX_GetNameFromAddr,
		IPX_GetAddrFromName,
		IPX_AddrCompare,
		IPX_GetSocketPort,
		IPX_SetSocketPort
	},

#ifdef USE_WATT32
	{	"Waterloo TCP",
		false,
		0,
		UDP_Init,
		UDP_Shutdown,
		UDP_Listen,
		UDP_OpenSocket,
		UDP_CloseSocket,
		UDP_Connect,
		UDP_CheckNewConnections,
		UDP_Read,
		UDP_Write,
		UDP_Broadcast,
		UDP_AddrToString,
		UDP_StringToAddr,
		UDP_GetSocketAddr,
		UDP_GetNameFromAddr,
		UDP_GetAddrFromName,
		UDP_AddrCompare,
		UDP_GetSocketPort,
		UDP_SetSocketPort
	},
#endif /* USE_WATT32 */
};

const int net_numlandrivers = (sizeof(net_landrivers) / sizeof(net_landrivers[0]));

