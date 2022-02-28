// entities.c

#include "havocmap.h"

entity_t	entities[MAX_MAP_ENTITIES];
int			num_entities;

/*
==============================================================================

ENTITY FILE PARSING

If a light has a targetname, generate a unique style in the 32-63 range
==============================================================================
*/

int		numlighttargets;
char	lighttargets[32][64];

int LightStyleForTargetname (char *targetname, qboolean alloc)
{
	int		i;

	for (i=0 ; i<numlighttargets ; i++)
		if (!strcmp (lighttargets[i], targetname))
			return 32 + i;
	if (!alloc)
		return -1;
	strcpy (lighttargets[i], targetname);
	numlighttargets++;
	return numlighttargets-1 + 32;
}


/*
==================
MatchTargets
==================
*/
void MatchTargets (void)
{
	int		i,j;

	for (i=0 ; i<num_entities ; i++)
	{
		if (!entities[i].target[0])
			continue;

		for (j=0 ; j<num_entities ; j++)
			if (!strcmp(entities[j].targetname, entities[i].target))
			{
				entities[i].targetent = &entities[j];
				break;
			}

		if (j==num_entities)
		{
			printf ("WARNING: entity at (%i,%i,%i) (%s) has unmatched target\n", (int)entities[i].origin[0], (int)entities[i].origin[1], (int)entities[i].origin[2], entities[i].classname);
			continue;
		}

		// set the style on the source ent for switchable lights
		if (entities[j].style)
		{
			char	s[16];
			entities[i].style = entities[j].style;
			sprintf (s,"%i", entities[i].style);
			SetKeyValue (&entities[i], "style", s);
		}
	}	
}


/*
==================
LoadEntities
==================
*/
/*
void LoadEntities (void)
{
	char 		*data;
	entity_t	*entity;
	char		key[64];	
	epair_t		*epair;
	double		vec[3];
	double		temp;
	int			i;

	data = dentdata;
	//
	// start parsing
	//
	num_entities = 0;

	// go through all the entities
	while (1)
	{
		// parse the opening brace	
		data = COM_Parse (data);
		if (!data)
			break;
		if (com_token[0] != '{')
			Error ("LoadEntities: found %s when expecting {",com_token);

		if (num_entities == MAX_MAP_ENTITIES)
			Error ("LoadEntities: MAX_MAP_ENTITIES");
		entity = &entities[num_entities];
		num_entities++;

		// go through all the keys in this entity
		while (1)
		{
			int		c;

			// parse key
			data = COM_Parse (data);
			if (!data)
				Error ("LoadEntities: EOF without closing brace");
			if (!strcmp(com_token,"}"))
				break;
			strcpy (key, com_token);

			// parse value
			data = COM_Parse (data);
			if (!data)
				Error ("LoadEntities: EOF without closing brace");
			c = com_token[0];
			if (c == '}')
				Error ("LoadEntities: closing brace without data");

			epair = calloc (1, sizeof(epair_t));
//			memset (epair, 0, sizeof(epair_t));
			strcpy (epair->key, key);
			strcpy (epair->value, com_token);
			epair->next = entity->epairs;
			entity->epairs = epair;

			if (!strcmp(key, "classname"))
				strcpy (entity->classname, com_token);
			else if (!strcmp(key, "target"))
				strcpy (entity->target, com_token);			
			else if (!strcmp(key, "targetname"))
				strcpy (entity->targetname, com_token);
			else if (!strcmp(key, "origin"))
			{
				// scan into doubles, then assign
				// which makes it vec_t size independent
				if (sscanf(com_token, "%lf %lf %lf", &vec[0], &vec[1], &vec[2]) != 3)
					Error ("LoadEntities: not 3 values for origin");
				for (i=0 ; i<3 ; i++)
				entity->origin[i] = vec[i];
			}
			else if (!strncmp(key, "light", 5) || !strcmp (key, "_light") )
				entity->light = atof(com_token);
			else if (!strcmp (key, "wait") )
			{
				entity->falloff = atof(com_token);
				entity->falloff *= entity->falloff; // square it for lighting calculations
			}
			else if (!strcmp(key, "style"))
			{
				entity->style = atof(com_token);
				if ((unsigned)entity->style > 254)
					Error ("Bad light style %i (must be 0-254)", entity->style);
			}
			else if (!strcmp(key, "angle"))
				entity->angle = atof(com_token);
			else if (!strcmp(key, "color") || !strcmp (key, "_color"))
			{
				// scan into doubles, then assign
				// which makes it vec_t size independent
				if (sscanf(com_token, "%lf %lf %lf", &vec[0], &vec[1], &vec[2]) != 3)
					Error ("LoadEntities: not 3 values for color");
				// scale the color to have at least one component at 1.0
				temp = vec[0];
				if (vec[1] > temp)
					temp = vec[1];
				if (vec[2] > temp)
					temp = vec[2];
				if (temp != 0.0)
					temp = 1.0 / temp;
				for (i=0 ; i<3 ; i++)
					entity->color[i] = vec[i] * temp;
			}
		}

		// all fields have been parsed
		if (!strncmp (entity->classname, "light", 5))
		{
			if (!entity->light)
				entity->light = DEFAULTLIGHTLEVEL;
			// LordHavoc: added falloff and color
			if (!entity->falloff)
				entity->falloff = DEFAULTFALLOFF * DEFAULTFALLOFF;
			if (!entity->color[0] && !entity->color[1] && !entity->color[2])
				entity->color[0] = entity->color[1] = entity->color[2] = 1.0f;
		}

		if (!strcmp (entity->classname, "light"))
			if (entity->targetname[0] && !entity->style)
			{
				char	s[16];
				entity->style = LightStyleForTargetname (entity->targetname, true);
				sprintf (s,"%i", entity->style);
				SetKeyValue (entity, "style", s);
			}
	}

	printf ("%d entities read\n", num_entities);

	MatchTargets ();
}
*/
