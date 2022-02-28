/*
  par.c  --  Quake *.pak file archiver
  Copyright (C) 1998-2004 Steffen Solyga <solyga@absinth.net>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

/*
  Contributors:
    David Costanzo <david_costanzo@yahoo.com>
    - ported to Windows
*/

/*
 * $Id: par.c,v 1.8 2006/11/09 19:26:39 david_costanzo Exp $
 */

#include <stdio.h>

#include "header.h"

#ifdef _WIN32
  #define MKDIR(DIRNAME)      _mkdir(DIRNAME);
  #define DIRECTORY_DELIMITER '\\'
#else
  #define MKDIR(DIRNAME) mkdir(DIRNAME, 0777);
  #define DIRECTORY_DELIMITER '/'
#endif


static
int
display_help( 
    const char* pn 
) 
{
    fprintf(
        HELP_CHANNEL, 
        "%s v%s (%s): Quake Pak ARchiving utility\n", 
        pn, 
        VERSION_NUMBER, 
        DATE_OF_LAST_MOD );

    fprintf(HELP_CHANNEL, "Written by Steffen Solyga <solyga@absinth.net>\n" );
    fprintf(HELP_CHANNEL, "Maintained by %s\n", MY_EMAIL_ADDRESS );
    fprintf(HELP_CHANNEL, "\n" );
    fprintf(HELP_CHANNEL, "Usage: %s options archive [files]\n", pn );
    fprintf(HELP_CHANNEL, "switches:\n" );
    fprintf(HELP_CHANNEL, "  -c\t create new pak archive\n" );
    fprintf(HELP_CHANNEL, "  -f\t force actions\n" );
    fprintf(HELP_CHANNEL, "  -h\t write this info to %s and exit sucessfully\n",HELP_CHANNEL==stdout?"stdout":"stderr" );
    fprintf(HELP_CHANNEL, "  -l\t list contents of pak archive\n" );
    fprintf(HELP_CHANNEL, "  -t\t files !!contain!! the names of the files to process\n" );
    fprintf(HELP_CHANNEL, "  -v\t be verbose\n" );
    fprintf(HELP_CHANNEL, "  -x\t extract files from archive\n" );
    fprintf(HELP_CHANNEL, "  -V\t print version and compilation info to %s and exit sucessfully\n", VERSION_CHANNEL==stdout?"stdout":"stderr" );
    fprintf(HELP_CHANNEL, "Hint: %s doesn't work with stdin/stdout.\n", pn );

    return 0;
}


static
int
display_version( 
    const char* pn 
) 
{
    fprintf( VERSION_CHANNEL, "%s v%s (%s)\n", pn, VERSION_NUMBER, DATE_OF_LAST_MOD );
    return 0;
}

/* returns index+1 of name in list or 0 if name is not in list */
/* if name is empty, number_of_entries+1 is returned */
static
int 
is_in_list(
    const char*   list,
    const char*   name 
)
{
  const char *pl= list;
  const char *pn;
  int index= 0; /* index in [0,noe) */
  while( *pl != '\0' ) {
      for( pn=name; ; pl++,pn++ ) {
          if( *pl != *pn ) {
              break;
          }
          if( *pl == '\0' ) {
              return index+1;
          }
      }
      while( *pl++ != '\0' ) {
          /* next entry */
      }
      index++;
  }
  return *name=='\0' ? index+1 : 0;
}


static
const char* 
add_to_list(
    const char*   name 
)
{
    static long nba= 0;   /* number of bytes allocated */
    static char *p0=NULL; /* memory start */
    static char *p1=NULL; /* write position */
    const char *p= name;  /* tmp pointer */
    int len= 1;       /* name length including '\0' */

    while( *p++ != '\0' ) {
        len++;
    }

    if( p1-p0+len >= nba ) {
        unsigned long diff= p1-p0;
        nba+= MALLOC_SIZE;
        if( (p1=realloc(p0,nba)) == NULL ) {
            return( realloc(p0,0) );
        }

        p0= p1; 
        p1+= diff;
        *p1= '\0'; /* init for first call */

        if (DEBUG) {
            fprintf(
                DEBUG_CHANNEL, 
                "DEBUG: add_to_list(): Allocated %p for list.\n", 
                p0);
        }
    }

    /* check name */
    if( is_in_list(p0,name) ) {
        return p0;
    }

    /* append name */
    if (DEBUG) {
        fprintf(
            DEBUG_CHANNEL, 
            "DEBUG: add_to_list(): Adding `%s' to list at %p.\n", 
            name, 
            p1);
    }

    for( p=name; (*p1++=*p++)!='\0'; ) {
        ;
    }
    *p1= '\0'; /* end-of-list code */

    return p0;
}

  
/* returns pointer to index-th entry, index in [0,noe) */
/* if index is out of bounds, string of size 0 is returned */
static
const char*
list_entry(
     const char* list,
     int         index 
)
{
    const char* p = list;
    int i = 0;

    if( list == NULL ) {
        return NULL;
    }

    while( *p != '\0' && i<index ) {
        
        while( *p++ != '\0' );
        i++;
    }

    return p;
}


/* Return an off_t from an unsigned char array in little-endian fashion */
static 
off_t
UCHARs_2_off_t(
    const unsigned char *p
)
{
  off_t val= (off_t)0;
  int i;
  for( i=0; i< PAK_OFFSET_SIZE; i++ ) {
      val|= p[i]<<(i*8);
  }

  return val;
}


/* Copies an off_t to an unsigned char array in little-endian fashion */
static
off_t
off_t_2_UCHARs(
    off_t           val,
    unsigned char*  p 
)
{
  int i;
  for (i=0; i<PAK_OFFSET_SIZE; i++) {
      p[i] = (unsigned char)(val>>(i*8)&0xff);
  }
  return val;
}


/* opens a file.  returns file descriptor or NULL on error */
static
struct my_file * 
my_open(
    const char * filename,     /* file name */
    const char * mode,         /* access mode */
    const char * program_name  /* name of main program */
)
{
    struct my_file * file;

    file = calloc(1, sizeof(*file));
    if (file == NULL) {
        return NULL;
    }

    file->stream = fopen(filename, mode);
    if (file->stream == NULL) {

        fprintf(
            ERROR_CHANNEL,
            "%s: Cannot open `%s' in mode `%s': %s.\n",
            program_name, 
            filename, 
            mode, 
            strerror(errno));
        
        free(file);
        return NULL;
    }

    /* consider for robustness: copy filename and program_name */
    file->filename     = filename;
    file->program_name = program_name;
    return file;
}


/* returns 0 or -1 on error */
static
int 
my_close(
    struct my_file * file  /* file stream */
) 
{
    if (file == NULL) {
        return -1;
    }

    int rval;
    rval = fclose(file->stream);
    if( rval != 0 ) {
        fprintf(
            ERROR_CHANNEL,
            "%s: Could not close `%s' successfully. %s.\n",
            file->program_name, 
            file->filename, 
            strerror(errno));

        return -1;
    }

    return 0;
}


/* returns new file offset or -1 on error */
static
int
my_lseek(
    struct my_file * file,   /* file stream */
    long             offset, /* file offset */
    int              whence  /* reference position */
)
{
    int rval = fseek(file->stream, offset, whence);
    if (rval != 0) {

        fprintf(
            ERROR_CHANNEL,
            "%s: Cannot lseek `%s'. %s.\n",
            file->program_name, 
            file->filename, 
            strerror(errno));

        return -1;
    }

    return ftell(file->stream);
}


/* read from nbtr bytes from file into buf.
   return number of bytes read or -1 on error
   like read(2) but nbr<nbtr only if eof reached 
*/
static
ssize_t 
my_read(
    struct my_file * file,   /* file stream */
    void*            buf,    /* buffer */
    size_t           nbtr    /* number of bytes to read */
)
{
    size_t nbr;
    ssize_t tnbr= 0;
    ssize_t rem = nbtr;
    unsigned char *p = (unsigned char*)buf;

    do {

        nbr = fread(p+tnbr, 1, rem, file->stream);
        if( ferror(file->stream) ) {
            fprintf(
                ERROR_CHANNEL,
                "%s: Cannot read from `%s': %s.\n",
                file->program_name, 
                file->filename, 
                strerror(errno));

            return -1;
        }

        tnbr+= nbr;
        rem  = nbtr - tnbr;

    } while( nbr>0 && rem>0 );

    return tnbr;
}

/* write nbtw buffer to file */
/* returns number of bytes written ( ==nbtw ) or -1 on error */
static
int
my_write(
    struct my_file * file,    /* file stream */
    const void*      buf,     /* buffer */
    size_t           buf_len  /* number of bytes to write */
)
{
    size_t total_bytes_written;

    total_bytes_written = fwrite(buf, 1, buf_len, file->stream);
    if (ferror(file->stream)) {
 
        fprintf(
            ERROR_CHANNEL, 
            "%s: Cannot write to `%s': %s.\n",
            file->program_name, 
            file->filename, 
            strerror(errno));
        
        return -1;
    }

    return total_bytes_written;
}


/* create all the parent directories of filename so that
   filename can be opened for creation.
   returns 0 on success or -1 on error 
*/
static
int 
my_mkdir(
    const char* filename,    /* filename to use path from */
    const char* program_name /* name of main program */
) 
{
    char directory[MAX_FN_LEN];

    const char *src;
    char       *dest;

    int  rval;

    /* copy directory_name to buf, creating the directories as we go */
    for (src = filename, dest = directory; 
         *src != '\0'; 
         src++, dest++) {

        switch (*src) {

        case '/':
        case '\\':
            /* directory delimiter -- create the directory */
            *dest = '\0';

            rval = MKDIR(directory);
            if ( (rval != 0) && errno != EEXIST ) {
                fprintf(
                    ERROR_CHANNEL, 
                    "%s: Cannot make directory `%s'. %s.\n",
                    program_name, 
                    directory,
                    strerror(errno));

                return -1;
            }

            /* copy the platform-specific delimiter */
            *dest = DIRECTORY_DELIMITER;

        default:
            /* copy the filename character */
            *dest = *src;
        }
    }

    return 0;
}


/* inits pak header structure (== pak header for empty archive) */
/* returns 0 on success or -1 on error */
static 
int 
init_pak_header(
    struct pak_header*  p_pak_hdr /* pak header */
) 
{
    if (p_pak_hdr == NULL) {
        return -1;
    }

    strcpy( p_pak_hdr->magic, PAK_MAGIC );
    p_pak_hdr->toc_off= (off_t) PAK_HDR_SIZE;
    p_pak_hdr->toc_sze= (off_t) 0;
    p_pak_hdr->pak_sze= (off_t) PAK_HDR_SIZE;

    return 0;
}


/* reads header from pak archive */
/* returns 0 or -1 on error */
static
int 
read_pak_header(
    struct pak_header*  p_pak_hdr,    /* pak header */
    const char*         pak_filename, /* pak file name */
    const char*         program_name  /* name of main prg. */
)
{
    int rv= 0;
    unsigned char buf[PAK_HDR_SIZE];
    int i;
    struct my_file* pak_file;
    off_t pak_size;
    ssize_t nbr;

    if( init_pak_header(p_pak_hdr) == -1 ) {
        return -1;
    }

    /* open file */
    pak_file = my_open(pak_filename, "rb", program_name);
    if (pak_file == NULL) {
        return -1;
    }

    /* fill buffer */
    nbr = my_read(pak_file, buf, PAK_HDR_SIZE);
    if( nbr != PAK_HDR_SIZE ) {
        /* read error or file too small */
        if( nbr != -1 ) {
            fprintf(
                ERROR_CHANNEL, 
                "%s: File `%s' is not a pak archive: File too small\n",
                program_name,
                pak_filename);
        }
        rv = -1; 
        goto RETURN;
    }

    /* magic */
    for( i=0; i<PAK_MAGIC_SIZE; i++ ) {
        p_pak_hdr->magic[i] = buf[i];
    }

    /* toc offset */
    p_pak_hdr->toc_off= UCHARs_2_off_t( buf+PAK_MAGIC_SIZE );

    /* toc size */
    p_pak_hdr->toc_sze= UCHARs_2_off_t( buf+PAK_MAGIC_SIZE+PAK_OFFSET_SIZE );

    /* pak size */
    pak_size = my_lseek(pak_file, 0, SEEK_END);
    if (pak_size == -1) {
        rv= -1; 
        goto RETURN; 
    }
    p_pak_hdr->pak_sze= pak_size;

RETURN:
    if( my_close(pak_file) == -1 ) {
        return -1;
    }

    return rv;
}

/* overwrites header of pak archive with values from p_pak_hdr */
/* returns -1 on error */
static
int 
write_pak_header(
    struct my_file *          pak_file,  /* open pak file */
    const struct pak_header*  p_pak_hdr  /* pak header */
)
{
    int rval;
    unsigned char buf[PAK_HDR_SIZE];
    int i;

    if( p_pak_hdr == NULL || pak_file == NULL) {
        return -1;
    }

    /* seek to the begining (where the header should be written) */
    rval = my_lseek(pak_file, 0, SEEK_SET);
    if (rval != 0) {
        return -1;
    }

    /* magic */
    for( i=0; i<PAK_MAGIC_SIZE; i++ ) {
        buf[i]= p_pak_hdr->magic[i];
    }

    /* toc offset */
    off_t_2_UCHARs( p_pak_hdr->toc_off, buf+PAK_MAGIC_SIZE );

    /* toc size */
    off_t_2_UCHARs( p_pak_hdr->toc_sze, buf+PAK_MAGIC_SIZE+PAK_OFFSET_SIZE );

    rval = my_write(pak_file, buf, PAK_HDR_SIZE);
    if (rval != PAK_HDR_SIZE) { 
        return -1;
    }

    return rval;
}


/* returns number of toc entries or -1 on error */
static
int 
check_pak_header(
    struct pak_header*  p_pak_hdr,  /* pak header */
    const char*         pak_filename, /* pak file name */
    const char*         program_name  /* name of main prg. */
)
{
    int noe;
    if( strcmp(p_pak_hdr->magic,PAK_MAGIC) ) {
        fprintf(
            ERROR_CHANNEL,
            "%s: File `%s' is not a pak archive. %s.\n",
            program_name, 
            pak_filename, 
            "Wrong magic number");
        return -1;
    }

    if( p_pak_hdr->toc_off < (off_t)PAK_HDR_SIZE ) {
        fprintf(
            ERROR_CHANNEL,
            "%s: Pak archive `%s' corrupted. Toc offset = %d.\n",
            program_name, 
            pak_filename, 
            (int)p_pak_hdr->toc_off);
        return -1; 
    }

    if( p_pak_hdr->toc_sze < (off_t)0 ) {
        fprintf(
            ERROR_CHANNEL,
            "%s: Pak archive `%s' corrupted. Toc size = %d.\n",
            program_name, 
            pak_filename, 
            (int)p_pak_hdr->toc_sze);
        return -1;
    }

    if( p_pak_hdr->pak_sze != p_pak_hdr->toc_off + p_pak_hdr->toc_sze ) {
        fprintf(
            ERROR_CHANNEL,
            "%s: Pak archive `%s' corrupted.  Pak file size (%d) != toc offset (%d) + toc size (%d).\n",
            program_name, 
            pak_filename, 
            (int) p_pak_hdr->pak_sze,
            (int) p_pak_hdr->toc_off,
            (int) p_pak_hdr->toc_sze);
        return -1;
    }

    noe= p_pak_hdr->toc_sze/PAK_TOC_ENTRY_SIZE;
    if( p_pak_hdr->toc_sze%PAK_TOC_ENTRY_SIZE ) {
        fprintf(
            ERROR_CHANNEL,
            "%s: Pak archive `%s' corrupted. %3.2f toc entries.\n",
            program_name, 
            pak_filename, 
            (p_pak_hdr->toc_sze*1.0)/PAK_TOC_ENTRY_SIZE );

        return -1;
    }

#ifndef ALLOW_EMPTY_ARCHIVES
    if( noe == 0 ) {
        fprintf(
            ERROR_CHANNEL,
            "%s: Pak archive `%s' is empty.\n",
            program_name, 
            pak_filename);
        return -1;
    }
#endif

    return noe;
}

/* reallocates memory for array[noe] of pak tocentries */
/* new memory is initialized */
/* returns pointer to tocentry-array or NULL on error or noe==0 */
/* on error the memory is freed */
static
struct pak_tocentry*
realloc_pak_toc(
    struct pak_tocentry*  pak_toc,    /* pak toc */
    int                   noe,        /* number of entries to alloc */
    const char*           program_name 
)
{
    static int noea= 0;       /* number of entries already allocated for */
    struct pak_tocentry* rv;  /* return value */
    int i,imax,j;

    /*
      The following if-statement is neccessary because
      realloc may return non-NULL if size is zero.
    */
    if( noe ) {
      
        rv=realloc(pak_toc,(size_t)(noe*sizeof(struct pak_tocentry)));
        if (rv == NULL) {
            fprintf(
                ERROR_CHANNEL,
                "%s: Allocation problems (%d bytes).\n",
                program_name, 
                noe*sizeof(struct pak_tocentry) );
          
            free( pak_toc );
            return( NULL );
        }
    }
    else {
        rv= NULL;
    }

    /* init new memory */
    imax= sizeof(rv[0].f_nme);
    for( j=noea; j<noe; j++ ) {
        for( i=0; i<imax; i++ ) rv[j].f_nme[i]= '\0';
        rv[j].f_off= (off_t)0;
        rv[j].f_sze= (off_t)0;
    }
    noea= noe;
    return rv;
}


/* returns address of first tocentry or NULL on error or empty pak */
static
struct pak_tocentry* 
read_pak_toc(
    struct pak_header*  p_pak_hdr,  /* pak header */
    const char*         pak_filename, /* pak file name */
    const char*         program_name  /* name of main prg. */
)
{
    struct pak_tocentry* pak_toc;
    struct pak_tocentry* rv;
    int noe= p_pak_hdr->toc_sze/PAK_TOC_ENTRY_SIZE;   /* number of entries */
    unsigned char buf[PAK_TOC_ENTRY_SIZE];
    struct my_file* pak_file;
    ssize_t nbr;
    int i,j;
    if( (pak_toc=realloc_pak_toc(NULL,noe,program_name)) == NULL ) { 
        return NULL; 
    }
    rv= pak_toc;

    /* open the pak file for reading */
    pak_file = my_open(pak_filename,"rb", program_name);
    if (pak_file == NULL) {
        rv = NULL; 
        goto RETURN; 
    }

    /* advance to the table of contents */
    if( my_lseek(pak_file, p_pak_hdr->toc_off, SEEK_SET) != p_pak_hdr->toc_off) {
        rv = NULL; 
        goto RETURN; 
    }

    /* fill entries */
    for( j=0; j<noe; j++ ) {
        nbr = my_read(pak_file, buf, PAK_TOC_ENTRY_SIZE);
        if (nbr != PAK_TOC_ENTRY_SIZE) { 
            /* shouldn't happen if header has been checked against pak size */
            if( nbr > -1 ) {
                fprintf(
                    ERROR_CHANNEL,
                    "%s: Pak archive `%s' corrupted: %s.\n",
                    program_name,
                    pak_filename,
                    "File too small" );
            }
            rv= NULL; 
            goto RETURN;
        }
        for( i=0; i<PAK_TOC_FN_LEN; i++ ) {
            pak_toc[j].f_nme[i]= buf[i];
        }
        pak_toc[j].f_off= UCHARs_2_off_t( buf+PAK_TOC_FN_LEN );
        pak_toc[j].f_sze= UCHARs_2_off_t( buf+PAK_TOC_FN_LEN+PAK_OFFSET_SIZE );
    }
 RETURN:
    if (rv == NULL) {
        realloc_pak_toc( pak_toc, 0, program_name );
    }

    if( my_close(pak_file) == -1 ) {
        return NULL;
    }
    return rv;
}

/* append toc to existing pak archive at p_pak_hdr->toc_off */
/* file header is not read */
/* returns 0 on success or -1 on error */
static
int 
write_pak_toc(
    struct my_file *            pak_file,     /* pak file   */
    const struct pak_header*    p_pak_hdr,    /* pak header */
    const struct pak_tocentry*  pak_toc       /* pak toc    */
)
{
    int pak_noe;
    int rv= 0;
    int i;

    /* seek to the entry that is being written */
    rv = my_lseek(pak_file, p_pak_hdr->toc_off, SEEK_SET);
    if(rv != p_pak_hdr->toc_off) { 
        return -1;
    }

    pak_noe = p_pak_hdr->toc_sze/PAK_TOC_ENTRY_SIZE;
    for( i=0; i<pak_noe; i++ ) {
        /* fill buffer */
        unsigned char buf[PAK_TOC_ENTRY_SIZE];

        memset(buf, 0x00, PAK_TOC_FN_LEN);
        strcpy( (char*)buf, pak_toc[i].f_nme );

        off_t_2_UCHARs( pak_toc[i].f_off, buf+PAK_TOC_FN_LEN );

        off_t_2_UCHARs( pak_toc[i].f_sze, buf+PAK_TOC_FN_LEN+PAK_OFFSET_SIZE );

        /* write buffer to pak file */
        rv = my_write(pak_file,buf,PAK_TOC_ENTRY_SIZE);
        if( rv == -1 ) {
            return -1; 
        }
    }

    return 0;
}


/* returns 0 on success or -1 on error */
static
int 
check_pak_toc(
    const struct pak_tocentry*  pak_toc,      /* pak toc */
    int                         noe,          /* number of entries */
    const char*                 pak_filename, /* pak file name */
    const char*                 program_name  /* name of main prg. */
)
{
    int j;

    if( pak_toc == NULL ) {
        return 0; /* empty toc is legal */
    }

    if( pak_toc[0].f_off != PAK_HDR_SIZE ) {

        fprintf(
            ERROR_CHANNEL,
            "%s: Pak archive `%s' corrupted (toc entry %d).\n",
            program_name, 
            pak_filename, 
            0);
        return -1;
    }
    
    for( j=1; j<noe; j++ ) {
        /* make sure that none of the toc entries are overlapping */
        if( pak_toc[j].f_off < pak_toc[j-1].f_off + pak_toc[j-1].f_sze ) {

            fprintf(
                ERROR_CHANNEL,
                "%s: Pak archive `%s' corrupted (toc entry %d).\n",
                program_name,
                pak_filename,
                j);

            return -1;
        }
    }

    return 0; /* it's good */
}


/* returns number of files listed or -1 on error */
static
int 
list_pak_toc(
    struct pak_tocentry* pak_toc,    /* pak toc */
    int                  pak_noe,    /* number of entries */
    const char*          list,       /* file name list */
    int                  verbose,    /* verbose flag */
    int                  force,      /* force flag */
    const char*          pak_filename, /* pak file name */
    const char*          program_name  /* name of main prg. */
)
{
  int list_noe;
  unsigned char* list_mark= NULL;
  int maxlen= 0;
  int i,j;
  char* fn;
  int nbl= 0;           /* number of bytes listed */
  int nfl= 0;           /* number of files listed */
  int tnb= 0;           /* total number of bytes */

  if( (list_noe=is_in_list(list,"")-1) ) {
      
      if( (list_mark=malloc((list_noe)*sizeof(unsigned char))) == NULL ) {
          
          fprintf( 
              ERROR_CHANNEL, 
              "%s: Allocation problem (%d bytes).\n",
              program_name, 
              list_noe*sizeof(unsigned char) );

          return -1;
      }
      for( j=0; j<list_noe; j++ ) {
          list_mark[j]= (unsigned char)0;
      }
  }

  /* find length of longest filename */
  for( j=0; j<pak_noe; j++ ) {
      fn= pak_toc[j].f_nme;
      if( list_noe==0 || is_in_list(list,fn) ) {
          maxlen= strlen(fn) > maxlen ? strlen(fn) : maxlen;
      }
  }

  /* list */
  for( j=0; j<pak_noe; j++ ) {

      fn= pak_toc[j].f_nme;
      tnb+= pak_toc[j].f_sze;
      if( list_noe==0 || is_in_list(list,fn) ) {
          nfl++;
          nbl+= pak_toc[j].f_sze;
          if( list_noe ) list_mark[is_in_list(list,fn)-1]= (unsigned char)1;
          printf( "%s", fn );
          if( verbose ) {
              for( i=strlen(fn); i<maxlen; printf(" "), i++ ) {
                  ;
              }
              printf( "%8d", (int)pak_toc[j].f_sze );
          }
          printf( "\n" );
      }
  }

  if( list_noe && !force ) {
      /* check for specified but unlisted files */
      for( j=0; j<list_noe; j++) {
          if( !list_mark[j] ) {
              fprintf( 
                  ERROR_CHANNEL, 
                  "%s: File `%s' not found in archive.\n",
                  program_name, 
                  list_entry(list, j));
          }
      }
  }

  if( verbose ) {

    printf( "Summary for pak archive `%s': \n", pak_filename);
    printf( "  Listed: %d file%s, %d bytes\n",
            nfl, nfl>1?"s":"",nbl );
    printf( "   Total: %d file%s, %d bytes\n",
            pak_noe, pak_noe>1?"s":"",tnb );
  }

  free( list_mark );
  if( nfl<list_noe && !force ) {
      return -1;
  }

  return nfl;
}


/* returns number of files extracted or -1 on error */
static
int 
extract_pak(
    struct pak_tocentry* pak_toc,      /* pak toc */
    int                  pak_noe,      /* number of entries */
    const char*          list,         /* file name list */
    int                  verbose,      /* verbose flag */
    int                  force,        /* force flag */
    const char*          pak_filename, /* pak file name */
    const char*          program_name  /* name of main prg. */
)
{
    int list_noe;
    unsigned char* list_mark= NULL;
    int nbe= 0;       /* number of bytes extracted */
    int nfe= 0;       /* number of files extracted */
    int tnb= 0;       /* total number of bytes */
    int j;
    struct my_file* pak_file;

    if( (list_noe=is_in_list(list,"")-1) ) { 
        /* set up marker array and init */
        list_mark = malloc((list_noe)*sizeof(unsigned char));
        if(list_mark == NULL) {

            fprintf(
                ERROR_CHANNEL, 
                "%s: Allocation problem (%d bytes).\n",
                program_name, 
                list_noe*sizeof(unsigned char) );
            return -1;
        }

        for( j=0; j<list_noe; j++ ) {
            list_mark[j]= (unsigned char)0;
        }
    }

    /* open the pak file for reading (to extract entries) */
    pak_file = my_open(pak_filename, "rb", program_name);
    if (pak_file == NULL) { 
        nfe= -1; 
        goto RETURN; 
    }

    /* extract each requested entry */
    for( j=0; j<pak_noe; j++ ) {

        const char* entry_filename; /* filename from pak-toc == name of generated file */
        struct my_file * entry_file;
        off_t offset;
        off_t size;

        entry_filename = pak_toc[j].f_nme;
        offset         = pak_toc[j].f_off;
        size           = pak_toc[j].f_sze;
        tnb+= size;
        if( list_noe==0 || is_in_list(list,entry_filename) ) { 
            /* extract one file */

            unsigned char buf[CP_BUF_SIZE];   /* buffer for copying */
            ssize_t rem= size;     /* remaining bytes */
            ssize_t nbr;
            ssize_t nbtr;
            int rval;
            if( verbose ) {
                printf( "%s, %d bytes\n", entry_filename, (int)size );
            }

            /* seek to the begining of the entry */
            rval = my_lseek( pak_file, offset, SEEK_SET);
            if (rval != offset) {
                nfe = -1; 
                goto RETURN; 
            }

            /* create the directory for this entry */
            if( my_mkdir(entry_filename, program_name) == -1 ) { 
                nfe= -1; 
                goto RETURN; 
            } 

            entry_file = my_open(entry_filename, "wb", program_name);
            if (entry_file == NULL) { 
                nfe= -1; goto RETURN; 
            }

            while( rem > 0 ) {

                nbtr = MIN(rem, CP_BUF_SIZE);
                nbr  = my_read(pak_file, buf, nbtr);
                if( nbr != nbtr ) { 
                    /* shouldn't happen if pak-toc has been checked against pak size */
                    fprintf(
                        ERROR_CHANNEL, 
                        "%s: Pak archive `%s' corrupted: %s.\n",
                        program_name, 
                        pak_filename, 
                        "File too small");
                        
                    nfe = -1; 
                    my_close(entry_file);
                    goto RETURN;
                }
                    
                if( my_write(entry_file, buf, nbr) == -1 ) { 
                    nfe= -1; 
                    my_close(entry_file);
                    goto RETURN; 
                }
                rem-= nbr;
            }

            if (my_close(entry_file) == -1) {
                nfe= -1; 
                goto RETURN; 
            }
            if( list_noe ) {
                list_mark[is_in_list(list,entry_filename)-1]= (unsigned char)1;
            }
            
            nfe++;
            nbe+= size;
        }
    }

    if( list_noe && !force ) { 
        /* check for specified but unextracted files */
        for( j=0; j<list_noe; j++) {
            
            if( !list_mark[j] ) {
                fprintf( 
                    ERROR_CHANNEL, 
                    "%s: File `%s' not found in archive.\n",
                    program_name, 
                    list_entry(list,j));
            }
        }
        if( verbose ) {
            printf( "Summary for pak archive `%s': \n", pak_filename );
            printf( "  Extracted: %d file%s, %d bytes\n",
                    nfe, nfe>1?"s":"", nbe );
            printf( "      Total: %d file%s, %d bytes\n",
                    pak_noe, pak_noe>1?"s":"", tnb );
        }
    }

 RETURN:
    free( list_mark );
    my_close(pak_file);
    if( nfe<list_noe && !force ) {
        return -1;
    }
    return nfe;
}

/* writes files from list to pak archive at PAK_HDR_SIZE */
/* sets up pak_toc and updates p_pak_hdr */
/* neither pak_toc nor p_pak_hdr is written */
/* returns pac_toc on success or NULL on error or empty list */
static
struct pak_tocentry*
write_pak(
    struct my_file *     pak_file,   /* pak file */
    struct pak_header*   p_pak_hdr,  /* pak header */
    const char*          list,       /* file (name) list */
    int                  verbose,    /* be talketive */
    int                  force,      /* ignore some errors */
    const char*          program_name  /* name of main prg. */
)
{
    struct pak_tocentry* pak_toc;
    struct pak_tocentry* rv;
    off_t pak_off;
    int pak_noe= 0;
    off_t sze;
    int j;
    int list_noe= is_in_list(list,"")-1;
    unsigned char buf[CP_BUF_SIZE];   /* copy buffer */
    ssize_t rem;          /* remaining bytes */
    ssize_t nbr;          /* number of bytes read */
    ssize_t nbtr;         /* number of bytes to read */

    p_pak_hdr->toc_sze= list_noe*PAK_TOC_ENTRY_SIZE;    /* for error detection */

    /* create the table of contents */
    pak_toc = realloc_pak_toc(NULL,list_noe,program_name);
    if (pak_toc == NULL) {
        /* out-of-memory or empty list */
        return NULL;
    }

    /* seek to the table of contents */
    pak_off = my_lseek(pak_file, PAK_HDR_SIZE, SEEK_SET);
    if( pak_off != PAK_HDR_SIZE) { 
        rv = NULL; 
        goto RETURN; 
    }

    /* write each entry into the pak file */
    for( j=0; j<list_noe; j++ ) {

        const char* entry_filename;
        struct my_file* entry_file;

        entry_filename = list_entry( list, j );
        if (DEBUG) {
            fprintf(
                DEBUG_CHANNEL,
                "DEBUG: write_pak(): Processing `%s' (list index %d).\n", 
                entry_filename, 
                j);
        }


        if( strlen(entry_filename)+1 > MAX_FN_LEN ) { 
            /* name too long */
            if( force ) {
                p_pak_hdr->toc_sze-= PAK_TOC_ENTRY_SIZE;
                continue;
            }
            rv = NULL; 
            goto RETURN;
        }

        /* open the entry for reading */
        entry_file = my_open(entry_filename, "rb", program_name);
        if (entry_file == NULL) {

            if( force ) {
                p_pak_hdr->toc_sze-= PAK_TOC_ENTRY_SIZE;
                continue;
            }

            rv = NULL; 
            goto RETURN;
        }

        /* determine the length of this entry */
        sze = my_lseek(entry_file, 0, SEEK_END);
        if (sze == -1) { 
            my_close(entry_file); 
            rv = NULL; 
            goto RETURN; 
        }

        /* seek back to the begining of the file*/
        my_lseek(entry_file, 0, SEEK_SET);

        /* copy data of one file */
        if (DEBUG) {
            fprintf(
                DEBUG_CHANNEL,
                "DEBUG: write_pak(): Copying file `%s' to pak file @ %#08x\n", 
                entry_filename, 
                (unsigned int) pak_off);
        }

        if ( verbose ) {
            printf( "%s, %d bytes\n", entry_filename, (int)sze );
        }

        rem = sze;
        while( rem > 0 ) {
            nbtr = MIN(rem, CP_BUF_SIZE);
            nbr  = my_read(entry_file, buf, nbtr);

            if( nbr != nbtr ) {
                /* shouldn't happen since size is known from lseek */

                if (nbr != -1) {

                    fprintf( 
                        ERROR_CHANNEL, 
                        "%s: Cannot read from file `%s': %s.\n",
                        program_name, 
                        entry_filename, 
                        "File too small");
                }
                
                my_close(entry_file); 
                rv = NULL;
                goto RETURN;
            }
                
            /* write this block into the pak file */
            if( my_write(pak_file, buf, nbr) == -1 ) {
                my_close(entry_file);
                rv= NULL;
                goto RETURN; 
            }
            rem-= nbr;
        }

        /* set toc data */
        strcpy( pak_toc[pak_noe].f_nme, entry_filename);
        pak_toc[pak_noe].f_off= pak_off;
        pak_toc[pak_noe].f_sze= sze;
        pak_noe++;
        pak_off+= sze;
        if (my_close(entry_file) == -1) {
            rv = NULL;
            goto RETURN;
        }
    }

    /* update p_pak_hdr */
    p_pak_hdr->toc_off= pak_off;
    p_pak_hdr->toc_sze= pak_noe*PAK_TOC_ENTRY_SIZE;
    rv = pak_toc;

 RETURN:

    if( rv == NULL ) {
        free(pak_toc);
    }
    return rv;
}


static
int
action_extract(
    const char * pak_filename,
    const char * file_list,
    int          verbose,
    int          force,
    const char * program_name
)
{
    int retval = RETVAL_OK;

    struct pak_header pak_hdr;           /* pak file header */
    struct pak_tocentry *pak_toc = NULL; /* pak file toc (array of tocentries) */
    int pak_nf;                          /* pak file number of files contained */

    if( read_pak_header(&pak_hdr,pak_filename,program_name) == -1 ) { 
        retval= RETVAL_ERROR; 
        goto RETURN; 
    }

    pak_nf = check_pak_header(&pak_hdr,pak_filename,program_name);
    if( pak_nf == -1 ) { 
        retval= RETVAL_ERROR; 
        goto RETURN; 
    }
    if( (pak_toc=read_pak_toc(&pak_hdr,pak_filename,program_name)) == NULL && pak_nf ) { 
        retval= RETVAL_ERROR; 
        goto RETURN; 
    }
    if( check_pak_toc(pak_toc,pak_nf,pak_filename,program_name) == -1 ) { 
        retval= RETVAL_ERROR; 
        goto RETURN; 
    }
    if( extract_pak(pak_toc,pak_nf,file_list,verbose,force,pak_filename,program_name) == -1 ) { 
        retval= RETVAL_ERROR; 
        goto RETURN; 
    }

 RETURN:
    free(pak_toc); 
    return retval;
}


static
int
action_list(
    const char * pak_filename,
    const char * file_list,
    int          verbose,
    int          force,
    const char * program_name
)
{
    int retval = RETVAL_OK;
    
    struct pak_header pak_hdr;           /* pak file header */
    struct pak_tocentry *pak_toc = NULL; /* pak file toc (array of tocentries) */
    int pak_nf;                          /* pak file number of files contained */

    if (pak_filename == NULL) {
        retval= RETVAL_ERROR; 
        goto RETURN; 
    }

    if( read_pak_header(&pak_hdr,pak_filename, program_name) == -1 ) {
        retval= RETVAL_ERROR; 
        goto RETURN; 
    }
    
    pak_nf = check_pak_header(&pak_hdr,pak_filename, program_name);
    if (pak_nf == -1) { 
        retval= RETVAL_ERROR; 
        goto RETURN; 
    }
    
    if (DEBUG) {
        fprintf(DEBUG_CHANNEL, "DEBUG: pak size  = %#08x\n",(unsigned int)pak_hdr.pak_sze);
        fprintf(DEBUG_CHANNEL, "DEBUG: toc offset= %#08x\n",(unsigned int)pak_hdr.toc_off);
        fprintf(DEBUG_CHANNEL, "DEBUG: toc size  = %#08x\n",(unsigned int)pak_hdr.toc_sze);
        fprintf(DEBUG_CHANNEL, "DEBUG: files     = %d\n",pak_nf);
    }
    
    pak_toc = read_pak_toc(&pak_hdr,pak_filename,program_name);
    if (pak_toc == NULL && pak_nf != 0) { 
        retval= RETVAL_ERROR; 
        goto RETURN; 
    }
    
    if (check_pak_toc(pak_toc, pak_nf, pak_filename, program_name) == -1 ) { 
        retval= RETVAL_ERROR; 
        goto RETURN; 
    }
    
    if (list_pak_toc(pak_toc, pak_nf, file_list, verbose, force, pak_filename, program_name) == -1 ) { 
        retval= RETVAL_ERROR; 
        goto RETURN; 
    }

 RETURN:
    free(pak_toc);
    return retval;
}


static
int
action_create(
    const char * pak_filename,
    const char * file_list,
    int          verbose,
    int          force,
    const char * program_name
)
{
    int retval = RETVAL_OK;
    
    struct pak_header pak_hdr;           /* pak file header */
    struct pak_tocentry *pak_toc = NULL; /* pak file toc (array of tocentries) */

    struct my_file * pak_file = NULL;

    if( init_pak_header(&pak_hdr) == -1 ) { 
        retval= RETVAL_ERROR; 
        goto RETURN; 
    }

    pak_file = my_open(pak_filename, "wb", program_name);
    
    /* write a place-holder header */
    if( write_pak_header(pak_file, &pak_hdr) == -1 ) { 
        retval= RETVAL_ERROR; 
        goto RETURN; 
    }

    /* write out the pak entries.  this generates a toc */
    pak_toc = write_pak(pak_file, &pak_hdr, file_list, verbose, force, program_name);
    if (pak_toc == NULL && pak_hdr.toc_sze != 0) { 
        retval= RETVAL_ERROR; 
        goto RETURN; 
    }

    /* write out the table of contents */
    if( write_pak_toc(pak_file, &pak_hdr, pak_toc) == -1 ) { 
        retval= RETVAL_ERROR; 
        goto RETURN; 
    }

    /* write the header that has the correct values filled in */
    if( write_pak_header(pak_file, &pak_hdr) == -1 ) {
        retval= RETVAL_ERROR; 
        goto RETURN; 
    }

    if (!ALLOW_EMPTY_ARCHIVES) {

        if( pak_hdr.toc_sze==0 ) {

            fprintf(
                ERROR_CHANNEL, 
                "%s: Creation of empty archives not allowed.\n",
                program_name);

            retval = RETVAL_ERROR;
        }
    }

 RETURN:
    free(pak_toc);
    my_close(pak_file);

    /* remove botched pak files, on error */
    if( retval==RETVAL_ERROR && pak_filename != NULL ) {
        remove(pak_filename);
    }

    return retval;
}

/*
 * strip directory from name
 * returns pointer to stripped name
 * hint: basename("/usr/bin/") == ""
 *   basename(1) would return "bin" !!
 */
static
const char*
basename( 
    const char* name 
) 
{
    const char* p= name;
    /* seek to the end of name */
    while( *p != '\0' ) {
        p++;
    }
    /* seek backward to the last directory delimiter */
    while( p > name ) {
        if( *(p-1) == '/' || *(p-1) == '\\') {
            break;
        }

        p--;
    }
    
    return p;
}



/*
 * main() par
 * started      : Sat Jul 4 00:33:50 MET DST 1998 @beast
 */
int 
main( 
    int            argc, 
    char * const * argv
) 
{
    /*** getopt stuff ***/
    int c;
    /*** options stuff ***/
    int action= ACTION_NONE;
    int indirect_files= 0;
    int force= 0;
    int verbose= 0;
    /*** file stuff ***/
    const char *pak_filename= NULL;  /* pak file name */

    int nbr;
    /*** miscellanious ***/
    const char *file_list= add_to_list(""); /* init list */
    int retval= RETVAL_OK;
    const char* full_program_name = argv[0]; /* full program name */
    const char* program_name      = basename(full_program_name);
    int i;
    int index;
    int eof_reached;


    /***** process options *****/

    while( (c=getopt(argc,argv,"cfhltvxV")) != EOF ) {
        switch( c ) {

        case 'c': /* action: create */
            if( action == ACTION_NONE ) {
                action= ACTION_CREATE;
            }
            else {
                fprintf(
                    ERROR_CHANNEL,
                    "%s: Two actions specified. Try -h for help.\n", 
                    program_name);
                retval = RETVAL_ERROR; 
                goto RETURN;
            }
            break;
        
        case 'f': /* force action */
            force= 1;
            break;
        
        case 'h': /* display help to HELP_CHANNEL and exit sucessfully */
            display_help( program_name );
            retval= RETVAL_OK; 
            goto RETURN;
        
        case 'l': /* action: list */
            if( action == ACTION_NONE ) {
                action= ACTION_LIST;
            }
            else {
                fprintf( 
                    ERROR_CHANNEL,
                    "%s: Two actions specified. Try -h for help.\n", 
                    program_name);
                retval= RETVAL_ERROR; 
                goto RETURN;
            }
            break;
        
        case 't': /* get filenames from specified files */
            indirect_files= 1;
            break;

        case 'v': /* be verbose */
            verbose++;
            break;

        case 'x': /* action: extract */
            if( action == ACTION_NONE ) {
                action= ACTION_EXTRACT;
            }
            else {
                fprintf( ERROR_CHANNEL,
                         "%s: Two actions specified. Try -h for help.\n", program_name );
                retval= RETVAL_ERROR; 
                goto RETURN;
            }
            break;

        case 'V': /* display version to VERSION_CHANNEL and exit sucessfully */
            display_version( program_name );
            retval= RETVAL_OK; 
            goto RETURN;
        
        case '?': /* refer to -h and exit unsucessfully */
            fprintf( 
                ERROR_CHANNEL, 
                "%s: Try `%s -h' for more information.\n",
                program_name, 
                full_program_name);
            retval= RETVAL_ERROR; 
            goto RETURN;

        default : /* program error */
            fprintf(
                ERROR_CHANNEL, 
                "%s: Options bug! E-mail me at %s.\n",
                program_name, 
                MY_EMAIL_ADDRESS);

            retval= RETVAL_BUG; 
            goto RETURN;
        }
    }

    if( action == ACTION_NONE ) {
        fprintf( ERROR_CHANNEL, "%s: No action specified. Try -h for help.\n", program_name );
        retval= RETVAL_ERROR;
        goto RETURN;
    }

    /***** set pak_filename *****/
    if( optind == argc ) {
        fprintf( ERROR_CHANNEL, "%s: No archive specified.\n", program_name );
        retval= RETVAL_ERROR;
        goto RETURN;
    }

    pak_filename = argv[optind];

    /***** get file list *****/
    for( index=optind+1; index<argc; index++ ) {
        const char * temp_filename = argv[index];
        if( indirect_files ) {
            struct my_file * temp_file;
            char entry_filename[MAX_FN_LEN];

            /* add names from file tmp_filename to list */
            temp_file = my_open(temp_filename, "rb", program_name);
            if (temp_file == NULL) {
                retval = RETVAL_ERROR;
                goto RETURN;
            }

            /* spaces are allowed; separator is a newline */
            eof_reached= 0;
            while( !eof_reached ) {
                /* read file name to buffer one byte at a time */
                for( i=0; i<MAX_FN_LEN; i++ ) {
                    nbr = my_read(temp_file, &entry_filename[i], 1);
                    if (nbr == -1) {
                        my_close(temp_file);
                        retval= RETVAL_ERROR; 
                        goto RETURN;
                    }
                    if (nbr == 0) {
                        eof_reached= 1;
                        entry_filename[i] = '\0';
                        break;
                    }
                    if (entry_filename[i] == '\n' ||
                        entry_filename[i] == '\r') {
                        /* treat '\r\n' as the end of line for MS-DOS */
                        entry_filename[i] = '\0';
                        break;
                    }
                }
                if (i == MAX_FN_LEN) {
                    entry_filename[i-1] = '\0';
                    fprintf( 
                        ERROR_CHANNEL,
                        "%s: File name `%s' from file `%s' too long.\n",
                        program_name, 
                        entry_filename, 
                        temp_filename);

                    my_close(temp_file);
                    retval = RETVAL_ERROR; 
                    goto RETURN;
                }

                /* ignore blank lines */
                if (entry_filename[0] != '\0') {

                    /* add file name to list */
                    file_list = add_to_list(entry_filename);
                    if( file_list == NULL ) { 
                        fprintf(ERROR_CHANNEL, "%s: Allocation problem.\n", program_name);
                        my_close(temp_file);
                        retval= RETVAL_ERROR;
                        goto RETURN;
                    }
                }
            }

            my_close(temp_file);
        }
        else {
            /* add temp_filename to list */
            if( strlen(temp_filename) >= MAX_FN_LEN ) {

                fprintf( 
                    ERROR_CHANNEL, 
                    "%s: File name `%s' too long.\n",
                    program_name, 
                    temp_filename);

                retval= RETVAL_ERROR; 
                goto RETURN;
            }

            file_list = add_to_list(temp_filename);
            if( file_list == NULL ) {
                fprintf(ERROR_CHANNEL, "%s: Allocation problem.\n", program_name);
                retval= RETVAL_ERROR; 
                goto RETURN;
            }
        }
    }

    if (DEBUG) {

        fprintf( 
            DEBUG_CHANNEL, 
            "DEBUG: main(): List has %d entries, namely:\n", 
            is_in_list(file_list,"")-1 );

        for( i=0; i<is_in_list(file_list,"")-1; i++ )
            fprintf( 
                DEBUG_CHANNEL, 
                "DEBUG: main(): %d - %p - `%s'\n", 
                i, 
                list_entry(file_list,i), 
                list_entry(file_list,i));
    }


    /***** do the dirty work *****/
    switch( action ) {
    case ACTION_LIST: /* list table of contents */

        retval = action_list(
            pak_filename, 
            file_list,
            verbose,
            force,
            program_name);
        break;

    case ACTION_EXTRACT: /* extract file(s) */

        retval = action_extract(
            pak_filename, 
            file_list,
            verbose,
            force,
            program_name);

        break;

    case ACTION_CREATE: /* create new pak file */

        retval = action_create(
            pak_filename, 
            file_list,
            verbose,
            force,
            program_name);

        break;

    default: /* program error */
        fprintf( 
            ERROR_CHANNEL, 
            "%s: Action %d unknown! E-mail me at %s.\n",
            program_name, 
            action, 
            MY_EMAIL_ADDRESS );
        retval = RETVAL_BUG; 
        break;
    }

 RETURN:
    return retval;
}
