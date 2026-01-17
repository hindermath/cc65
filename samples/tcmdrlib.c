/*
** tcmdrlib.c - Implementation block for TinyCmdr.
**
** (C) Thorsten Hindermann, 2026
*/

#include <stdio.h>    /* Standard I/O functions */
#include <stdlib.h>   /* Standard library functions */
#include <string.h>   /* String manipulation functions */
#include <dirent.h>   /* Directory entry operations */
#include <conio.h>    /* Console I/O functions */
#include <unistd.h>   /* POSIX operating system API */
#include <errno.h>    /* Error number definitions */
#include <fcntl.h>    /* File control options */
#include <ctype.h>    /* Character type functions */
#include <dbg.h>      /* Debugging support */
#include <cc65.h>     /* cc65 specific library functions */
#include "tinycmdr.h" /* Global declarations and state */

/* Global state definitions */
file_entry left_files[MAX_FILES];
int left_count = 0;
int left_sel = 0;
int left_top = 0;
char left_path[256];

file_entry right_files[MAX_FILES];
int right_count = 0;
int right_sel = 0;
int right_top = 0;
char right_path[256];

int active_col = 0;

/*****************************************************************************
 * Function:    get_input                                                    *
 *                                                                           *
 * Description: Displays a prompt and reads a string of characters from the  *
 *              user. Handles backspace/delete for editing and Enter to      *
 *              finish. The cursor is shown during input.                    *
 *                                                                           *
 * Parameters:  prompt - String to display before the input field.           *
 *              buffer - Character buffer where the input will be stored.    *
 *              maxlen - Maximum length of the input string.                 *
 *                                                                           *
 * Returns:     None.                                                        *
 *****************************************************************************/
void get_input(const char* prompt, char* buffer, unsigned char maxlen) {
    unsigned char pos = 0;
    int key;

    buffer[0] = '\0';
    cursor(1);

    while (1) {
        gotoxy(0, PROMPT_Y);
        cclear(40);
        textcolor(COLOR_WHITE);
        cprintf("%s", prompt);
        textcolor(COLOR_YELLOW);
        cprintf("%s", buffer);

        key = cgetc();
        if (key == 13) { /* ENTER */
            break;
        } else if (key == CH_DEL || key == CH_CURS_LEFT || key == 20) { /* 20 is Backspace on C64 */
            if (pos > 0) {
                pos--;
                buffer[pos] = '\0';
            }
        } else if (key >= 32 && key < 127 && pos < maxlen - 1) {
            /* Map uppercase to lowercase if needed, but for drive numbers it doesn't matter.
               However, cc65's cgetc() on C64 might return PETSCII.
               In PETSCII, numbers are the same as ASCII. */
            buffer[pos++] = (char)key;
            buffer[pos] = '\0';
        }
    }
    cursor(0);
}

/*****************************************************************************
 * Function:    read_directory                                               *
 *                                                                           *
 * Description: Reads the contents of a directory and populates an array of  *
 *              file entries. It detects whether an entry is a directory and *
 *              identifies the file type on CBM platforms.                   *
 *                                                                           *
 * Parameters:  path  - The directory path to read.                          *
 *              files - Pointer to the array of file_entry structures.       *
 *              count - Pointer to an integer to store the number of files.  *
 *                                                                           *
 * Returns:     None.                                                        *
 *****************************************************************************/
void read_directory(const char* path, file_entry* files, int* count) {
    static DIR* dir;
    static struct dirent* ent;
#ifdef HAVE_SUBDIRS
    static DIR* subdir;
#endif
    *count = 0;

#ifdef __CBM__
    /* Check if the path is a drive specification like "8:" */
    if (path[0] >= '8' && path[0] <= '9' && path[1] == ':' && path[2] == '\0') {
        dir = opendir(".");
        if (!dir) {
            /* Try opendir with the path as a fallback, although opendir in cc65-cbm
               usually only supports "0:", "1:", or "." */
            dir = opendir(path);
        }
    } else if (path[0] == '1' && (path[1] == '0' || path[1] == '1') && path[2] == ':' && path[3] == '\0') {
        dir = opendir(".");
        if (!dir) {
            dir = opendir(path);
        }
    } else {
        /* Default to path if not a clear drive spec */
        dir = opendir(path);
    }
#else
    dir = opendir(path);
#endif
    if (!dir) return;

    /* Clear existing file list to avoid confusion */
    memset(files, 0, MAX_FILES * sizeof(file_entry));

    while ((*count < MAX_FILES) && (ent = readdir(dir))) {
        strncpy(files[*count].name, ent->d_name, FILENAME_MAX - 1);
        files[*count].name[FILENAME_MAX - 1] = '\0';

#ifdef __CBM__
        files[*count].type = ent->d_type;
        if (ent->d_type == _CBM_T_DIR) {
            files[*count].is_dir = 1;
        } else {
            files[*count].is_dir = 0;
        }
#else
        /* Simple check for directory */
        /* In many cc65 targets, we can't easily check d_type. */
        /* For this 'tiny' app, we'll mark '.' and '..' as dirs. */
        files[*count].type = 0;
        if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0) {
            files[*count].is_dir = 1;
        } else {
#ifdef HAVE_SUBDIRS
            /* Try to opendir it to see if it's a directory */
            subdir = opendir(ent->d_name);
            if (subdir) {
                files[*count].is_dir = 1;
                closedir(subdir);
            } else {
                files[*count].is_dir = 0;
            }
#else
            files[*count].is_dir = 0;
#endif
        }
#endif
        (*count)++;
    }
    closedir(dir);
}

/*****************************************************************************
 * Function:    draw_frame                                                   *
 *                                                                           *
 * Description: Draws a rectangular frame on the screen using standard       *
 *              character-based line drawing symbols.                        *
 *                                                                           *
 * Parameters:  x - Horizontal starting position (left).                     *
 *              y - Vertical starting position (top).                        *
 *              w - Width of the frame.                                      *
 *              h - Height of the frame.                                     *
 *                                                                           *
 * Returns:     None.                                                        *
 *****************************************************************************/
void draw_frame(int x, int y, int w, int h) {
    int i;
    gotoxy(x, y);
    cputc(CH_ULCORNER);
    for (i = 0; i < w - 2; ++i) cputc(CH_HLINE);
    cputc(CH_URCORNER);

    for (i = 1; i < h - 1; ++i) {
        gotoxy(x, y + i);
        cputc(CH_VLINE);
        gotoxy(x + w - 1, y + i);
        cputc(CH_VLINE);
    }

    gotoxy(x, y + h - 1);
    cputc(CH_LLCORNER);
    for (i = 0; i < w - 2; ++i) cputc(CH_HLINE);
    cputc(CH_LRCORNER);
}

/*****************************************************************************
 * Function:    update_list                                                  *
 *                                                                           *
 * Description: Renders the list of files for a specific column (left or     *
 *              right). It handles scrolling, selection highlighting, and    *
 *              color coding for directories vs. files.                      *
 *                                                                           *
 * Parameters:  col - The column index (0 for left, 1 for right).            *
 *                                                                           *
 * Returns:     None.                                                        *
 *****************************************************************************/
void update_list(int col) {
    int i;
    int x = (col == 0) ? LEFT_COL_X + 1 : RIGHT_COL_X + 1;
    int count = (col == 0) ? left_count : right_count;
    int sel = (col == 0) ? left_sel : right_sel;
    int top = (col == 0) ? left_top : right_top;
    file_entry* files = (col == 0) ? left_files : right_files;
    static char type_str[4];

    for (i = 0; i < COL_HEIGHT - 2; ++i) {
        int idx = top + i;
        gotoxy(x, TOP_Y + 1 + i);
        if (idx < count) {
            if (idx == sel && col == active_col) {
                revers(1);
                textcolor(SEL_COLOR);
            } else {
                revers(0);
                if (files[idx].is_dir) textcolor(DIR_COLOR);
                else textcolor(TEXT_COLOR);
            }

            /* Display type on CBM targets */
#ifdef __CBM__
            switch (files[idx].type) {
                case _CBM_T_DEL: strcpy(type_str, "DEL"); break;
                case _CBM_T_SEQ: strcpy(type_str, "SEQ"); break;
                case _CBM_T_PRG: strcpy(type_str, "PRG"); break;
                case _CBM_T_USR: strcpy(type_str, "USR"); break;
                case _CBM_T_REL: strcpy(type_str, "REL"); break;
                case _CBM_T_VRP: strcpy(type_str, "VRP"); break;
                case _CBM_T_CBM: strcpy(type_str, "CBM"); break;
                case _CBM_T_DIR: strcpy(type_str, "DIR"); break;
                case _CBM_T_LNK: strcpy(type_str, "LNK"); break;
                case _CBM_T_OTHER: strcpy(type_str, "OTH"); break;
                case _CBM_T_HEADER: strcpy(type_str, "HDR"); break;
                default: strcpy(type_str, "???"); break;
            }
            cprintf("%-13.13s %s", files[idx].name, type_str);
#else
            cprintf("%-17.17s", files[idx].name);
#endif
        } else {
            revers(0);
            textcolor(TEXT_COLOR);
            cprintf("                 ");
        }
    }
    revers(0);
    textcolor(TEXT_COLOR);
}

/*****************************************************************************
 * Function:    draw_ui                                                      *
 *                                                                           *
 * Description: Redraws the entire user interface, including the two panels,  *
 *              the file lists, and the function key shortcuts at the bottom *
 *              of the screen.                                               *
 *                                                                           *
 * Parameters:  None.                                                        *
 *                                                                           *
 * Returns:     None.                                                        *
 *****************************************************************************/
void draw_ui(void) {
    textcolor(TEXT_COLOR);
    draw_frame(LEFT_COL_X, TOP_Y, COL_WIDTH + 1, COL_HEIGHT);
    draw_frame(RIGHT_COL_X, TOP_Y, COL_WIDTH + 1, COL_HEIGHT);

    update_list(0);
    update_list(1);

    /* Shortcut row (bottom row) */
    gotoxy(0, SHORTCUT_Y);
    cclear(40);
    textcolor(COLOR_CYAN);
    cprintf("1:CP 2:DL 3:RN ");

#ifdef HAVE_SUBDIRS
    textcolor(COLOR_CYAN);
#else
    textcolor(COLOR_GRAY1);
#endif
    cprintf("4:CD 5:MD 6:RD ");

    {
        /* Check if selected file is executable (PRG on CBM) */
        int sel = (active_col == 0) ? left_sel : right_sel;
        int count = (active_col == 0) ? left_count : right_count;
        file_entry* files = (active_col == 0) ? left_files : right_files;
        int is_exe = 0;
        if (sel < count) {
#ifdef __CBM__
            if (files[sel].type == _CBM_T_PRG) is_exe = 1;
#else
            /* On other platforms, we might need a different check,
               but for now we follow the .md which implies 'executable' */
            is_exe = 1;
#endif
        }
        if (is_exe) textcolor(COLOR_CYAN);
        else textcolor(COLOR_GRAY1);
    }
    cprintf("7:EX ");

    textcolor(COLOR_CYAN);
    cprintf("8:QT");
}

/*****************************************************************************
 * Function:    copy_file                                                    *
 *                                                                           *
 * Description: Copies a file from the source path to the destination path.  *
 *              On CBM targets, it handles file types (PRG, SEQ, etc.) and   *
 *              replaces existing destination files.                         *
 *                                                                           *
 * Parameters:  src  - Path of the source file.                              *
 *              dst  - Path of the destination file.                         *
 *              type - CBM file type attribute.                              *
 *                                                                           *
 * Returns:     None.                                                        *
 *****************************************************************************/
void copy_file(const char* src, const char* dst, unsigned char type) {
    static int sfd, dfd;
    static int n;
    static char buf[512];
    static size_t buf_sz = sizeof(buf);
    static char cbm_src[FILENAME_MAX + 10];
    static char cbm_dst[FILENAME_MAX + 10];
    static unsigned char base_type;

#ifdef __CBM__
    /* Use original name for reading */
    strncpy(cbm_src, src, FILENAME_MAX);
    cbm_src[FILENAME_MAX] = '\0';

    /* For writing, first try to delete existing file to avoid "File exists" error */
    /* We build the name with suffix for unlinking too */
    strncpy(cbm_dst, dst, FILENAME_MAX);
    cbm_dst[FILENAME_MAX] = '\0';

    base_type = type & 0x0F;
    if (base_type == (_CBM_T_PRG & 0x0F)) {
        strcat(cbm_dst, ",p");
    } else if (base_type == (_CBM_T_SEQ & 0x0F)) {
        strcat(cbm_dst, ",s");
    } else if (base_type == (_CBM_T_USR & 0x0F)) {
        strcat(cbm_dst, ",u");
    }

    unlink(cbm_dst);
    strcat(cbm_dst, ",w");

    sfd = open(cbm_src, O_RDONLY);
#else
    (void)type;
    sfd = open(src, O_RDONLY);
    strncpy(cbm_dst, dst, FILENAME_MAX);
    cbm_dst[FILENAME_MAX] = '\0';
#endif

    if (sfd < 0) {
        gotoxy(0, PROMPT_Y);
        cclear(40);
        textcolor(COLOR_RED);
        cprintf("SRC ERR %d: %s", errno, cbm_src);
        cgetc();
        return;
    }

    dfd = open(cbm_dst, O_WRONLY | O_CREAT | O_TRUNC, 0666);

    if (dfd < 0) {
        gotoxy(0, PROMPT_Y);
        cclear(40);
        textcolor(COLOR_RED);
        cprintf("DST ERR %d: %s", errno, cbm_dst);
        close(sfd);
        cgetc();
        return;
    }

    while ((n = read(sfd, buf, buf_sz)) > 0) {
        if (write(dfd, buf, n) != n) {
            gotoxy(0, PROMPT_Y);
            cclear(40);
            textcolor(COLOR_RED);
            cprintf("WRITE ERR %d", errno);
            cgetc();
            break;
        }
    }

    close(sfd);
    close(dfd);
}

/*****************************************************************************
 * Function:    execute_command                                              *
 *                                                                           *
 * Description: Processes high-level file operations such as copy, delete,    *
 *              rename, and directory navigation based on the provided key.  *
 *                                                                           *
 * Parameters:  key - The key code representing the command (e.g., F-keys).  *
 *                                                                           *
 * Returns:     None.                                                        *
 *****************************************************************************/
void execute_command(int key) {
    static file_entry* files;
    static int* count;
    static int* sel;
    static int* top;
    static char* path;
    static char filename[FILENAME_MAX];
    static char newname[FILENAME_MAX];
    static int visible_height = COL_HEIGHT - 2;

    files = (active_col == 0) ? left_files : right_files;
    count = (active_col == 0) ? &left_count : &right_count;
    sel = (active_col == 0) ? &left_sel : &right_sel;
    top = (active_col == 0) ? &left_top : &right_top;
    path = (active_col == 0) ? left_path : right_path;

    if (*sel < *count) {
        strcpy(filename, files[*sel].name);
    } else {
        filename[0] = '\0';
    }

    switch (key) {
        case CH_F1: /* CP */
            if (filename[0]) {
                get_input("COPY TO: ", newname, FILENAME_MAX);
                if (newname[0]) {
                    copy_file(filename, newname, files[*sel].type);
                    read_directory(left_path, left_files, &left_count);
                    read_directory(right_path, right_files, &right_count);
                    /* Reset scroll position if count changed significantly */
                    if (left_sel >= left_count) { left_sel = left_count > 0 ? left_count - 1 : 0; }
                    if (left_top + visible_height > left_count) { left_top = left_count > visible_height ? left_count - visible_height : 0; }
                    if (right_sel >= right_count) { right_sel = right_count > 0 ? right_count - 1 : 0; }
                    if (right_top + visible_height > right_count) { right_top = right_count > visible_height ? right_count - visible_height : 0; }
                }
            }
            break;
        case CH_F2: /* DL */
            if (filename[0]) {
                int confirm_key;
                gotoxy(0, PROMPT_Y);
                cclear(40);
                textcolor(COLOR_RED);
                cprintf("DELETE %s? (F2 TO CONFIRM)", filename);
                confirm_key = cgetc();
                if (confirm_key == CH_F2) {
                    unlink(filename);
                    read_directory(left_path, left_files, &left_count);
                    read_directory(right_path, right_files, &right_count);
                    if (*sel >= *count && *count > 0) *sel = *count - 1;
                    if (*top + visible_height > *count) { *top = *count > visible_height ? *count - visible_height : 0; }
                }
                gotoxy(0, PROMPT_Y);
                cclear(40);
            }
            break;
        case CH_F3: /* RN */
            if (filename[0]) {
                get_input("RENAME TO: ", newname, FILENAME_MAX);
                if (newname[0]) {
                    rename(filename, newname);
                    read_directory(left_path, left_files, &left_count);
                    read_directory(right_path, right_files, &right_count);
                }
            }
            break;
        case CH_F4: /* CD */
        case 13:    /* Enter */
#ifdef HAVE_SUBDIRS
            if (filename[0]) {
                if (chdir(filename) == 0) {
                    getcwd(path, 255);
                    read_directory(".", files, count);
                    *sel = 0;
                    if (active_col == 0) left_top = 0; else right_top = 0;
                }
            }
#endif
            break;
        case CH_F5: /* MD */
#ifdef HAVE_SUBDIRS
            get_input("MKDIR: ", newname, FILENAME_MAX);
            if (newname[0]) {
                mkdir(newname, 0777);
                read_directory(left_path, left_files, &left_count);
                read_directory(right_path, right_files, &right_count);
            }
#endif
            break;
        case CH_F6: /* RD */
#ifdef HAVE_SUBDIRS
            if (filename[0]) {
                rmdir(filename);
                read_directory(left_path, left_files, &left_count);
                read_directory(right_path, right_files, &right_count);
            }
#endif
            break;
        case CH_F7: /* EX */
            if (filename[0]) {
                int is_exe = 0;
#ifdef __CBM__
                if (files[*sel].type == _CBM_T_PRG) is_exe = 1;
#else
                is_exe = 1;
#endif
                if (is_exe) {
                    clrscr();
                    exec(filename, "");
                    /* If exec returns, it failed */
                    cprintf("Exec failed: %s\n", strerror(errno));
                    cgetc();
                    clrscr();
                }
            }
            break;
        case CH_F8: /* QT */
            clrscr();
            exit(0);
            break;
    }
}

/*****************************************************************************
 * Function:    handle_input                                                 *
 *                                                                           *
 * Description: Waits for user input and handles navigation (cursor keys)    *
 *              between columns and files, or dispatches function keys to    *
 *              the command execution logic.                                 *
 *                                                                           *
 * Parameters:  None.                                                        *
 *                                                                           *
 * Returns:     None.                                                        *
 *****************************************************************************/
void handle_input(void) {
    static int key;
    int* sel = (active_col == 0) ? &left_sel : &right_sel;
    int* top = (active_col == 0) ? &left_top : &right_top;
    int count = (active_col == 0) ? left_count : right_count;
    int visible_height = COL_HEIGHT - 2;

    key = cgetc();
    switch (key) {
        case CH_CURS_UP:
            if (*sel > 0) {
                (*sel)--;
                if (*sel < *top) {
                    *top = *sel;
                }
            }
            break;
        case CH_CURS_DOWN:
            if (*sel < count - 1) {
                (*sel)++;
                if (*sel >= *top + visible_height) {
                    *top = *sel - visible_height + 1;
                }
            }
            break;
        case CH_CURS_LEFT:
            active_col = 0;
            break;
        case CH_CURS_RIGHT:
            active_col = 1;
            break;
        case 13: /* ENTER */
            execute_command(13);
            break;
        case 'd':
        case 'D':
            BREAK();
            /* The debugger might have changed the colors. Restore them. */
            (void)bordercolor(COLOR_BLUE);
            (void)bgcolor(BGC);
            (void)textcolor(TEXT_COLOR);
            /* The debugger changed the screen; restore it. */
            clrscr();
            draw_ui();
            break;
        case 'r':
        case 'R':
            {
                char drive_buf[4];
                char* colon;
                get_input("RIGHT DRIVE (8-11): ", drive_buf, 3);
                /* Remove trailing colon if present */
                colon = strchr(drive_buf, ':');
                if (colon) *colon = '\0';

                if (strcmp(drive_buf, "8") == 0 || strcmp(drive_buf, "9") == 0 ||
                    strcmp(drive_buf, "10") == 0 || strcmp(drive_buf, "11") == 0) {
#ifdef __CBM__
                    /* On CBM, chdir("8") sets the current device to 8. */
                    if (chdir(drive_buf) == 0) {
                         sprintf(right_path, "%s:", drive_buf);
                         read_directory(right_path, right_files, &right_count);
                    }
#else
                    sprintf(right_path, "%s:", drive_buf);
                    read_directory(right_path, right_files, &right_count);
#endif
                    right_sel = 0;
                    right_top = 0;
                    if (right_count == 0) {
                        gotoxy(0, PROMPT_Y);
                        cclear(40);
                        textcolor(COLOR_RED);
                        cprintf("NO FILES ON DRIVE %s", drive_buf);
                        cgetc();
                    }
                }
            }
            break;
        case 'l':
        case 'L':
            {
                char drive_buf[4];
                char* colon;
                get_input("LEFT DRIVE (8-11): ", drive_buf, 3);
                /* Remove trailing colon if present */
                colon = strchr(drive_buf, ':');
                if (colon) *colon = '\0';

                if (strcmp(drive_buf, "8") == 0 || strcmp(drive_buf, "9") == 0 ||
                    strcmp(drive_buf, "10") == 0 || strcmp(drive_buf, "11") == 0) {
#ifdef __CBM__
                    /* On CBM, chdir("8") sets the current device to 8. */
                    if (chdir(drive_buf) == 0) {
                        sprintf(left_path, "%s:", drive_buf);
                        read_directory(left_path, left_files, &left_count);
                    }
#else
                    sprintf(left_path, "%s:", drive_buf);
                    read_directory(left_path, left_files, &left_count);
#endif
                    left_sel = 0;
                    left_top = 0;
                    if (left_count == 0) {
                        gotoxy(0, PROMPT_Y);
                        cclear(40);
                        textcolor(COLOR_RED);
                        cprintf("NO FILES ON DRIVE %s", drive_buf);
                        cgetc();
                    }
                }
            }
            break;
        default:
            if (key >= CH_F1 && key <= CH_F8) {
                execute_command(key);
            }
            break;
    }
}
