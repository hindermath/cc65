/*
** TinyCmdr - A simple TUI file commander for cc65.
** Inspired by Norton Commander and Midnight Commander.
**
** (C) Thorsten Hindermann, 2026
*/

#ifndef TINYCMDR_H
#define TINYCMDR_H

#if defined(__APPLE2__) || defined(__ATARI__)
#define HAVE_SUBDIRS 1       /* Enable subdirectory support for specific platforms */
#endif

/* Defines for UI layout and limits */
#define MAX_FILES 144        /* Maximum number of files to display in a list panel */
#define COL_WIDTH 19         /* Width of each directory column (panel) in characters */
#define COL_HEIGHT 21        /* Height of each directory column (panel) in characters */
#define LEFT_COL_X 0         /* X-coordinate (left edge) of the left panel */
#define RIGHT_COL_X 20       /* X-coordinate (left edge) of the right panel */
#define TOP_Y 1              /* Y-coordinate (top edge) of the file panels */
#define PROMPT_Y 22          /* Y-coordinate for the input prompt and messages */
#define SHORTCUT_Y 23        /* Y-coordinate for the shortcut/function keys bar at the bottom */

/* Colors - based on tinycmdr.md specification */
/* background blue, unselected white, selected yellow, subdirs green */
#define BGC COLOR_BLUE       /* Application background color */
#define TEXT_COLOR COLOR_WHITE /* Standard text color for file names and UI */
#define SEL_COLOR COLOR_YELLOW /* Highlight color for the currently selected item */
#define DIR_COLOR COLOR_GREEN /* Color to distinguish directory entries from files */

/*****************************************************************************
 * Structure:   file_entry                                                   *
 *                                                                           *
 * Description: Represents a single file or directory entry in the file      *
 *              list, including its name, type, and directory status.        *
 *****************************************************************************/
typedef struct {
    char name[32];          /* Filename (null-terminated) */
    unsigned char is_dir;   /* Flag: 1 if entry is a directory, 0 otherwise */
    unsigned char type;     /* CBM file type (e.g., SEQ, PRG, DIR) */
} file_entry;

/* Global state - Extern declarations to be defined in tcmdrlib.c */
extern file_entry left_files[MAX_FILES];  /* File entries currently loaded in the left panel */
extern int left_count;                   /* Total number of file entries in the left panel */
extern int left_sel;                     /* Index of the currently highlighted file in the left panel */
extern int left_top;                     /* Index of the first visible file in the left panel (for scrolling) */
extern char left_path[256];              /* Current working directory or device path for the left panel */

extern file_entry right_files[MAX_FILES]; /* File entries currently loaded in the right panel */
extern int right_count;                  /* Total number of file entries in the right panel */
extern int right_sel;                    /* Index of the currently highlighted file in the right panel */
extern int right_top;                    /* Index of the first visible file in the right panel (for scrolling) */
extern char right_path[256];             /* Current working directory or device path for the right panel */

extern int active_col; /* Index of the panel that currently has keyboard focus (0: left, 1: right) */

/* Prototypes */

/*****************************************************************************
 * Function:    read_directory                                               *
 * Description: Reads directory contents and populates file entry arrays.    *
 *****************************************************************************/
void read_directory(const char* path, file_entry* files, int* count);

/*****************************************************************************
 * Function:    draw_frame                                                   *
 * Description: Draws a rectangular frame using character-based symbols.     *
 *****************************************************************************/
void draw_frame(int x, int y, int w, int h);

/*****************************************************************************
 * Function:    draw_ui                                                      *
 * Description: Redraws the complete UI including panels and shortcuts.      *
 *****************************************************************************/
void draw_ui(void);

/*****************************************************************************
 * Function:    update_list                                                  *
 * Description: Renders the file list for a specific panel.                  *
 *****************************************************************************/
void update_list(int col);

/*****************************************************************************
 * Function:    handle_input                                                 *
 * Description: Handles keyboard navigation and command dispatching.         *
 *****************************************************************************/
void handle_input(void);

/*****************************************************************************
 * Function:    execute_command                                              *
 * Description: Executes file operations (copy, delete, rename, etc.).       *
 *****************************************************************************/
void execute_command(int key);

/*****************************************************************************
 * Function:    copy_file                                                    *
 * Description: Copies a file from source to destination.                    *
 *****************************************************************************/
void copy_file(const char* src, const char* dst, unsigned char type);

/*****************************************************************************
 * Function:    get_input                                                    *
 * Description: Reads a string of characters from the user with a prompt.    *
 *****************************************************************************/
void get_input(const char* prompt, char* buffer, unsigned char maxlen);

#endif /* TINYCMDR_H */
