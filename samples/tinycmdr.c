/*
** TinyCmdr - A simple TUI file commander for cc65.
** Inspired by Norton Commander and Midnight Commander.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <conio.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <ctype.h>

#if defined(__APPLE2__) || defined(__ATARI__)
#define HAVE_SUBDIRS 1
#endif

/* Defines */
#define MAX_FILES 50
#define COL_WIDTH 19
#define COL_HEIGHT 21
#define LEFT_COL_X 0
#define RIGHT_COL_X 20
#define TOP_Y 1
#define PROMPT_Y 22
#define SHORTCUT_Y 23

/* Colors - based on tinycmdr.md */
/* background blue, unselected white, selected yellow, subdirs green */
#define BGC COLOR_BLUE
#define TEXT_COLOR COLOR_WHITE
#define SEL_COLOR COLOR_YELLOW
#define DIR_COLOR COLOR_GREEN

/* File entry structure */
typedef struct {
    char name[FILENAME_MAX];
    unsigned char is_dir;
    unsigned char type;
} file_entry;

/* Global state */
static file_entry left_files[MAX_FILES];
static int left_count = 0;
static int left_sel = 0;
static int left_top = 0;
static char left_path[256];

static file_entry right_files[MAX_FILES];
static int right_count = 0;
static int right_sel = 0;
static int right_top = 0;
static char right_path[256];

static int active_col = 0; /* 0 for left, 1 for right */
static char cmd_buf[128];

/* Prototypes */
void read_directory(const char* path, file_entry* files, int* count);
void draw_frame(int x, int y, int w, int h);
void draw_ui(void);
void update_list(int col);
void handle_input(void);
void execute_command(int key);
void copy_file(const char* src, const char* dst);
void get_input(const char* prompt, char* buffer, unsigned char maxlen);

/* Implementation */

void get_input(const char* prompt, char* buffer, unsigned char maxlen) {
    unsigned char pos = 0;
    int key;

    buffer[0] = '\0';
    cursor(1);

    while (1) {
        gotoxy(0, PROMPT_Y);
        cclear(40);
        textcolor(COLOR_RED);
        cprintf("%s%s", prompt, buffer);

        key = cgetc();
        if (key == 13) { /* ENTER */
            break;
        } else if (key == CH_DEL || key == CH_CURS_LEFT) {
            if (pos > 0) {
                pos--;
                buffer[pos] = '\0';
            }
        } else if (key >= 32 && key < 127 && pos < maxlen - 1) {
            buffer[pos++] = (char)key;
            buffer[pos] = '\0';
        }
    }
    cursor(0);
}

void read_directory(const char* path, file_entry* files, int* count) {
    static DIR* dir;
    static struct dirent* ent;
#ifdef HAVE_SUBDIRS
    static DIR* subdir;
#endif
    *count = 0;

    dir = opendir(path);
    if (!dir) return;

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

void draw_ui(void) {
    textcolor(TEXT_COLOR);
    draw_frame(LEFT_COL_X, TOP_Y, COL_WIDTH + 1, COL_HEIGHT);
    draw_frame(RIGHT_COL_X, TOP_Y, COL_WIDTH + 1, COL_HEIGHT);

    update_list(0);
    update_list(1);

    /* Command prompt row above shortcut row */
    gotoxy(0, PROMPT_Y);
    cclear(40);
    textcolor(COLOR_RED);
    cprintf("CMD> %s", cmd_buf);

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

    textcolor(COLOR_CYAN);
    cprintf("7:EX 8:Q");
}

void copy_file(const char* src, const char* dst) {
    static int sfd, dfd;
    static int n;
    static char buf[128];
    sfd = open(src, O_RDONLY);
    if (sfd < 0) return;
    dfd = open(dst, O_WRONLY | O_CREAT | O_TRUNC, 0666);
    if (dfd < 0) {
        close(sfd);
        return;
    }
    while ((n = read(sfd, buf, sizeof(buf))) > 0) {
        write(dfd, buf, n);
    }
    close(sfd);
    close(dfd);
}

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
                    copy_file(filename, newname);
                    read_directory(left_path, left_files, &left_count);
                    read_directory(right_path, right_files, &right_count);
                    /* Reset scroll position if count changed significantly */
                    if (left_sel >= left_count) { left_sel = left_count > 0 ? left_count - 1 : 0; }
                    if (left_top + visible_height > left_count) { left_top = left_count > visible_height ? left_count - visible_height : 0; }
                    if (right_sel >= right_count) { right_sel = right_count > 0 ? right_count - 1 : 0; }
                    if (right_top + visible_height > right_count) { right_top = right_count > visible_height ? right_count - visible_height : 0; }
                }
                cmd_buf[0] = '\0';
            }
            break;
        case CH_F2: /* DL */
            if (filename[0]) {
                unlink(filename);
                read_directory(left_path, left_files, &left_count);
                read_directory(right_path, right_files, &right_count);
                if (*sel >= *count && *count > 0) *sel = *count - 1;
                if (*top + visible_height > *count) { *top = *count > visible_height ? *count - visible_height : 0; }
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
                cmd_buf[0] = '\0';
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
            cmd_buf[0] = '\0';
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
                clrscr();
                exec(filename, "");
                /* If exec returns, it failed */
                cprintf("Exec failed: %s\n", strerror(errno));
                cgetc();
                clrscr();
            }
            break;
        case CH_F8: /* Q */
            clrscr();
            exit(0);
            break;
    }
}

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
        default:
            if (key >= CH_F1 && key <= CH_F8) {
                execute_command(key);
            }
            break;
    }
}

int main(void) {
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

    cmd_buf[0] = '\0';

    while (1) {
        draw_ui();
        handle_input();
    }
}
