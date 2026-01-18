/*
** TinyCmdr - A simple TUI file commander for cc65.
** Inspired by Norton Commander and Midnight Commander.
**
** (C) Thorsten Hindermann, 2026
*/

#include <stdio.h>    /* Standard I/O functions */
#include <stdlib.h>   /* Standard library functions */
#include <string.h>   /* String manipulation functions */
#include <conio.h>    /* Console I/O functions */
#include <unistd.h>   /* POSIX operating system API */
#include <errno.h>    /* Error number definitions */
#include <dbg.h>      /* Debugging support */
#include "tinycmdr.h" /* Global declarations and state */

/*****************************************************************************
 * Function:    main                                                         *
 *                                                                           *
 * Description: Main program entry point. Initializes the screen environment, *
 *              reads the current directory, and enters the main application *
 *              loop for UI updates and input handling.                      *
 *                                                                           *
 * Parameters:  None.                                                        *
 *                                                                           *
 * Returns:     The program exit code (standard 0 for success).              *
 *****************************************************************************/
int main(void) {
    /* Initialize the debugger */
    DbgInit(0);

    /* Initialize colors and screen */
    (void)bordercolor(COLOR_BLUE);
    (void)bgcolor(BGC);
    (void)textcolor(TEXT_COLOR);
    clrscr();
    cursor(0);

#ifdef HAVE_SUBDIRS
    getcwd(left_path, 255);
#else
    strcpy(left_path, ".");
#endif
    strcpy(right_path, left_path);

    read_directory(left_path, left_files, &left_count);
    read_directory(right_path, right_files, &right_count);

    while (1) {
        /* Update the display with current panel contents and status */
        draw_ui();
        /* Wait for and process user input */
        handle_input();
    }
}
