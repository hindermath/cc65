/*
** tcmdrlib.c - Implementation block for TinyCmdr.
**
** (C) Thorsten Hindermann, 2026
*/

/* TinyCmdr uses the Apple //e cursor and OpenApple+number key mappings even
** when it is built for the compatible Apple ][ target. */
#if defined(__APPLE2__) && !defined(__APPLE2ENH__)
#define APPLE2_INCLUDE_IIE_CHARS
#endif

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
#ifdef __CBM__
#include <device.h>
#endif
#include "tinycmdr.h" /* Global declarations and state */

/* Global state definitions (initialized in tinycmdr.c or through logic) */
file_entry left_files[MAX_FILES];   /* Data for the left list panel */
int left_count = 0;                 /* Entries in left list */
int left_sel = 0;                   /* Highlighted entry in left list */
int left_top = 0;                   /* Scrolling offset for left list */
char left_path[256];                /* Current path/device for left list */
unsigned int left_used = 0;         /* Total blocks used on left drive */
unsigned int left_free = 0;         /* Total blocks free on left drive */

file_entry right_files[MAX_FILES];  /* Data for the right list panel */
int right_count = 0;                /* Entries in right list */
int right_sel = 0;                  /* Highlighted entry in right list */
int right_top = 0;                  /* Scrolling offset for right list */
char right_path[256];               /* Current path/device for right list */
unsigned int right_used = 0;        /* Total blocks used on right drive */
unsigned int right_free = 0;        /* Total blocks free on right drive */

int active_col = 0;                 /* 0 = Left panel active, 1 = Right panel active */

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
        /* Render prompt and current buffer content */
        gotoxy(0, PROMPT_Y);
        cclear(40);
        textcolor(COLOR_WHITE);
        cprintf("%s", prompt);
        textcolor(COLOR_YELLOW);
        cprintf("%s", buffer);

        key = cgetc();
        if (key == 13) { /* ENTER key: Finish input */
            break;
        } else if (key == CH_DEL || key == CH_CURS_LEFT || key == 20) {
            /* Handle backspace/delete (20 is PETSCII Backspace on C64) */
            if (pos > 0) {
                pos--;
                buffer[pos] = '\0';
            }
        } else if (key >= 32 && key < 127 && pos < maxlen - 1) {
            /* Accept printable ASCII characters within buffer limits */
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
    unsigned int* used = (files == left_files) ? &left_used : &right_used;
    unsigned int* free = (files == left_files) ? &left_free : &right_free;

    *count = 0;
    *used = 0;
    *free = 0;

#ifdef __CBM__
    /* Check if the path is a drive specification like "8:" (C64/C128 specific).
       cc65 opendir/readdir implementation for CBM targets typically handles
       drive numbers and device access. */
    if (path[0] >= '8' && path[0] <= '9' && path[1] == ':' && path[2] == '\0') {
        dir = opendir("."); /* Fallback to current device if needed */
        if (!dir) {
            /* Try opendir with the path as a fallback, although opendir in cc65-cbm
               usually only supports "0:", "1:", or "." */
            dir = opendir(path);
        }
    } else if (path[0] == '1' && (path[1] == '0' || path[1] == '1') && path[2] == ':' && path[3] == '\0') {
        /* Support for dual-digit drive numbers (10, 11) */
        dir = opendir(".");
        if (!dir) {
            dir = opendir(path);
        }
    } else {
        /* Default to path if not a clear drive spec */
        dir = opendir(path);
    }
#else
    /* Non-CBM targets (Apple II, Atari) use standard filesystem paths */
    dir = opendir(path);
#endif
    if (!dir) return;

    /* Clear existing file list to avoid confusion */
    memset(files, 0, MAX_FILES * sizeof(file_entry));

    while ((*count < MAX_FILES) && (ent = readdir(dir))) {
        strncpy(files[*count].name, ent->d_name, FILENAME_MAX - 1);
        files[*count].name[FILENAME_MAX - 1] = '\0';

#ifdef __CBM__
        /* Map CBM specific directory/file type info and block size */
        files[*count].type = ent->d_type;
        files[*count].blocks = ent->d_blocks;

        if (ent->d_type == _CBM_T_DIR) {
            files[*count].is_dir = 1;
            *used += ent->d_blocks;
        } else if (ent->d_type == _CBM_T_HEADER) {
            /* We don't want to show the header in our file list usually. */
            continue;
        } else {
            files[*count].is_dir = 0;
            *used += ent->d_blocks;
        }
#else
        /* Generic filesystem logic (e.g. Apple II, Atari) */
        files[*count].blocks = 0; /* Not easily available via dirent on all targets */
        files[*count].type = 0;
        if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0) {
            files[*count].is_dir = 1;
        } else {
#ifdef HAVE_SUBDIRS
            /* Try to opendir it to see if it's actually a directory */
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

#ifdef __CBM__
    /* Calculate free blocks: total capacity - used blocks.
       A standard 1541 disk (C64) has 683 blocks total, 664 usable.
       Using 664 as a safe default for 'free' display. */
    *free = (664 > *used) ? (664 - *used) : 0;
#endif
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
            /* If this is the selected item in the active column, highlight it */
            if (idx == sel && col == active_col) {
                revers(1);
                textcolor(SEL_COLOR);
            } else {
                revers(0);
                /* Directories are shown in a different color */
                if (files[idx].is_dir) textcolor(DIR_COLOR);
                else textcolor(TEXT_COLOR);
            }

            /* Display name, blocks and type on CBM targets (fixed width) */
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
            cprintf("%-10.10s %3u %s", files[idx].name, files[idx].blocks, type_str);
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

    /* Display summary (Used/Free blocks) at the bottom line of the frame */
    gotoxy(x, TOP_Y + COL_HEIGHT - 1);
    textcolor(COLOR_YELLOW);
    {
        unsigned int used = (col == 0) ? left_used : right_used;
        unsigned int free = (col == 0) ? left_free : right_free;
        cprintf("Used:%-4u Free:%-4u", used, free);
    }

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
    static char src_drive[4];
    static char src_name[FILENAME_MAX];
    static char dst_drive[4];
    static char dst_name[FILENAME_MAX];
    static char src_full_cbm[FILENAME_MAX + 10];
    static char dst_full_cbm[FILENAME_MAX + 10];
    static int sfd, dfd;
    static int n;
    static char buf[512];
    static size_t buf_sz = sizeof(buf);
    static unsigned char base_type;
    static char old_drive[4];

#ifdef __CBM__
    /* --- CBM specific parsing logic ---
       We need to separate the drive number from the filename to use the
       appropriate cc65 library calls (chdir, open). */
    /* Parse source drive and name */
    if (src[1] == ':' && src[0] >= '8' && src[0] <= '9') {
        src_drive[0] = src[0];
        src_drive[1] = '\0';
        strcpy(src_name, src + 2);
    } else if (src[2] == ':' && src[0] == '1' && (src[1] == '0' || src[1] == '1')) {
        src_drive[0] = src[0];
        src_drive[1] = src[1];
        src_drive[2] = '\0';
        strcpy(src_name, src + 3);
    } else if (src[0] == '.' && src[1] == '/') {
        src_drive[0] = '\0';
        strcpy(src_name, src + 2);
    } else {
        src_drive[0] = '\0';
        strcpy(src_name, src);
    }

    /* Double check if name still contains drive prefix after parsing */
    if (src_name[1] == ':' && src_name[0] >= '8' && src_name[0] <= '9') {
        if (!src_drive[0]) {
            src_drive[0] = src_name[0];
            src_drive[1] = '\0';
        }
        memmove(src_name, src_name + 2, strlen(src_name + 2) + 1);
    } else if (src_name[2] == ':' && src_name[0] == '1' && (src_name[1] == '0' || src_name[1] == '1')) {
        if (!src_drive[0]) {
            src_drive[0] = src_name[0];
            src_drive[1] = src_name[1];
            src_drive[2] = '\0';
        }
        memmove(src_name, src_name + 3, strlen(src_name + 3) + 1);
    }

    /* Parse destination drive and name */
    if (dst[1] == ':' && dst[0] >= '8' && dst[0] <= '9') {
        dst_drive[0] = dst[0];
        dst_drive[1] = '\0';
        strcpy(dst_name, dst + 2);
    } else if (dst[2] == ':' && dst[0] == '1' && (dst[1] == '0' || dst[1] == '1')) {
        dst_drive[0] = dst[0];
        dst_drive[1] = dst[1];
        dst_drive[2] = '\0';
        strcpy(dst_name, dst + 3);
    } else if (dst[0] == '.' && dst[1] == '/') {
        dst_drive[0] = '\0';
        strcpy(dst_name, dst + 2);
    } else {
        dst_drive[0] = '\0';
        strcpy(dst_name, dst);
    }

    /* Double check if name still contains drive prefix after parsing */
    if (dst_name[1] == ':' && dst_name[0] >= '8' && dst_name[0] <= '9') {
        if (!dst_drive[0]) {
            dst_drive[0] = dst_name[0];
            dst_drive[1] = '\0';
        }
        memmove(dst_name, dst_name + 2, strlen(dst_name + 2) + 1);
    } else if (dst_name[2] == ':' && dst_name[0] == '1' && (dst_name[1] == '0' || dst_name[1] == '1')) {
        if (!dst_drive[0]) {
            dst_drive[0] = dst_name[0];
            dst_drive[1] = dst_name[1];
            dst_drive[2] = '\0';
        }
        memmove(dst_name, dst_name + 3, strlen(dst_name + 3) + 1);
    }

    /* Prepare names (without manual suffixes, cc65 open() handles them) */
    strcpy(src_full_cbm, src_name);
    strcpy(dst_full_cbm, dst_name);

    /* Set the file type for creation on CBM devices.
       This uses the global _filetype variable from the cc65 runtime. */
    base_type = type & 0x0F;
    if (base_type == (_CBM_T_PRG & 0x0F)) {
        _filetype = 'p';
        strcat(src_full_cbm, ",p"); /* Force type for reading */
    } else if (base_type == (_CBM_T_SEQ & 0x0F)) {
        _filetype = 's';
        strcat(src_full_cbm, ",s");
    } else if (base_type == (_CBM_T_USR & 0x0F)) {
        _filetype = 'u';
        strcat(src_full_cbm, ",u");
    } else {
        _filetype = 's'; /* Default to SEQ if unknown */
    }

    /* Save current device to restore later */
    sprintf(old_drive, "%d", getcurrentdevice());

    /* Switch to source drive and open */
    if (src_drive[0]) chdir(src_drive);
    sfd = open(src_full_cbm, O_RDONLY);
    if (sfd < 0) {
        gotoxy(0, PROMPT_Y);
        cclear(40);
        textcolor(COLOR_RED);
        cprintf("SRC ERR %d: %s", errno, src_full_cbm);
        chdir(old_drive);
        cgetc();
        return;
    }

    /* Switch to destination drive and open */
    if (dst_drive[0]) chdir(dst_drive);
    /* Delete existing if needed */
    unlink(dst_full_cbm);
    dfd = open(dst_full_cbm, O_WRONLY | O_CREAT | O_TRUNC, 0666);
    if (dfd < 0) {
        gotoxy(0, PROMPT_Y);
        cclear(40);
        textcolor(COLOR_RED);
        cprintf("DST ERR %d: %s", errno, dst_full_cbm);
        close(sfd);
        chdir(old_drive);
        cgetc();
        return;
    }
#else
    (void)type;
    sfd = open(src, O_RDONLY);
    if (sfd < 0) {
        gotoxy(0, PROMPT_Y);
        cclear(40);
        textcolor(COLOR_RED);
        cprintf("SRC ERR %d: %s", errno, src);
        cgetc();
        return;
    }
    dfd = open(dst, O_WRONLY | O_CREAT | O_TRUNC, 0666);
    if (dfd < 0) {
        gotoxy(0, PROMPT_Y);
        cclear(40);
        textcolor(COLOR_RED);
        cprintf("DST ERR %d: %s", errno, dst);
        close(sfd);
        cgetc();
        return;
    }
#endif

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

#ifdef __CBM__
    /* Restore original drive */
    chdir(old_drive);
#endif
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
    static char drive_buf[4];
    static char src_full_name[FILENAME_MAX + 8];
    static char dest_full_name[FILENAME_MAX + 8];

    /* Determine source/destination pointers based on the active panel */
    files = (active_col == 0) ? left_files : right_files;
    count = (active_col == 0) ? &left_count : &right_count;
    sel = (active_col == 0) ? &left_sel : &right_sel;
    top = (active_col == 0) ? &left_top : &right_top;
    path = (active_col == 0) ? left_path : right_path;

    if (*sel < *count) {
        strcpy(filename, files[*sel].name);
        /* Construct the full source path including drive or directory prefix */
#ifdef __CBM__
        /* CBM uses ':' for drive, and usually no subdirectories.
           If path is ".", we just use the filename.
        */
        if (strcmp(path, ".") == 0) {
            strcpy(src_full_name, filename);
        } else if (path[0] != '\0' && path[strlen(path)-1] != ':' && path[strlen(path)-1] != '/') {
            sprintf(src_full_name, "%s/%s", path, filename);
        } else {
            sprintf(src_full_name, "%s%s", path, filename);
        }
#else
        if (path[0] != '\0' && path[strlen(path)-1] != ':' && path[strlen(path)-1] != '/') {
            sprintf(src_full_name, "%s/%s", path, filename);
        } else {
            sprintf(src_full_name, "%s%s", path, filename);
        }
#endif
    } else {
        filename[0] = '\0';
        src_full_name[0] = '\0';
    }

    switch (key) {
        case CH_F1: /* CP - Copy File */
            if (filename[0]) {
                get_input("DEST DRIVE (8-11): ", drive_buf, 3);
                /* Validating input: TinyCmdr currently supports CBM device numbers 8 to 11 */
                if (strcmp(drive_buf, "8") == 0 || strcmp(drive_buf, "9") == 0 ||
                    strcmp(drive_buf, "10") == 0 || strcmp(drive_buf, "11") == 0) {

                    get_input("COPY TO NAME: ", newname, FILENAME_MAX);
                    if (newname[0]) {
                        int exists = 0;
                        int fd;
                        sprintf(dest_full_name, "%s:%s", drive_buf, newname);

                        /* Check if file exists */
                        fd = open(dest_full_name, O_RDONLY);
                        if (fd >= 0) {
                            exists = 1;
                            close(fd);
                        }

                        if (exists) {
                            int confirm_key;
                            gotoxy(0, PROMPT_Y);
                            cclear(40);
                            textcolor(COLOR_RED);
                            cprintf("OVERWRITE %s? (F1 TO CONFIRM)", newname);
                            confirm_key = cgetc();
                            if (confirm_key != CH_F1) {
                                break;
                            }
                        }

                        copy_file(src_full_name, dest_full_name, files[*sel].type);
                        /* Refresh both lists after operation */
                        read_directory(left_path, left_files, &left_count);
                        read_directory(right_path, right_files, &right_count);
                        /* Reset scroll position if count changed significantly to keep selection visible */
                        if (left_sel >= left_count) { left_sel = left_count > 0 ? left_count - 1 : 0; }
                        if (left_top + visible_height > left_count) { left_top = left_count > visible_height ? left_count - visible_height : 0; }
                        if (right_sel >= right_count) { right_sel = right_count > 0 ? right_count - 1 : 0; }
                        if (right_top + visible_height > right_count) { right_top = right_count > visible_height ? right_count - visible_height : 0; }
                    }
                } else {
                    /* Show error message for unsupported device numbers */
                    gotoxy(0, PROMPT_Y);
                    cclear(40);
                    textcolor(COLOR_RED);
                    cprintf("INVALID DRIVE %s", drive_buf);
                    cgetc();
                }
            }
            break;
        case CH_F2: /* DL - Delete File */
            if (filename[0]) {
                int confirm_key;
                gotoxy(0, PROMPT_Y);
                cclear(40);
                textcolor(COLOR_RED);
                cprintf("DELETE %s? (F2 TO CONFIRM)", filename);
                confirm_key = cgetc();
                if (confirm_key == CH_F2) {
                    unlink(filename);
                    /* Refresh directories after deletion */
                    read_directory(left_path, left_files, &left_count);
                    read_directory(right_path, right_files, &right_count);
                    if (*sel >= *count && *count > 0) *sel = *count - 1;
                    if (*top + visible_height > *count) { *top = *count > visible_height ? *count - visible_height : 0; }
                }
                gotoxy(0, PROMPT_Y);
                cclear(40);
            }
            break;
        case CH_F3: /* RN - Rename File */
            if (filename[0]) {
                get_input("RENAME TO: ", newname, FILENAME_MAX);
                if (newname[0]) {
                    rename(filename, newname);
                    read_directory(left_path, left_files, &left_count);
                    read_directory(right_path, right_files, &right_count);
                }
            }
            break;
        case CH_F4: /* CD - Change Directory */
        case 13:    /* Enter - Also triggers CD if selection is a directory */
#ifdef HAVE_SUBDIRS
            if (filename[0]) {
                if (chdir(filename) == 0) {
                    /* Update current path and reload files */
                    getcwd(path, 255);
                    read_directory(".", files, count);
                    *sel = 0;
                    if (active_col == 0) left_top = 0; else right_top = 0;
                }
            }
#endif
            break;
        case CH_F5: /* MD - Make Directory */
#ifdef HAVE_SUBDIRS
            get_input("MKDIR: ", newname, FILENAME_MAX);
            if (newname[0]) {
                mkdir(newname, 0777);
                read_directory(left_path, left_files, &left_count);
                read_directory(right_path, right_files, &right_count);
            }
#endif
            break;
        case CH_F6: /* RD - Remove Directory */
#ifdef HAVE_SUBDIRS
            if (filename[0]) {
                rmdir(filename);
                read_directory(left_path, left_files, &left_count);
                read_directory(right_path, right_files, &right_count);
            }
#endif
            break;
        case CH_F7: /* EX - Execute Program */
            if (filename[0]) {
                int is_exe = 0;
#ifdef __CBM__
                /* On CBM, only PRG files can be executed via exec() */
                if (files[*sel].type == _CBM_T_PRG) is_exe = 1;
#else
                /* On other platforms, we assume anything might be executable */
                is_exe = 1;
#endif
                if (is_exe) {
                    clrscr();
                    exec(filename, "");
                    /* If exec returns, it failed (e.g. file not found or wrong format) */
                    cprintf("Exec failed: %s\n", strerror(errno));
                    cgetc();
                    clrscr();
                }
            }
            break;
        case CH_F8: /* QT - Quit Application */
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
            /* Move selection up and scroll if necessary */
            if (*sel > 0) {
                (*sel)--;
                if (*sel < *top) {
                    *top = *sel;
                }
            }
            break;
        case CH_CURS_DOWN:
            /* Move selection down and scroll if necessary */
            if (*sel < count - 1) {
                (*sel)++;
                if (*sel >= *top + visible_height) {
                    *top = *sel - visible_height + 1;
                }
            }
            break;
        case CH_CURS_LEFT:
            /* Switch keyboard focus to the left panel */
            active_col = 0;
            break;
        case CH_CURS_RIGHT:
            /* Switch keyboard focus to the right panel */
            active_col = 1;
            break;
        case 13: /* ENTER */
            /* Execute the default action (CD for dirs, or handle as F-key command) */
            execute_command(13);
            break;
        case 'd':
        case 'D':
            /* Enter the debugger (if available) */
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
                /* Quick shortcut to change the drive for the RIGHT panel */
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
                /* Quick shortcut to change the drive for the LEFT panel */
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
