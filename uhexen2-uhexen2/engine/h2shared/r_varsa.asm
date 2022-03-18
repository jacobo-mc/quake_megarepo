;
; r_varsa.asm
; global refresh variables
;
; this file uses NASM syntax.
;
; Copyright (C) 1996-1997  Id Software, Inc.
; Copyright (C) 1997-1998  Raven Software Corp.
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;
; See the GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to:
; Free Software Foundation, Inc.
; 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
;

%include "asm_nasm.inc"

; underscore prefix handling
; for C-shared symbols:
%ifmacro _sym_prefix
; C-shared externs:
; C-shared globals:
 _sym_prefix r_bmodelactive
 _sym_prefix FoundTrans
%endif	; _sym_prefix

SEGMENT .data

;
; ASM-only variables
;
 global float_1, float_particle_z_clip, float_point5
 global float_minus_1, float_0
float_0 dd 0.0
float_1 dd 1.0
float_minus_1 dd -1.0
float_particle_z_clip dd 8.0
float_point5 dd 0.5

 global fp_16, fp_64k, fp_1m, fp_64kx64k
 global fp_1m_minus_1
 global fp_8
fp_1m dd 1048576.0
fp_1m_minus_1 dd 1048575.0
fp_64k dd 65536.0
fp_8 dd 8.0
fp_16 dd 16.0
fp_64kx64k dd 04f000000h

 global FloatZero, Float2ToThe31nd, FloatMinus2ToThe31nd
FloatZero dd 0
Float2ToThe31nd dd 04f000000h
FloatMinus2ToThe31nd dd 0cf000000h

;
; C-shared variables
;
 global r_bmodelactive
r_bmodelactive dd 0

 global FoundTrans
FoundTrans dd 0

