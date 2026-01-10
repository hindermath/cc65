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
} file_entry;

/* Global state */
static file_entry left_files[MAX_FILES];
static int left_count = 0;
static int left_sel = 0;
static char left_path[256];

static file_entry right_files[MAX_FILES];
static int right_count = 0;
static int right_sel = 0;
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

/* Implementation */

void read_directory(const char* path, file_entry* files, int* count) {
    static DIR* dir;
    static struct dirent* ent;
    static DIR* subdir;
    *count = 0;

    dir = opendir(path);
    if (!dir) return;

    while ((*count < MAX_FILES) && (ent = readdir(dir))) {
        strncpy(files[*count].name, ent->d_name, FILENAME_MAX - 1);
        files[*count].name[FILENAME_MAX - 1] = '\0';

        /* Simple check for directory */
        /* In many cc65 targets, we can't easily check d_type. */
        /* For this 'tiny' app, we'll mark '.' and '..' as dirs. */
        if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0) {
            files[*count].is_dir = 1;
        } else {
            /* Try to opendir it to see if it's a directory */
            subdir = opendir(ent->d_name);
            if (subdir) {
                files[*count].is_dir = 1;
                closedir(subdir);
            } else {
                files[*count].is_dir = 0;
            }
        }
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
    file_entry* files = (col == 0) ? left_files : right_files;

    for (i = 0; i < COL_HEIGHT - 2; ++i) {
        gotoxy(x, TOP_Y + 1 + i);
        if (i < count) {
            if (i == sel && col == active_col) {
                revers(1);
                textcolor(SEL_COLOR);
            } else {
                revers(0);
                if (files[i].is_dir) textcolor(DIR_COLOR);
                else textcolor(TEXT_COLOR);
            }
            cprintf("%-17.17s", files[i].name);
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
    cprintf("1:CP 2:DL 3:RN 4:CD 5:MD 6:RD 7:EX 8:Q");
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
    static char* path;
    static char filename[FILENAME_MAX];
    static char dst[256];

    files = (active_col == 0) ? left_files : right_files;
    count = (active_col == 0) ? &left_count : &right_count;
    sel = (active_col == 0) ? &left_sel : &right_sel;
    path = (active_col == 0) ? left_path : right_path;

    if (*sel < *count) {
        strcpy(filename, files[*sel].name);
    } else {
        filename[0] = '\0';
    }

    switch (key) {
        case CH_F1: /* CP */
            if (filename[0]) {
                strcpy(dst, (active_col == 0) ? right_path : left_path);
                strcat(dst, "/");
                strcat(dst, filename);
                copy_file(filename, dst);
                read_directory(left_path, left_files, &left_count);
                read_directory(right_path, right_files, &right_count);
            }
            break;
        case CH_F2: /* DL */
            if (filename[0]) {
                unlink(filename);
                read_directory(".", files, count);
                if (*sel >= *count && *count > 0) *sel = *count - 1;
            }
            break;
        case CH_F3: /* RN */
            /* Placeholder for rename */
            break;
        case CH_F4: /* CD */
        case 13:    /* Enter */
            if (filename[0]) {
#ifdef HAVE_SUBDIRS
                if (chdir(filename) == 0) {
                    getcwd(path, 255);
                    read_directory(".", files, count);
                    *sel = 0;
                }
#endif
            }
            break;
        case CH_F5: /* MD */
            /* Placeholder for makedir */
            break;
        case CH_F6: /* RD */
            if (filename[0]) {
#ifdef HAVE_SUBDIRS
                rmdir(filename);
                read_directory(".", files, count);
#endif
            }
            break;
        case CH_F7: /* EX */
            /* Placeholder for execute */
            break;
        case CH_F8: /* Q */
            clrscr();
            exit(0);
            break;
    }
}

void handle_input(void) {
    static int key;
    key = cgetc();
    switch (key) {
        case CH_CURS_UP:
            if (active_col == 0) {
                if (left_sel > 0) left_sel--;
            } else {
                if (right_sel > 0) right_sel--;
            }
            break;
        case CH_CURS_DOWN:
            if (active_col == 0) {
                if (left_sel < left_count - 1) left_sel++;
            } else {
                if (right_sel < right_count - 1) right_sel++;
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
