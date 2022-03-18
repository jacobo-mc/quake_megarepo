;
; sys_ia32.asm
; x86 assembly-language misc system routines.
; this file uses NASM syntax.
;
; Copyright (C) 1996-1997  Id Software, Inc.
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or (at
; your option) any later version.
;
; This program is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;
; See the GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License along
; with this program; if not, write to the Free Software Foundation, Inc.,
; 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
;

%include "asm_nasm.inc"

; underscore prefix handling
; for C-shared symbols:
%ifmacro _sym_prefix
; C-shared externs:
; C-shared globals:
 _sym_prefix MaskExceptions
 _sym_prefix Sys_LowFPPrecision
 _sym_prefix Sys_HighFPPrecision
 _sym_prefix Sys_PushFPCW_SetHigh
 _sym_prefix Sys_PopFPCW
 _sym_prefix Sys_SetFPCW
%endif	; _sym_prefix


SEGMENT .data
 ALIGN 4

fpenv:
 dd 0, 0, 0, 0, 0, 0, 0, 0


SEGMENT .text

 global MaskExceptions
MaskExceptions:
 fnstenv  [fpenv]
 or  dword [fpenv],03Fh
 fldenv   [fpenv]
 ret


SEGMENT .data

 ALIGN 4

 global ceil_cw, single_cw, full_cw, cw, pushed_cw
ceil_cw dd 0
single_cw dd 0
full_cw dd 0
cw dd 0
pushed_cw dd 0


SEGMENT .text

 global Sys_LowFPPrecision
Sys_LowFPPrecision:
 fldcw  word [single_cw]
 ret

 global Sys_HighFPPrecision
Sys_HighFPPrecision:
 fldcw  word [full_cw]
 ret

 global Sys_PushFPCW_SetHigh
Sys_PushFPCW_SetHigh:
 fnstcw  word [pushed_cw]
 fldcw  word [full_cw]
 ret

 global Sys_PopFPCW
Sys_PopFPCW:
 fldcw  word [pushed_cw]
 ret

 global Sys_SetFPCW
Sys_SetFPCW:
 fnstcw  word [cw]
 mov eax, dword [cw]
 and ah,0F0h
 or ah,003h
 mov  dword [full_cw],eax
 and ah,0F0h
 or ah,00Ch
 mov  dword [single_cw],eax
 and ah,0F0h
 or ah,008h
 mov  dword [ceil_cw],eax
 ret

