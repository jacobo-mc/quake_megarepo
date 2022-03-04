#include "QF/dstring.h"
#include "QF/hash.h"
#include "QF/script.h"
#include "QF/sys.h"
#include "QF/va.h"

#include "Entity.h"
#include "EntityClass.h"
#include "TexturePalette.h"
#include "SetBrush.h"
#include "Map.h"
#include "CameraView.h"

#define THING Entity
#include "THING+NSArray.m"

@implementation Entity

vec3_t  bad_mins = {-8, -8, -8};
vec3_t  bad_maxs = {8, 8, 8};

- (id) createFixedBrush: (vec3_t)org
{
	vec3_t          emins, emaxs;
	float           *v, *v2, *color;
	id              new;
	texturedef_t    td;

	// get class
	new = [entity_classes_i classForName: [self valueForQKey: "classname"]];
	if (new) {
		v = [new mins];
		v2 = [new maxs];
	} else {
		v = bad_mins;
		v2 = bad_maxs;
	}

	color = [new drawColor];

	modifiable = NO;
	memset (&td, 0, sizeof (td));
	strcpy (td.texture, "entity");

	VectorAdd (org, v, emins);
	VectorAdd (org, v2, emaxs);
	new = [[SetBrush alloc] initOwner: self mins: emins maxs: emaxs texture: &td];
	[new setEntityColor: color];

	[self addObject: new];

	return self;
}

- (id) copyWithZone: (NSZone *) zone
{
	id          new, nb;
	epair_t     *e;
	int         i, c;

	new = [[Entity allocWithZone: zone] init];
	[new setModifiable: modifiable];

	for (e = epairs; e; e = e->next) {
		// don't copy target and targetname fields
		if (strncmp (e->key, "target", 6))
			[new setKey: e->key toValue: e->value];
	}

	c = [self count];
	for (i = 0; i < c; i++) {
		nb = [[self objectAtIndex: i] copy];
		[nb setParent: new];
		[new addObject: nb];
	}

	return new;
}

static const char *
epair_getkey (void *_ep, void *unused)
{
	epair_t    *ep = (epair_t *) _ep;
	return ep->key;
}

static void
epair_free (void *_ep, void *unused)
{
	epair_t    *ep = (epair_t *) _ep;
	free (ep->key);
	free (ep->value);
	if (ep->next)
		ep->next->prev = ep->prev;
	*ep->prev = ep->next;
	free (ep);
}

- (Entity *) initClass: (const char *)classname
{
	id          new;
	esize_t     esize;
	vec3_t      min, max;
	int         org[3];
	float       *v;

	self = [super init];
	array = [[NSMutableArray alloc] init];
	epair_tab = Hash_NewTable (61, epair_getkey, epair_free, 0);

	modifiable = YES;

	[self setKey: "classname" toValue: classname];

	// get class
	new = [entity_classes_i classForName: [self valueForQKey: "classname"]];
	if (!new)
		esize = esize_model;
	else
		esize = [new esize];

	// create a brush if needed
	if (esize == esize_fixed) {
		v = [new mins];
		[[map_i selectedBrush] getMins: min maxs: max];
		VectorSubtract (min, v, min);
		VectorCopy (min, org);

		// convert to integer
		[self setKey: "origin" toValue: va ("%i %i %i", org[0], org[1], org[2])];

		[self createFixedBrush: min];
	} else {
		modifiable = YES;
	}
	return self;
}

- (oneway void) dealloc
{
	Hash_DelTable (epair_tab);
	[array release];
	[super dealloc];
}

- (BOOL) modifiable
{
	return modifiable;
}

- (void) setModifiable: (BOOL)m
{
	modifiable = m;
	return;
}

- (void) removeObject: (id)o
{
	[super removeObject: o];
	if ([self count])
		return;

	// the entity is empty, so remove the entire thing
	if (self == [map_i objectAtIndex: 0])   // unless it's the world...
		return;

	[map_i removeObject: self];
	[self release];
}

- (const char *) valueForQKey: (const char *)k
{
	epair_t  *e;

	e = Hash_Find (epair_tab, k);
	if (e)
		return e->value;
	return "";
}

- (void) getVector: (vec3_t)v
   forKey: (const char *)k
{
	const char  *c;

	c = [self valueForQKey: k];
	v[0] = v[1] = v[2] = 0;

	sscanf (c, "%f %f %f", &v[0], &v[1], &v[2]);
}

- (id) print
{
	epair_t  *e;

	for (e = epairs; e; e = e->next)
		printf ("%20s : %20s\n", e->key, e->value);

	return self;
}

- (void) setKey: (const char *)k
   toValue: (const char *)v
{
	epair_t  *e;

	while (*k && *k <= ' ')
		k++;

	// don't set NULL values
	if (!*k)
		return;

	e = Hash_Find (epair_tab, k);
	if (e) {
		if (!strcmp (e->value, v))
			return;
		if (!strcmp (e->key, "targetname") && e->value[0])
			[map_i removeTarget: self];
		free (e->value);
		e->value = strdup (v);
		if (!strcmp (e->key, "targetname") && e->value[0])
			[map_i addTarget: self];
		return;
	}

	e = malloc (sizeof (epair_t));

	e->key = strdup (k);
	e->value = strdup (v);
	e->next = epairs;
	e->prev = &epairs;
	if (epairs)
		epairs->prev = &e->next;
	epairs = e;
	Hash_Add (epair_tab, e);
	if (!strcmp (e->key, "targetname") && e->value[0])
		[map_i addTarget: self];
}

- (int) numPairs
{
	int         i;
	epair_t     *e;

	i = 0;
	for (e = epairs; e; e = e->next)
		i++;

	return i;
}

- (epair_t *) epairs
{
	return epairs;
}

- (void) removeKeyPair: (char *)key
{
	epair_t  *e;

	if (!epairs)
		return;

	e = Hash_Del (epair_tab, key);
	if (e) {
		Hash_Free (epair_tab, e);
		return;
	}

	printf ("WARNING: removeKeyPair: %s not found\n", key);
	return;
}

/*
=============
targetname

If the entity does not have a "targetname" key, a unique one is generated
=============
*/
- (const char *) targetname
{
	const char  *t;
	int         i, count;
	id          ent;
	int         tval, maxt;

	t = [self valueForQKey: "targetname"];
	if (t && t[0])
		return t;

	// make a unique name of the form t<number>
	count = [map_i count];
	maxt = 0;
	for (i = 1; i < count; i++) {
		ent = [map_i objectAtIndex: i];
		t = [ent valueForQKey: "targetname"];
		if (!t || t[0] != 't')
			continue;
		tval = atoi (t + 1);
		if (tval > maxt)
			maxt = tval;
	}

	[self setKey: "targetname" toValue: va ("t%i", maxt + 1)];

	return [self valueForQKey: "targetname"];
}

/*
==============================================================================

FILE METHODS

==============================================================================
*/

int  nument;

- (Entity *) initFromScript: (script_t *)script
{
	char    *key;
	id      eclass, brush;
	const char      *spawn;
	vec3_t          emins, emaxs;
	vec3_t          org;
	texturedef_t    td;
	esize_t         esize;
	int             i, c;
	float           *color;

	self = [super init];
	array = [[NSMutableArray alloc] init];
	epair_tab = Hash_NewTable (61, epair_getkey, epair_free, 0);

	if (!Script_GetToken (script, true)) {
		[self dealloc];
		return nil;
	}

	if (strcmp (Script_Token (script), "{"))
		Sys_Error ("initFromScript: { not found");

	do {
		if (!Script_GetToken (script, true))
			break;
		if (!strcmp (Script_Token (script), "}"))
			break;
		if (!strcmp (Script_Token (script), "{")) {
			// read a brush
			brush = [[SetBrush alloc] initFromScript: script owner: self];
			[self addObject: brush];
		} else {
			// read a key / value pair
			key = strdup (Script_Token (script));
			Script_GetToken (script, false);
			[self setKey: key toValue: Script_Token (script)];
			free (key);
		}
	} while (1);

	nument++;

	// get class
	spawn = [self valueForQKey: "classname"];
	eclass = [entity_classes_i classForName: spawn];

	esize = [eclass esize];

	[self getVector: org forKey: "origin"];

	if ([self count] && esize != esize_model) {
		printf ("WARNING:Entity with brushes and wrong model type\n");
		[self removeAllObjects];
	}

	if (![self count] && esize == esize_model) {
		printf ("WARNING:Entity with no brushes and esize_model: %s\n",
		        [self valueForQKey: "classname"]);
		[texturepalette_i getTextureDef: &td];
		for (i = 0; i < 3; i++) {
			emins[i] = org[i] - 8;
			emaxs[i] = org[i] + 8;
		}
		brush =
		    [[SetBrush alloc] initOwner: self mins: emins maxs: emaxs texture: &td];
		[self addObject: brush];
	}

	// create a brush if needed
	if (esize == esize_fixed)
		[self createFixedBrush: org];
	else
		modifiable = YES;

	// set all the brush colors
	color = [eclass drawColor];

	c = [self count];
	for (i = 0; i < c; i++) {
		brush = [self objectAtIndex: i];
		[brush setEntityColor: color];
	}

	return self;
}

- (void) writeToFile: (QFile *)file
   region: (BOOL)reg;
{
	epair_t         *e;
	int             ang;
	unsigned int    i;
	id              new;
	vec3_t          mins, maxs;
	int             org[3];
	const vec_t     *v;
	char            *oldang = 0;

	if (reg) {
		if (!strcmp ([self valueForQKey: "classname"], "info_player_start")) {
			// move the playerstart temporarily to the camera position
			oldang = strdup ([self valueForQKey: "angle"]);
			ang = (int) ([cameraview_i yawAngle] * 180 / M_PI);
			[self setKey: "angle" toValue: va ("%i", ang)];
		} else if (self != [map_i objectAtIndex: 0]
		           && [[self objectAtIndex: 0] regioned]) {
			return; // skip the entire entity definition
		}
	}

	Qprintf (file, "{\n");

	// set an origin epair
	if (!modifiable) {
		[[self objectAtIndex: 0] getMins: mins maxs: maxs];
		if (oldang) {
			[cameraview_i getOrigin: mins];
			mins[0] -= 16;
			mins[1] -= 16;
			mins[2] -= 48;
		}
		new = [entity_classes_i classForName:
		       [self valueForQKey: "classname"]];
		if (new)
			v = [new mins];
		else
			v = vec3_origin;

		VectorSubtract (mins, v, org);
		[self setKey: "origin"
		     toValue: va ("%i %i %i", org[0], org[1], org[2])];
	}

	for (e = epairs; e; e = e->next)
		Qprintf (file, "\"%s\"\t\"%s\"\n", e->key, e->value);

	// fixed size entities don't save out brushes
	if (modifiable) {
		for (i = 0; i < [self count]; i++)
			[[self objectAtIndex: i] writeToFile: file region: reg];
	}

	Qprintf (file, "}\n");

	if (oldang) {
		[self setKey: "angle" toValue: oldang];
		free (oldang);
	}

	return;
}

/*
==============================================================================

INTERACTION

==============================================================================
*/

@end
