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

#ifndef EZQUAKE_R_LIGHTMAPS_HEADER
#define EZQUAKE_R_LIGHTMAPS_HEADER

void R_BuildLightmaps(void);
qbool R_FullBrightAllowed(void);
void R_CheckReloadLightmaps(void);
void R_RenderAllDynamicLightmaps(struct model_s* model);
void R_LightmapFrameInit(void);
void R_ForceReloadLightMaps(void);
unsigned int R_LightmapCount(void);
struct msurface_s* R_DrawflatLightmapChain(int i);
void R_ClearDrawflatLightmapChain(int i);
void R_AddDrawflatChainSurface(struct msurface_s* surf, qbool floor);

#endif // EZQUAKE_R_LIGHTMAPS_HEADER
