;
; r_edgeb.asm -- for MASM
; x86 assembly-language edge-processing code.
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

 .386P
 .model FLAT
; externs from C code
 externdef _r_bmodelactive:dword
 externdef _surfaces:dword
 externdef _edge_tail:dword
 externdef _edge_aftertail:dword
 externdef _edge_head:dword
 externdef _edge_head_u_shift20:dword
 externdef _edge_tail_u_shift20:dword
 externdef _current_iv:dword
 externdef _span_p:dword
 externdef _fv:dword

; externs from ASM-only code

_DATA SEGMENT
Ltemp dd 0
float_1_div_0100000h dd 035800000h
float_point_999 dd 0.999
float_1_point_001 dd 1.001
_DATA ENDS
_TEXT SEGMENT
 align 4
 public _R_EdgeCodeStartT
_R_EdgeCodeStartT:
TrailingEdge:
 mov eax,ds:dword ptr[20+esi]
 dec eax
 jnz LInverted
 mov ds:dword ptr[20+esi],eax
 mov ecx,ds:dword ptr[40+esi]
 mov edx,ds:dword ptr[12345678h]
LPatch0:
 mov eax,ds:dword ptr[_r_bmodelactive]
 sub eax,ecx
 cmp edx,esi
 mov ds:dword ptr[_r_bmodelactive],eax
 jnz LNoEmit
 mov eax,ds:dword ptr[0+ebx]
 shr eax,20
 mov edx,ds:dword ptr[16+esi]
 mov ecx,ds:dword ptr[0+esi]
 cmp eax,edx
 jle LNoEmit2

;rj
 bt ds:dword ptr[24+esi],7   ; surf->flags & SURF_TRANSLUCENT
 jnc LNoEmit2

 mov ds:dword ptr[16+ecx],eax
 sub eax,edx
 mov ds:dword ptr[0+ebp],edx
 mov ds:dword ptr[8+ebp],eax
 mov eax,ds:dword ptr[_current_iv]
 mov ds:dword ptr[4+ebp],eax
 mov eax,ds:dword ptr[8+esi]
 mov ds:dword ptr[12+ebp],eax
 mov ds:dword ptr[8+esi],ebp
 add ebp,16
 mov edx,ds:dword ptr[0+esi]
 mov esi,ds:dword ptr[4+esi]
 mov ds:dword ptr[0+esi],edx
 mov ds:dword ptr[4+edx],esi
 ret
LNoEmit2:
 mov ds:dword ptr[16+ecx],eax
 mov edx,ds:dword ptr[0+esi]
 mov esi,ds:dword ptr[4+esi]
 mov ds:dword ptr[0+esi],edx
 mov ds:dword ptr[4+edx],esi
 ret
LNoEmit:
 mov edx,ds:dword ptr[0+esi]
 mov esi,ds:dword ptr[4+esi]
 mov ds:dword ptr[0+esi],edx
 mov ds:dword ptr[4+edx],esi
 ret
LInverted:
 mov ds:dword ptr[20+esi],eax
 ret

Lgs_trailing:
 push offset Lgs_nextedge
 jmp TrailingEdge
 public _R_GenerateTSpans
_R_GenerateTSpans:
 push ebp
 push edi
 push esi
 push ebx
 mov eax,ds:dword ptr[_surfaces]
 mov edx,ds:dword ptr[_edge_head_u_shift20]
 add eax,64
 mov ebp,ds:dword ptr[_span_p]
 mov ds:dword ptr[_r_bmodelactive],0
 mov ds:dword ptr[0+eax],eax
 mov ds:dword ptr[4+eax],eax
 mov ds:dword ptr[16+eax],edx
 mov ebx,ds:dword ptr[_edge_head+12]
 cmp ebx,offset _edge_tail
 jz Lgs_lastspan
Lgs_edgeloop:
 mov edi,ds:dword ptr[16+ebx]
 mov eax,ds:dword ptr[_surfaces]
 mov esi,edi
 and edi,0FFFF0000h
 and esi,0FFFFh
 jz Lgs_leading
 shl esi,6
 add esi,eax
 test edi,edi
 jz Lgs_trailing
 call near ptr TrailingEdge
 mov eax,ds:dword ptr[_surfaces]
Lgs_leading:
 shr edi,16-6
 mov eax,ds:dword ptr[_surfaces]
 add edi,eax
 mov esi,ds:dword ptr[12345678h]
LPatch2:
 mov edx,ds:dword ptr[20+edi]
 mov eax,ds:dword ptr[40+edi]
 test eax,eax
 jnz Lbmodel_leading
 test edx,edx
 jnz Lxl_done
 inc edx
 mov eax,ds:dword ptr[12+edi]
 mov ds:dword ptr[20+edi],edx
 mov ecx,ds:dword ptr[12+esi]
 cmp eax,ecx
 jl Lnewtop
Lsortloopnb:
 mov esi,ds:dword ptr[0+esi]
 mov ecx,ds:dword ptr[12+esi]
 cmp eax,ecx
 jge Lsortloopnb
 jmp LInsertAndExit
 align 4
Lbmodel_leading:
 test edx,edx
 jnz Lxl_done
 mov ecx,ds:dword ptr[_r_bmodelactive]
 inc edx
 inc ecx
 mov ds:dword ptr[20+edi],edx
 mov ds:dword ptr[_r_bmodelactive],ecx
 mov eax,ds:dword ptr[12+edi]
 mov ecx,ds:dword ptr[12+esi]
 cmp eax,ecx
 jl Lnewtop
 jz Lzcheck_for_newtop
Lsortloop:
 mov esi,ds:dword ptr[0+esi]
 mov ecx,ds:dword ptr[12+esi]
 cmp eax,ecx
 jg Lsortloop
 jne LInsertAndExit
 mov eax,ds:dword ptr[0+ebx]
 sub eax,0FFFFFh
 mov ds:dword ptr[Ltemp],eax
 fild ds:dword ptr[Ltemp]
 fmul ds:dword ptr[float_1_div_0100000h]
 fld st(0)
 fmul ds:dword ptr[48+edi]
 fld ds:dword ptr[_fv]
 fmul ds:dword ptr[52+edi]
 fxch st(1)
 fadd ds:dword ptr[44+edi]
 fld ds:dword ptr[48+esi]
 fmul st(0),st(3)
 fxch st(1)
 faddp st(2),st(0)
 fld ds:dword ptr[_fv]
 fmul ds:dword ptr[52+esi]
 fld st(2)
 fmul ds:dword ptr[float_point_999]
 fxch st(2)
 fadd ds:dword ptr[44+esi]
 faddp st(1),st(0)
 fxch st(1)
 fcomp st(1)
 fxch st(1)
 fmul ds:dword ptr[float_1_point_001]
 fxch st(1)
 fnstsw ax
 test ah,001h
 jz Lgotposition_fpop3
 fcomp st(1)
 fnstsw ax
 test ah,045h
 jz Lsortloop_fpop2
 fld ds:dword ptr[48+edi]
 fcomp ds:dword ptr[48+esi]
 fnstsw ax
 test ah,001h
 jz Lgotposition_fpop2
 fstp st(0)
 fstp st(0)
 mov eax,ds:dword ptr[12+edi]
 jmp Lsortloop
Lgotposition_fpop3:
 fstp st(0)
Lgotposition_fpop2:
 fstp st(0)
 fstp st(0)
 jmp LInsertAndExit
Lnewtop_fpop3:
 fstp st(0)
Lnewtop_fpop2:
 fstp st(0)
 fstp st(0)
 mov eax,ds:dword ptr[12+edi]
Lnewtop:
 mov eax,ds:dword ptr[0+ebx]
 mov edx,ds:dword ptr[16+esi]
 shr eax,20
 mov ds:dword ptr[16+edi],eax
 cmp eax,edx
 jle LInsertAndExit

;rj
 bt ds:dword ptr[24+esi],7   ; surf->flags & SURF_TRANSLUCENT
 jnc LInsertAndExit

 sub eax,edx
 mov ds:dword ptr[0+ebp],edx
 mov ds:dword ptr[8+ebp],eax
 mov eax,ds:dword ptr[_current_iv]
 mov ds:dword ptr[4+ebp],eax
 mov eax,ds:dword ptr[8+esi]
 mov ds:dword ptr[12+ebp],eax
 mov ds:dword ptr[8+esi],ebp
 add ebp,16
LInsertAndExit:
 mov ds:dword ptr[0+edi],esi
 mov eax,ds:dword ptr[4+esi]
 mov ds:dword ptr[4+edi],eax
 mov ds:dword ptr[4+esi],edi
 mov ds:dword ptr[0+eax],edi
Lgs_nextedge:
 mov ebx,ds:dword ptr[12+ebx]
 cmp ebx,offset _edge_tail
 jnz Lgs_edgeloop
Lgs_lastspan:
 mov esi,ds:dword ptr[12345678h]
LPatch3:
 mov eax,ds:dword ptr[_edge_tail_u_shift20]
 xor ecx,ecx
 mov edx,ds:dword ptr[16+esi]
 sub eax,edx
 jle Lgs_resetspanstate

;rj
 bt ds:dword ptr[24+esi],7   ; surf->flags & SURF_TRANSLUCENT
 jnc Lgs_resetspanstate

 mov ds:dword ptr[0+ebp],edx
 mov ds:dword ptr[8+ebp],eax
 mov eax,ds:dword ptr[_current_iv]
 mov ds:dword ptr[4+ebp],eax
 mov eax,ds:dword ptr[8+esi]
 mov ds:dword ptr[12+ebp],eax
 mov ds:dword ptr[8+esi],ebp
 add ebp,16
Lgs_resetspanstate:
 mov ds:dword ptr[20+esi],ecx
 mov esi,ds:dword ptr[0+esi]
 cmp esi,012345678h
LPatch4:
 jnz Lgs_resetspanstate
 mov ds:dword ptr[_span_p],ebp
 pop ebx
 pop esi
 pop edi
 pop ebp
 ret
 align 4
Lxl_done:
 inc edx
 mov ds:dword ptr[20+edi],edx
 jmp Lgs_nextedge
 align 4
Lzcheck_for_newtop:
 mov eax,ds:dword ptr[0+ebx]
 sub eax,0FFFFFh
 mov ds:dword ptr[Ltemp],eax
 fild ds:dword ptr[Ltemp]
 fmul ds:dword ptr[float_1_div_0100000h]
 fld st(0)
 fmul ds:dword ptr[48+edi]
 fld ds:dword ptr[_fv]
 fmul ds:dword ptr[52+edi]
 fxch st(1)
 fadd ds:dword ptr[44+edi]
 fld ds:dword ptr[48+esi]
 fmul st(0),st(3)
 fxch st(1)
 faddp st(2),st(0)
 fld ds:dword ptr[_fv]
 fmul ds:dword ptr[52+esi]
 fld st(2)
 fmul ds:dword ptr[float_point_999]
 fxch st(2)
 fadd ds:dword ptr[44+esi]
 faddp st(1),st(0)
 fxch st(1)
 fcomp st(1)
 fxch st(1)
 fmul ds:dword ptr[float_1_point_001]
 fxch st(1)
 fnstsw ax
 test ah,001h
 jz Lnewtop_fpop3
 fcomp st(1)
 fnstsw ax
 test ah,045h
 jz Lsortloop_fpop2
 fld ds:dword ptr[48+edi]
 fcomp ds:dword ptr[48+esi]
 fnstsw ax
 test ah,001h
 jz Lnewtop_fpop2
Lsortloop_fpop2:
 fstp st(0)
 fstp st(0)
 mov eax,ds:dword ptr[12+edi]
 jmp Lsortloop
 public _R_EdgeCodeEndT
_R_EdgeCodeEndT:
 align 4

 public _R_SurfacePatchT
_R_SurfacePatchT:
 mov eax,ds:dword ptr[_surfaces]
 add eax,64
 mov ds:dword ptr[LPatch4-4],eax
 add eax,0
 mov ds:dword ptr[LPatch0-4],eax
 mov ds:dword ptr[LPatch2-4],eax
 mov ds:dword ptr[LPatch3-4],eax
 ret

_TEXT ENDS
 END
