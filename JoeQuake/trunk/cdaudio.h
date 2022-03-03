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
// cdaudio.h

int CDAudio_Init (void);
void CDAudio_Play (byte track, qboolean looping);
void CDAudio_Stop (void);
void CDAudio_Pause (void);
void CDAudio_Resume (void);
void CDAudio_Shutdown (void);
void CDAudio_Update (void);

// fmod related externals
extern qboolean fmod_loaded;
extern qboolean streamplaying;

qboolean FMOD_LoadLibrary(void);
void FMOD_Init(void);
void FMOD_Stop_Stream_f(void);
void FMOD_ChangeVolume(float value);
void FMOD_Stop_Stream_f(void);
void FMOD_PlayTrack(int track);
