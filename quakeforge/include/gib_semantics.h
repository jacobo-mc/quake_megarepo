/*
	#FILENAME#

	#DESCRIPTION#

	Copyright (C) 2003 AUTHOR#

	Author: #AUTHOR#
	Date: #DATE#

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA

*/

#ifndef __GIB_SEMANTICS_H
#define __GIB_SEMANTICS_H

gib_tree_t *GIB_Semantic_Tokens_To_Lines (gib_tree_t *tokens, const char *program, gib_tree_flags_t flags, unsigned int start, unsigned int end);

#endif
