/*
 * Simple (Tiny) Text User Interface (TUI) file commander like DOS Norton Commander or Linux Midnight Commander
 * It shpuld be a "graphical" version for the functions of the sample programm tinyshell.
 * (C) 2026 by Thorsten Hindermann, hindermath@tmyttmaap.info
 */

 #define VERSION_ASC "0.91"

 #ifdef __ATARI__
 #define UPPERCASE      /* define (e.g. for Atari) to convert filenames etc. to upper case */
 #define HAVE_SUBDIRS
 #endif

 #ifdef __APPLE2__
 #define HAVE_SUBDIRS
 #endif

 #ifdef __CC65__
 #define CHECK_SP
 #endif

 #define KEYB_BUFSZ 127
 #define PROMPT ">>> "

 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
 #include <errno.h>
 #include <unistd.h>
 #ifndef __CC65__
 #include <sys/stat.h>
 #include <sys/param.h>
 #define HAVE_SUBDIRS
 #else
 #define MAXPATHLEN 64
 #endif
 #include <sys/types.h>
 #include <fcntl.h>
 #include <dirent.h>

 #ifdef CHECK_SP
 extern unsigned int getsp(void);  /* comes from getsp.s */
 #endif

int main()
{
    return EXIT_SUCCESS;
}
