// ======================================
//
// QuakeEd Project Management
//
// ======================================

#include <unistd.h>

#include "QF/qfplist.h"
#include "QF/quakefs.h"
#include "QF/sys.h"
#include "QF/va.h"

#include "Project.h"
#include "Map.h"
#include "QuakeEd.h"
#include "Preferences.h"
#include "Dict.h"
#include "Things.h"
#include "TexturePalette.h"

id  project_i;

@implementation Project

- (id) init
{
	project_i = self;

	return self;
}

// ===========================================================
//
//  Project code
//
// ===========================================================
- (id) initVars
{
	NSString    *ts;

	ts = path_projectinfo;
	ts = path_basepath = [[ts stringByDeletingLastPathComponent] retain];

	path_progdir = [[ts stringByAppendingPathComponent: SUBDIR_ENT] retain];

	path_mapdirectory = [[ts stringByAppendingPathComponent: SUBDIR_MAPS] retain];
	path_finalmapdir = [[ts stringByAppendingPathComponent: SUBDIR_MAPS] retain];

	// in Project Inspector
	[basepathinfo_i setStringValue: ts];

#if 0  // FIXME: for "out-of-tree" projects ?
	if ((s = [projectInfo getStringFor: BASEPATHKEY])) {
		strcpy (path_basepath, s);

		strcpy (path_progdir, s);
		strcat (path_progdir, "/" SUBDIR_ENT);

		strcpy (path_mapdirectory, s);
		strcat (path_mapdirectory, "/" SUBDIR_MAPS); // source dir

		strcpy (path_finalmapdir, s);
		strcat (path_finalmapdir, "/" SUBDIR_MAPS); // dest dir

		[basepathinfo_i setStringValue: s];  // in Project Inspector
	}
#endif

	string_fullvis = [projectInfo getStringFor: BSPFULLVIS];
	string_fastvis = [projectInfo getStringFor: BSPFASTVIS];
	string_novis = [projectInfo getStringFor: BSPNOVIS];
	string_relight = [projectInfo getStringFor: BSPRELIGHT];
	string_leaktest = [projectInfo getStringFor: BSPLEAKTEST];
	string_entities = [projectInfo getStringFor: BSPENTITIES];

	// Build list of wads
	wadList = [projectInfo getArrayFor: WADSKEY];

	// Build list of maps & descriptions
	mapList = [projectInfo getArrayFor: MAPNAMESKEY];
	descList = [projectInfo getArrayFor: DESCKEY];

	[self initProjSettings];

	return self;
}

//  Init Project Settings fields
- (id) initProjSettings
{
	[pis_basepath_i setStringValue: path_basepath];
	[pis_fullvis_i setStringValue: [NSString stringWithCString: string_fullvis]];
	[pis_fastvis_i setStringValue: [NSString stringWithCString: string_fastvis]];
	[pis_novis_i setStringValue: [NSString stringWithCString: string_novis]];
	[pis_relight_i setStringValue: [NSString stringWithCString: string_relight]];
	[pis_leaktest_i setStringValue: [NSString stringWithCString: string_leaktest]];

	return self;
}

//  Add text to the BSP Output window
- (id) addToOutput: (const char *)string
{
	int  end;

	end = [BSPoutput_i textLength];
	[BSPoutput_i    replaceCharactersInRange: NSMakeRange (end, 0)
	                              withString: [NSString stringWithCString: string]];

	end = [BSPoutput_i textLength];
	[BSPoutput_i setSelectedRange: NSMakeRange (end, 0)];
	// XXX [BSPoutput_i scrollSelToVisible];

	return self;
}

- (id) clearBspOutput: sender
{
	int  end;

	end = [BSPoutput_i textLength];
	[BSPoutput_i replaceCharactersInRange: NSMakeRange (0, end) withString: @""];

	return self;
}

- (id) print
{
	// XXX [BSPoutput_i printPSCode:self];
	return self;
}

- (id) initProject
{
	[self parseProjectFile];
	if (projectInfo == NULL)
		return self;
	[self initVars];
	[mapbrowse_i setReusesColumns: YES];
	[mapbrowse_i loadColumnZero];
	[pis_wads_i setReusesColumns: YES];
	[pis_wads_i loadColumnZero];

	[things_i initEntities];

	return self;
}

//  Fill the QuakeEd Maps or wads browser
//  (Delegate method - delegated in Interface Builder)
- (void) browser: sender createRowsForColumn: (int)column inMatrix: matrix
{
	id          cell;
	plitem_t   *list;
	int         max;
	const char *name;
	int         i;

	if (sender == mapbrowse_i) {
		list = mapList;
	} else if (sender == pis_wads_i) {
		list = wadList;
	} else {
		list = 0;
		Sys_Error ("Project: unknown browser to fill");
	}

	max = list ? PL_A_NumObjects (list) : 0;
	for (i = 0; i < max; i++) {
		name = PL_String (PL_ObjectAtIndex (list, i));
		[matrix addRow];
		cell = [matrix cellAtRow: i column: 0];
		[cell setStringValue: [NSString stringWithCString: name]];
		[cell setLeaf: YES];
		[cell setLoaded: YES];
	}
}

//  Clicked on a map name or description!
- (id) clickedOnMap: sender
{
	id      matrix;
	int     row;
	NSString    *mapname;
	NSString    *fname;
	id              panel;
	NSModalSession  session;

	matrix = [sender matrixInColumn: 0];
	row = [matrix selectedRow];
	mapname = [NSString stringWithCString:
				PL_String (PL_ObjectAtIndex (mapList, row))];
	fname = [[path_mapdirectory stringByAppendingPathComponent: mapname]
				stringByAppendingPathExtension: @"map"];

	panel = NSGetAlertPanel (@"Loading...",
	                         @"Loading map. Please wait.", NULL, NULL, NULL);

	session = [NSApp beginModalSessionForWindow: panel];
	[NSApp runModalSession: session];

	[quakeed_i doOpen: fname];

	[NSApp endModalSession: session];
	[panel close];
	NSReleaseAlertPanel (panel);
	return self;
}

- (id) setTextureWad: (const char *)wf
{
	int         i, c;
	const char  *name;

	Sys_Printf ("loading %s\n", wf);

	// set the row in the settings inspector wad browser
	c = PL_A_NumObjects (wadList);
	for (i = 0; i < c; i++) {
		name = PL_String (PL_ObjectAtIndex (wadList, i));
		if (!strcmp (name, wf)) {
			[[pis_wads_i matrixInColumn: 0] selectCellAtRow: i column: 0];
			break;
		}
	}

	// update the texture inspector
	[texturepalette_i initPaletteFromWadfile: wf];
	[[map_i objectAtIndex: 0] setKey: "wad" toValue: wf];
//  [inspcontrol_i changeInspectorTo:i_textures];

	[quakeed_i updateAll];

	return self;
}

//  Clicked on a wad name
- (id) clickedOnWad: sender
{
	id          matrix;
	int         row;
	const char *name;

	matrix = [sender matrixInColumn: 0];
	row = [matrix selectedRow];

	name = PL_String (PL_ObjectAtIndex (wadList, row));
	[self setTextureWad: name];

	return self;
}

//  Read in the <name>.QE_Project file
- (id) parseProjectFile
{
	NSString    *path;
	int         rtn;
	NSFileManager *fm = [NSFileManager defaultManager];

	path = [preferences_i getProjectPath];
	if (![path length] || ![fm fileExistsAtPath: path]) {
		rtn = NSRunAlertPanel (@"Project Error!",
		                       @"A default project has not been found.\n",
		                       @"Open Project", NULL, NULL);
		if ([self openProject] == nil) {
			while (1)
				[NSApp terminate: self];    // can't run without a project
		}
		return self;
	}

	[self openProjectFile: path];
	return self;
}

//  Loads and parses a project file
- (id) openProjectFile: (NSString *)path
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSData      *contents;

	NSLog (@"openProjectFile: %@\n", path);
	[path retain];
	[path_projectinfo release];
	path_projectinfo = path;

	projectInfo = NULL;
	contents = [fm contentsAtPath: path];
	if (!contents)
		return self;

	projectInfo = [[Dict alloc] initFromData: contents];

	return self;
}

- (NSString *) currentProjectFile
{
	return path_projectinfo;
}

//  Open a project file
- (id) openProject
{
	id          openpanel;
	int         rtn;
	NSString    *projtypes[] = {@"qpr"};
	NSArray     *projtypes_array;
	NSArray     *filenames;
	NSString    *path;

	openpanel = [NSOpenPanel new];
	[openpanel setAllowsMultipleSelection:NO];
	[openpanel setCanChooseDirectories:NO];
	projtypes_array = [NSArray arrayWithObjects: projtypes count: 1];
	rtn = [openpanel runModalForTypes: projtypes_array];
	if (rtn == NSOKButton) {
		filenames = [openpanel filenames];
		path = [filenames objectAtIndex: 0];
		[self openProjectFile: path];
		return self;
	}

	return nil;
}

- (NSString *) baseDirectoryPath
{
	return path_basepath;
}

- (NSString *) getMapDirectory
{
	return path_mapdirectory;
}

- (NSString *) getFinalMapDirectory
{
	return path_finalmapdir;
}

- (NSString *) getProgDirectory
{
	return path_progdir;
}

//  Return the WAD name for cmd-8
- (const char *) getWAD8
{
	if (!path_wad8[0])
		return NULL;

	return path_wad8;
}

//  Return the WAD name for cmd-9
- (const char *) getWAD9
{
	if (!path_wad9[0])
		return NULL;

	return path_wad9;
}

//  Return the WAD name for cmd-0
- (const char *) getWAD0
{
	if (!path_wad0[0])
		return NULL;

	return path_wad0;
}

//  Return the FULLVIS cmd string
- (const char *) getFullVisCmd
{
	if (!string_fullvis[0])
		return NULL;

	return string_fullvis;
}

//  Return the FASTVIS cmd string
- (const char *) getFastVisCmd
{
	if (!string_fastvis[0])
		return NULL;

	return string_fastvis;
}

//  Return the NOVIS cmd string
- (const char *) getNoVisCmd
{
	if (!string_novis[0])
		return NULL;

	return string_novis;
}

//  Return the RELIGHT cmd string
- (const char *) getRelightCmd
{
	if (!string_relight[0])
		return NULL;

	return string_relight;
}

//  Return the LEAKTEST cmd string
- (const char *) getLeaktestCmd
{
	if (!string_leaktest[0])
		return NULL;

	return string_leaktest;
}

- (const char *) getEntitiesCmd
{
	if (!string_entities[0])
		return NULL;

	return string_entities;
}

@end
