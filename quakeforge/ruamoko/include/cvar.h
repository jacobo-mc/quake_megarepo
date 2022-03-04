#ifndef __ruamoko_cvar_h
#define __ruamoko_cvar_h

@extern float cvar (string s);
@extern void cvar_set (string var, string val);

@extern int Cvar_MakeAlias (string alias_name, string cvar_name);
@extern int Cvar_RemoveAlias (string alias_name);
@extern void Cvar_SetString (string varname, string value);
@extern void Cvar_SetFloat (string varname, float value);
@extern void Cvar_SetInteger (string varname, int value);
@extern void Cvar_SetVector (string varname, vector value);
@extern string Cvar_GetString (string varname);
@extern float Cvar_GetFloat (string varname);
@extern int Cvar_GetInteger (string varname);
@extern vector Cvar_GetVector (string varname);
@extern void Cvar_Toggle (string varname);

#endif//__ruamoko_cvar_h
