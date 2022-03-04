/*
	Controller.h

	Application controller class

	Copyright (C) 2001 Dusk to Dawn Computing, Inc.

	Author: Jeff Teunissen <deek@d2dc.net>
	Date:	5 Nov 2001

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License as
	published by the Free Software Foundation; either version 2 of
	the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public
	License along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA
*/

#ifndef Controller_h
#define Controller_h

#ifdef HAVE_CONFIG_H
# include "Config.h"
#endif

#include <Foundation/NSObject.h>
#include <Foundation/NSNotification.h>
#include <Foundation/NSString.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSNibDeclarations.h>

#include "BundleController.h"
#include "PrefsController.h"

typedef enum {CNoMode = 0, COpenMode, CCreateMode} CMode;

@interface Controller: NSObject <BundleDelegate>
{
	IBOutlet BundleController	*bundleController;
	IBOutlet PrefsController	*prefsController;
	IBOutlet CMode				fileMode;
	IBOutlet NSString			*fileName;
}

// App delegate methods
- (BOOL) application: (NSApplication *) app openFile: (NSString *) filename;
- (BOOL) applicationShouldTerminate: (NSApplication *) app;
- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) app;

// Notifications
- (void) applicationDidFinishLaunching: (NSNotification *) not;
- (void) applicationWillFinishLaunching: (NSNotification *) not;
- (void) applicationWillTerminate: (NSNotification *) not;

// Action methods
- (IBAction) showPreferencesPanel: (id) sender;

// Open/Create Project
- (IBAction) newProject: (id) sender;
- (IBAction) openProject: (id) sender;

// Private (for Project)
- (CMode) fileMode;
- (NSString *) fileName;
@end

#endif//Controller_h
