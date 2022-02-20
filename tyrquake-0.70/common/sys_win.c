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

#include <conio.h>
#include <direct.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <windows.h>
#include <mmsystem.h>
#include <shlobj.h>
#include <winreg.h>
#include <winsock2.h>

#include "common.h"
#include "console.h"
#include "sys.h"
#include "zone.h"

#ifdef NQ_HACK
#include "conproc.h"
#include "host.h"
#endif

#ifndef SERVERONLY
#include "client.h"
#include "input.h"
#include "quakedef.h"
#include "resource.h"
#include "screen.h"
#include "winquake.h"
#else
#include "qwsvdef.h"
#include "server.h"
#endif

static int64_t timer_pfreq;
static int64_t timer_lastpcount;
static qboolean timer_perfctr;
static DWORD timer_starttime;
static DWORD timer_lasttime;

void MaskExceptions(void);
void Sys_PushFPCW_SetHigh(void);
void Sys_PopFPCW(void);

qboolean isDedicated;

#ifdef SERVERONLY
static cvar_t sys_nostdout = { "sys_nostdout", "0" };
#else
#define PAUSE_SLEEP	50	// sleep time on pause or minimization
#define NOT_FOCUS_SLEEP	20	// sleep time when not focus

static HANDLE tevent;

#ifdef NQ_HACK
static qboolean sc_return_on_enter = false;
static HANDLE hinput, houtput;
static HANDLE hFile;
static HANDLE heventParent;
static HANDLE heventChild;

static void Print_Win32SystemError(DWORD messageid);
#define CONSOLE_ERROR_TIMEOUT	60.0	// # of seconds to wait on Sys_Error
					// running dedicated before exiting
#endif
#ifdef QW_HACK
static HANDLE qwclsemaphore;
#endif
#endif /* !SERVERONLY */

static char win32_cwd[MAX_PATH];
static char win32_basedir[MAX_PATH];

static const char *
Win32_StripTrailingSlash(char *path)
{
    size_t length = strlen(path);
    if (length && (path[length - 1] == '/' || path[length - 1] == '\\'))
        path[length - 1] = 0;

    return path;
}

static const char *
Win32_SteamPath()
{
    /*
     * https://docs.microsoft.com/en-us/windows/win32/api/winreg/nf-winreg-regopenkeyexa
     * https://docs.microsoft.com/en-us/windows/win32/winprog64/accessing-an-alternate-registry-view
     */
    const char *subkey = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Steam App 2310";
    const char *value_name = "InstallLocation";
    LSTATUS status;
    HKEY key_handle;

    HKEY keys[] = { HKEY_CURRENT_USER, HKEY_LOCAL_MACHINE };
    for (int i = 0; i < ARRAY_SIZE(keys); i++) {
        DWORD flags[] = { KEY_WOW64_64KEY, KEY_WOW64_32KEY };
        for (int j = 0; j < ARRAY_SIZE(flags); j++) {
            status = RegOpenKeyExA(keys[i], subkey, 0, KEY_QUERY_VALUE | flags[j], &key_handle);
            if (status != ERROR_SUCCESS)
                continue;
            DWORD value_type;
            DWORD path_size = sizeof(win32_basedir);
            status = RegQueryValueExA(key_handle, value_name, NULL, &value_type, (BYTE *)win32_basedir, &path_size);
            RegCloseKey(key_handle);
            if (status != ERROR_SUCCESS || value_type != REG_SZ)
                continue;

            return Win32_StripTrailingSlash(win32_basedir);
        }
    }

    return NULL;
}

static const char *
Win32_CSIDL_Path(int csidl)
{
    char folder_path[MAX_PATH];
    BOOL result;

    result = SHGetSpecialFolderPathA(0, folder_path, csidl, false);
    if (!result)
        return NULL;

    Win32_StripTrailingSlash(folder_path);
    qsnprintf(win32_basedir, sizeof(win32_basedir), "%s/Quake", folder_path);

    return win32_basedir;
}

static const char *
Win32_ProgramFilesX86Path()
{
    return Win32_CSIDL_Path(CSIDL_PROGRAM_FILESX86);
}

static const char *
Win32_ProgramFilesPath()
{
    return Win32_CSIDL_Path(CSIDL_PROGRAM_FILES);
}

static const char *
Win32_DefaultPath()
{
    return "C:/quake";
}

int64_t
Sys_FileTime(const char *path)
{
    HANDLE handle;
    FILETIME filetime;
    ULARGE_INTEGER mtime;
    BOOL success;

    handle = CreateFileA(path, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
    if (handle == INVALID_HANDLE_VALUE)
        return -1;

    success = GetFileTime(handle, NULL, NULL, &filetime);
    CloseHandle(handle);
    if (!success)
        return -1;

    /*
     * A UNIX timestamp contains the number of seconds from Jan 1,
     * 1970, while the FILETIME documentation says: Contains a 64-bit
     * value representing the number of 100-nanosecond intervals since
     * January 1, 1601 (UTC).
     *
     * Between Jan 1, 1601 and Jan 1, 1970 there are 11644473600
     * seconds, so we will just subtract that value:
     */
    mtime.LowPart = filetime.dwLowDateTime;
    mtime.HighPart = filetime.dwHighDateTime;

    mtime.QuadPart -= 11644473600LL * 10000;

    return mtime.QuadPart;
}

void
Sys_mkdir(const char *path)
{
    _mkdir(path);
}

void
Sys_RegisterVariables()
{
#ifdef SERVERONLY
    Cvar_RegisterVariable(&sys_nostdout);
#endif
}

static void
Sys_Init(void)
{
#ifndef SERVERONLY
    OSVERSIONINFO vinfo;

#ifdef QW_HACK
    /*
     * Allocate a named semaphore on the client so the front end can tell
     * if it is alive. Mutex will fail if semephore already exists
     */
    qwclsemaphore = CreateMutex(NULL,		/* Security attributes */
				0,		/* owner       */
				"qwcl");	/* Semaphore name      */
    if (!qwclsemaphore)
	Sys_Error("QWCL is already running on this system");
    CloseHandle(qwclsemaphore);

    qwclsemaphore = CreateSemaphore(NULL,	/* Security attributes */
				    0,		/* Initial count       */
				    1,		/* Maximum count       */
				    "qwcl");	/* Semaphore name      */
#endif

    vinfo.dwOSVersionInfoSize = sizeof(vinfo);
    if (!GetVersionEx(&vinfo))
	Sys_Error("Couldn't get OS info");

    if ((vinfo.dwMajorVersion < 4) ||
	(vinfo.dwPlatformId == VER_PLATFORM_WIN32s)) {
	Sys_Error("TyrQuake requires at least Win95 or NT 4.0");
    }
#endif

    /* Set floating point options */
    MaskExceptions();
    Sys_SetFPCW();

    /*
     * Request 1ms precision for timeouts from the scheduler
     * (may or may not succeed)
     */
    timeBeginPeriod(1);

    timer_starttime = timer_lasttime = timeGetTime();
    timer_perfctr = !!QueryPerformanceFrequency((LARGE_INTEGER *)&timer_pfreq);
    if (timer_perfctr)
	QueryPerformanceCounter((LARGE_INTEGER *)&timer_lastpcount);
}

double
Sys_DoubleTime(void)
{
    int64_t pcount;
    int64_t currtime;
    double qtime;

    Sys_PushFPCW_SetHigh();

    currtime = timeGetTime();
    qtime = (currtime - timer_starttime) * 0.001;

    if (!timer_perfctr)
	goto out;

    QueryPerformanceCounter((LARGE_INTEGER *)&pcount);

    if (currtime != timer_lasttime) {
	/*
	 * Re-query the frequency in case it changes (which it can on
	 * multicore machines with buggy BIOS or drivers). Or we could set
	 * processor affinity, but would rather not for now.
	 *
	 * See also:
	 *   Game Timing and Multicore Processors (Windows)
	 *   http://msdn.microsoft.com/en-us/library/windows/desktop/ee417693%28v=vs.85%29.aspx
	 */
	QueryPerformanceFrequency((LARGE_INTEGER *)&timer_pfreq);

	/*
	 * Calculate a fudge factor to compensate for low precision in
	 * timeGetTime().
	 */
	qtime += (double)(pcount - timer_lastpcount) / (double)timer_pfreq;
	qtime -= (currtime - timer_lasttime) * 0.001;

	timer_lastpcount = pcount;
	timer_lasttime = currtime;
    }

    qtime += (double)(pcount - timer_lastpcount) / (double)timer_pfreq;

 out:
    Sys_PopFPCW();

    return qtime;
}

/*
 * FIXME - NQ/QW Sys_Error are different enough to duplicate for now
 */
#ifdef NQ_HACK
void
Sys_Error(const char *error, ...)
{
    va_list argptr;
    char text[MAX_PRINTMSG];
    char text2[MAX_PRINTMSG];
    const char *text3 = "Press Enter to exit\n";
    const char *text4 = "***********************************\n";
    const char *text5 = "\n";
    DWORD dummy;
    double starttime;
    static int in_sys_error0 = 0;
    static int in_sys_error1 = 0;
    static int in_sys_error2 = 0;
    static int in_sys_error3 = 0;

    if (!in_sys_error3) {
	in_sys_error3 = 1;
    }

    va_start(argptr, error);
    qvsnprintf(text, sizeof(text), error, argptr);
    va_end(argptr);

    if (isDedicated) {
	qsnprintf(text2, sizeof(text2), "ERROR: %s\n", text);
	if (text2[sizeof(text2) - 2])
	    strcpy(text2 + sizeof(text2) - 2, "\n"); /* in case we truncated */
	WriteFile(houtput, text5, strlen(text5), &dummy, NULL);
	WriteFile(houtput, text4, strlen(text4), &dummy, NULL);
	WriteFile(houtput, text2, strlen(text2), &dummy, NULL);
	WriteFile(houtput, text3, strlen(text3), &dummy, NULL);
	WriteFile(houtput, text4, strlen(text4), &dummy, NULL);

	starttime = Sys_DoubleTime();
	sc_return_on_enter = true;	// so Enter will get us out of here

	while (!Sys_ConsoleInput() &&
	       ((Sys_DoubleTime() - starttime) < CONSOLE_ERROR_TIMEOUT)) {
	}
    } else {
	// switch to windowed so the message box is visible, unless we already
	// tried that and failed
	if (!in_sys_error0) {
	    in_sys_error0 = 1;
	    VID_SetDefaultMode();
	    MessageBox(NULL, text, "Quake Error",
		       MB_OK | MB_SETFOREGROUND | MB_ICONSTOP);
	} else {
	    MessageBox(NULL, text, "Double Quake Error",
		       MB_OK | MB_SETFOREGROUND | MB_ICONSTOP);
	}
    }

    if (!in_sys_error1) {
	in_sys_error1 = 1;
	Host_Shutdown();
    }
// shut down QHOST hooks if necessary
    if (!in_sys_error2) {
	in_sys_error2 = 1;
	DeinitConProc();
    }

    exit(1);
}
#endif
#ifdef QW_HACK
void
Sys_Error(const char *error, ...)
{
    va_list argptr;
    char text[MAX_PRINTMSG];

#ifndef SERVERONLY
    Host_Shutdown();
#endif

    va_start(argptr, error);
    qvsnprintf(text, sizeof(text), error, argptr);
    va_end(argptr);

#ifndef SERVERONLY
    MessageBox(NULL, text, "Error", 0 /* MB_OK */ );
    CloseHandle(qwclsemaphore);
#else
    printf("ERROR: %s\n", text);
#endif

    exit(1);
}
#endif

void
Sys_Printf(const char *fmt, ...)
{
    va_list argptr;
#ifdef NQ_HACK
    char text[MAX_PRINTMSG];
    DWORD dummy;

    if (isDedicated) {
	va_start(argptr, fmt);
	qvsnprintf(text, sizeof(text), fmt, argptr);
	va_end(argptr);
	WriteFile(houtput, text, strlen(text), &dummy, NULL);
	return;
    }
#endif
#ifdef SERVERONLY
    if (sys_nostdout.value)
	return;
#endif
    va_start(argptr, fmt);
    vprintf(fmt, argptr);
    va_end(argptr);

#ifdef DEBUG
    fflush(stdout);
#endif
}

void
Sys_Quit(void)
{
#ifndef SERVERONLY
    Host_Shutdown();
    if (tevent)
	CloseHandle(tevent);

#ifdef NQ_HACK
    if (isDedicated)
	FreeConsole();

// shut down QHOST hooks if necessary
    DeinitConProc();
#endif
#ifdef QW_HACK
    if (qwclsemaphore)
	CloseHandle(qwclsemaphore);
#endif
#endif

    exit(0);
}

#ifndef USE_X86_ASM
void Sys_SetFPCW(void) {}
void Sys_PushFPCW_SetHigh(void) {}
void Sys_PopFPCW(void) {}
void MaskExceptions(void) {}
#endif

/*
 * ===========================================================================
 * NQ/QW SERVER SHARED
 *
 * Console input for QWSV and NQ in dedicated mode. Not very similar
 * right now because NQ needs to operate as both a GUI and console
 * application.
 * ===========================================================================
 */
#ifdef NQ_HACK
char *
Sys_ConsoleInput(void)
{
    static char text[256];
    static int len;
    INPUT_RECORD recs[1024];
    DWORD dummy;
    int ch;
    DWORD numread, numevents;

    if (!isDedicated)
	return NULL;

    for (;;) {
	if (!GetNumberOfConsoleInputEvents(hinput, &numevents)) {
	    DWORD err = GetLastError();

	    printf("GetNumberOfConsoleInputEvents: ");
	    Print_Win32SystemError(err);
	    Sys_Error("Error getting # of console events");
	}

	if (numevents <= 0)
	    break;

	if (!ReadConsoleInput(hinput, recs, 1, &numread))
	    Sys_Error("Error reading console input");

	if (numread != 1)
	    Sys_Error("Couldn't read console input");

	if (recs[0].EventType == KEY_EVENT) {
	    if (!recs[0].Event.KeyEvent.bKeyDown) {
		ch = recs[0].Event.KeyEvent.uChar.AsciiChar;

		switch (ch) {
		case '\r':
		    WriteFile(houtput, "\r\n", 2, &dummy, NULL);
		    if (len) {
			text[len] = 0;
			len = 0;
			return text;
		    } else if (sc_return_on_enter) {
			/*
			 * special case to allow exiting from the error
			 * handler on Enter
			 */
			text[0] = '\r';
			len = 0;
			return text;
		    }
		    break;
		case '\b':
		    WriteFile(houtput, "\b \b", 3, &dummy, NULL);
		    if (len) {
			len--;
		    }
		    break;
		default:
		    if (ch >= ' ') {
			WriteFile(houtput, &ch, 1, &dummy, NULL);
			text[len] = ch;
			len = (len + 1) & 0xff;
		    }
		    break;
		}
	    }
	}
    }

    return NULL;
}
#endif
#ifdef SERVERONLY
char *
Sys_ConsoleInput(void)
{
    static char text[256];
    static int len;
    int c;

    // read a line out
    while (_kbhit()) {
	c = _getch();
	putch(c);
	if (c == '\r') {
	    text[len] = 0;
	    putch('\n');
	    len = 0;
	    return text;
	}
	if (c == 8) {
	    if (len) {
		putch(' ');
		putch(c);
		len--;
		text[len] = 0;
	    }
	    continue;
	}
	text[len] = c;
	len++;
	if (len == sizeof(text)) {
	    /* buffer is full */
	    len = 0;
	    text[0] = '\0';
	    fprintf (stderr, "\nConsole input too long!\n");
	    return text;
	} else {
	    text[len] = 0;
	}
    }

    return NULL;
}
#endif

/*
 * ===========================================================================
 * QW SERVER ONLY
 * ===========================================================================
 */
#ifdef SERVERONLY

/*
 * ==================
 * Server main()
 * ==================
 */
int
main(int argc, char **argv)
{
    quakeparms_t parms;
    double newtime, time, oldtime;
    struct timeval timeout;
    fd_set fdset;

    COM_InitArgv(argc, (const char **)argv);

    parms.argc = com_argc;
    parms.argv = com_argv;
    parms.basedir = ".";
    parms.memsize = Memory_GetSize();
    parms.membase = malloc(parms.memsize);
    if (!parms.membase)
	Sys_Error("Insufficient memory.");

    Sys_Init();
    SV_Init(&parms);

// run one frame immediately for first heartbeat
    SV_Frame(0.1);

//
// main loop
//
    oldtime = Sys_DoubleTime() - 0.1;
    while (1) {
	// select on the net socket and stdin
	// the only reason we have a timeout at all is so that if the last
	// connected client times out, the message would not otherwise
	// be printed until the next event.
	FD_ZERO(&fdset);
	FD_SET(net_socket, &fdset);
	timeout.tv_sec = 0;
	timeout.tv_usec = 100;
	if (select(net_socket + 1, &fdset, NULL, NULL, &timeout) == -1)
	    continue;

	// find time passed since last cycle
	newtime = Sys_DoubleTime();
	time = newtime - oldtime;
	oldtime = newtime;

	SV_Frame(time);
    }

    return 0;
}

#endif /* SERVERONLY */

/*
 * ===========================================================================
 * NQ/QW CLIENT ONLY
 * ===========================================================================
 */
#ifndef SERVERONLY

void
Sys_DebugLog(const char *file, const char *fmt, ...)
{
    va_list argptr;
    static char data[MAX_PRINTMSG];
    int fd;

    va_start(argptr, fmt);
    qvsnprintf(data, sizeof(data), fmt, argptr);
    va_end(argptr);
    fd = open(file, O_WRONLY | O_CREAT | O_APPEND, 0666);
    write(fd, data, strlen(data));
    close(fd);
};

void
Sys_Sleep(void)
{
    Sleep(1);
}

void
Sys_SendKeyEvents(void)
{
    MSG msg;

    while (PeekMessage(&msg, NULL, 0, 0, PM_NOREMOVE)) {
	// we always update if there are any event, even if we're paused
	scr_skipupdate = 0;

	if (!GetMessage(&msg, NULL, 0, 0))
	    Sys_Quit();
	TranslateMessage(&msg);
	DispatchMessage(&msg);
    }

    /* Allow the vid driver to process it's message queue */
    VID_ProcessEvents();
}

static void
SleepUntilInput(int time)
{
    MsgWaitForMultipleObjects(1, &tevent, FALSE, time, QS_ALLINPUT);
}

/*
==================
WinMain
==================
*/
HINSTANCE global_hInstance;
int global_nCmdShow;
HWND hwnd_dialog;

int WINAPI
WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine,
	int nCmdShow)
{
    quakeparms_t parms;
    double time, oldtime, newtime;
    RECT rect;

    /* previous instances do not exist in Win32 */
    if (hPrevInstance)
	return 0;

    global_hInstance = hInstance;
    global_nCmdShow = nCmdShow;

    if (!GetCurrentDirectory(sizeof(win32_cwd), win32_cwd))
	Sys_Error("Couldn't determine current directory");
    Win32_StripTrailingSlash(win32_cwd);

    COM_InitArgv(__argc, (const char **)__argv);

    parms.basedir = win32_cwd;
    parms.argc = com_argc;
    parms.argv = com_argv;

#ifdef NQ_HACK
    isDedicated = (COM_CheckParm("-dedicated") != 0);
#endif
#ifdef QW_HACK
#ifdef SERVERONLY
    isDedicated = true;
#else
    isDedicated = false;
#endif
#endif
    if (!isDedicated) {
	hwnd_dialog = CreateDialog(hInstance, MAKEINTRESOURCE(IDD_DIALOG1), NULL, NULL);
	if (hwnd_dialog) {
	    if (GetWindowRect(hwnd_dialog, &rect)) {
		if (rect.left > (rect.top * 2)) {
		    SetWindowPos(hwnd_dialog, 0,
				 (rect.left / 2) -
				 ((rect.right - rect.left) / 2), rect.top, 0,
				 0, SWP_NOZORDER | SWP_NOSIZE);
		}
	    }

	    ShowWindow(hwnd_dialog, SW_SHOWDEFAULT);
	    UpdateWindow(hwnd_dialog);
	    SetForegroundWindow(hwnd_dialog);
	}
    }

    parms.memsize = Memory_GetSize();
    parms.membase = malloc(parms.memsize);
    if (!parms.membase)
	Sys_Error("Not enough memory free; check disk space");

    tevent = CreateEvent(NULL, FALSE, FALSE, NULL);
    if (!tevent)
	Sys_Error("Couldn't create event");

#ifdef NQ_HACK
    if (isDedicated) {
	int parm;

	if (!AllocConsole()) {
	    DWORD err = GetLastError();

	    printf("AllocConsole Failed: ");
	    Print_Win32SystemError(err);

	    // Already have one? - Try free it and get a new one...
	    // FIXME - Keep current console or get new one...
	    FreeConsole();
	    if (!AllocConsole()) {
		err = GetLastError();
		printf("AllocConsole (2nd try): Error %i\n", (int)err);
		fflush(stdout);

		// FIXME - might not have stdout or stderr here for Sys_Error.
		Sys_Error("Couldn't create dedicated server console");
	    }
	}
	// FIXME - these can fail...
	// FIXME - the whole console creation thing is pretty screwy...
	// FIXME - well, at least from cygwin rxvt it sucks...
	hinput = GetStdHandle(STD_INPUT_HANDLE);
	if (!hinput) {
	    DWORD err = GetLastError();
	    printf("GetStdHandle(STD_INPUT_HANDLE): Error %i\n", (int)err);
	    fflush(stdout);
	}
	houtput = GetStdHandle(STD_OUTPUT_HANDLE);
	if (!hinput) {
	    DWORD err = GetLastError();
	    printf("GetStdHandle(STD_OUTPUT_HANDLE): Error %i\n", (int)err);
	    fflush(stdout);
	}
	// give QHOST a chance to hook into the console
	// FIXME - Do we even care about QHOST?
	parm = COM_CheckParm("-HFILE");
	if (parm && com_argc > parm + 1)
	    hFile = (HANDLE)(uintptr_t)strtoull(com_argv[parm + 1], NULL, 0);

	parm = COM_CheckParm("-HPARENT");
	if (parm && com_argc > parm + 1)
	    heventParent = (HANDLE)(uintptr_t)strtoull(com_argv[parm + 1], NULL, 0);

	parm = COM_CheckParm("-HCHILD");
	if (parm && com_argc > parm + 1)
	    heventChild = (HANDLE)(uintptr_t)strtoull(com_argv[parm + 1], NULL, 0);

	InitConProc(hFile, heventParent, heventChild);
    }
#endif

    Sys_Init();

// because sound is off until we become active
    S_BlockSound();

    Sys_Printf("Host_Init\n");

    basedir_fn basedir_fns[] = {
        Win32_SteamPath,
        Win32_ProgramFilesX86Path,
        Win32_ProgramFilesPath,
        Win32_DefaultPath,
        NULL,
    };
    Host_Init(&parms, basedir_fns);

    oldtime = Sys_DoubleTime();

    /* main window message loop */
    while (1) {
#ifdef NQ_HACK
	if (isDedicated) {
	    newtime = Sys_DoubleTime();
	    time = newtime - oldtime;

	    while (time < sys_ticrate.value) {
		Sys_Sleep();
		newtime = Sys_DoubleTime();
		time = newtime - oldtime;
	    }

	    Host_Frame(time);
	    oldtime = newtime;
	    continue;
	}
#endif
	/*
	 * yield the CPU for a little while when paused, minimized,
	 * or not the focus
	 */
	if ((cl.paused && (!IN_HaveFocus() && !DDActive)) || !window_visible() || scr_block_drawing) {
	    SleepUntilInput(PAUSE_SLEEP);
	    scr_skipupdate = 1;	/* no point in bothering to draw */
	} else if (!IN_HaveFocus() && !DDActive) {
	    SleepUntilInput(NOT_FOCUS_SLEEP);
	}

	newtime = Sys_DoubleTime();
	time = newtime - oldtime;
	Host_Frame(time);
	oldtime = newtime;
    }

    /* return success of application */
    return TRUE;
}

/*
================
Sys_MakeCodeWriteable
================
*/
void
Sys_MakeCodeWriteable(void *start_addr, void *end_addr)
{
    DWORD dummy;
    BOOL success;
    size_t length;

    length = (byte *)end_addr - (byte *)start_addr;
    success = VirtualProtect(start_addr, length, PAGE_EXECUTE_READWRITE, &dummy);
    if (!success)
	Sys_Error("Protection change failed");
}

void
Sys_MakeCodeUnwriteable(void *start_addr, void *end_addr)
{
    DWORD dummy;
    BOOL success;
    size_t length;

    length = (byte *)end_addr - (byte *)start_addr;
    success = VirtualProtect(start_addr, length, PAGE_EXECUTE_READ, &dummy);
    if (!success)
	Sys_Error("Protection change failed");

    /* After changing the code, strictly speaking we must flush the instruction cache */
    FlushInstructionCache(GetCurrentProcess(), start_addr, length);
}

#ifndef USE_X86_ASM
void Sys_HighFPPrecision(void) {}
void Sys_LowFPPrecision(void) {}
#endif

#ifdef NQ_HACK
/*
 * For debugging - Print a Win32 system error string to stderr
 */
static void
Print_Win32SystemError(DWORD messageid)
{
    LPTSTR buffer;
    DWORD flags, length;

    flags = FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM;
    length = FormatMessage(flags, NULL, messageid, 0, (LPTSTR)&buffer, 0, NULL);
    if (!length)
	return;

    fprintf(stderr, "%s: %s\n", __func__, buffer);
    fflush(stderr);
    LocalFree(buffer);
}
#endif

#endif /* !SERVERONLY */
