/*
 *    $Id: header.h,v 1.4 2006/11/09 19:26:39 david_costanzo Exp $
 */

#define DEBUG 0


#include <stdio.h>
#include <errno.h>
#include <unistd.h>     /* getopt() */
#include <stdlib.h>     /* exit(), malloc() */
#include <sys/types.h>  /* mkdir() */
#include <sys/stat.h>   /* mkdir() */
#include <string.h>     /* str*() */

#define DEBUG_CHANNEL   stderr
#define ERROR_CHANNEL   stderr
#define HELP_CHANNEL    stdout
#define VERSION_CHANNEL stdout

#define RETVAL_OK       0
#define RETVAL_BUG      1
#define RETVAL_ERROR    2

#define ALLOW_EMPTY_ARCHIVES 1

#define ACTION_NONE     0
#define ACTION_LIST     1
#define ACTION_EXTRACT  2
#define ACTION_CREATE   3

#define MAX_FN_LEN      PAK_TOC_FN_LEN  /* 0x00 included */
#define MALLOC_SIZE     512

#define PAK_MAGIC               "PACK"
#define PAK_MAGIC_SIZE          PAK_OFFSET_SIZE         /* '\0' excluded */
#define PAK_OFFSET_SIZE         0x04    /* size of offset field in pak structs */
#define PAK_HDR_SIZE            (PAK_MAGIC_SIZE + 2*PAK_OFFSET_SIZE)
#define PAK_TOC_FN_LEN          0x38    /* number of filename bytes in toc */
#define PAK_TOC_ENTRY_SIZE      (PAK_TOC_FN_LEN + 2*PAK_OFFSET_SIZE)
#define CP_BUF_SIZE             1024    /* copy-buffer size */

#define VERSION_NUMBER          "v0.06.00 *forked*"
#define DATE_OF_LAST_MOD        "2006-11-09"
#define MY_EMAIL_ADDRESS        "David Costanzo <david_costanzo@yahoo.com>"

#define MAX(A,B) ((A)>(B)?(A):(B))
#define MIN(A,B) ((A)<(B)?(A):(B))

struct pak_header {
    char  magic[PAK_MAGIC_SIZE+1];
    off_t toc_off;
    off_t toc_sze;
    off_t pak_sze;
};

struct pak_tocentry {
    char  f_nme[PAK_TOC_FN_LEN+1]; /* +1 to be sure */
    off_t f_off;
    off_t f_sze;
};

struct my_file {
    FILE*        stream;
    const char * filename;
    const char * program_name;
};
