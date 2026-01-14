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

/* Defines */
#define MAX_FILES 144        /* Maximum number of files to display in a list */
#define COL_WIDTH 19         /* Width of each directory column */
#define COL_HEIGHT 21        /* Height of each directory column */
#define LEFT_COL_X 0         /* X-coordinate of the left panel */
#define RIGHT_COL_X 20       /* X-coordinate of the right panel */
#define TOP_Y 1              /* Y-coordinate of the top of the panels */
#define PROMPT_Y 22          /* Y-coordinate for the input prompt */
#define SHORTCUT_Y 23        /* Y-coordinate for the shortcut keys bar */

/* Colors - based on tinycmdr.md */
/* background blue, unselected white, selected yellow, subdirs green */
#define BGC COLOR_BLUE       /* Background color */
#define TEXT_COLOR COLOR_WHITE /* Default text color */
#define SEL_COLOR COLOR_YELLOW /* Color for the selected item */
#define DIR_COLOR COLOR_GREEN /* Color for directory entries */

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

/* Global state */
static file_entry left_files[MAX_FILES]; /* Array of file entries for the left panel */
static int left_count = 0;              /* Number of files in the left panel */
static int left_sel = 0;                /* Index of the currently selected file in the left panel */
static int left_top = 0;                /* Index of the top-most visible file in the left panel */
static char left_path[256];             /* Current directory path of the left panel */

static file_entry right_files[MAX_FILES]; /* Array of file entries for the right panel */
static int right_count = 0;               /* Number of files in the right panel */
static int right_sel = 0;                 /* Index of the currently selected file in the right panel */
static int right_top = 0;                 /* Index of the top-most visible file in the right panel */
static char right_path[256];              /* Current directory path of the right panel */

static int active_col = 0; /* Index of the currently active column (0: left, 1: right) */

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
