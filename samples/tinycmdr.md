# TinyCmdr

# Purpose
TinyCmdr ia a simple (Tiny) Text User Interface (TUI) file commander like DOS Norton Commander oder Linux Midnight Commander.

# Text User Interface
- 2 columns layout that contains only the filenames and subdirectory names.
  - the types of the files should also displayed correct, wether they are executable, archive, or other
  - each column have a border arouns them
- 2 rows the bottom have a special meaning:
  - the bottom row have the short cut informations for the F1-F8 functions keys
  - the row above the buttom row is a commandline prompt to enter commands like in the sample program tinyshell.c
- Changing from the left to the right column and vice versa is done by pressing the left and right cursor keys
- Navigating in each column up und down of the listed files are with the up and down cursor keys
- a selected file is highlighted with a different color
- actions to a selected file are made by using/pressing the functions keys. The commands they do are described above
- colors:
  - the selected file is highlighted with a different color
  - the commandline prompt is highlighted with a different color
  - subdirectory names are highlighted with a different color
  - the short cut informations are highlighted with a different color
    - background color are blue
    - filenames unselected white
    - filename selected yellow
    - subdirs color are green
- command:
  - copy -> short CP associated to F1
  - delete -> short DL associated to F2
  - rename -> short RN associated to F3
  - chdir -> short CD associated to F4
  - makedir -> short MD associated to F5
  - removedir -> short RD associated to F6
  - execute -> short EX associated to F7
  - quit -> short Q associated to F8
# Functions
- if the system/operatingsystem does not support directories on disk the the commands F4-F6 must be disables and the color should be COLOR_GREY
- if F1 is pressed a prompt in PROMPT_Y should appera and ask for a new name. After entering the name and press RETURN the selected file must be copied to the new file with the new name
- if F2 is pressed the selected file must be deleted
- if F3 is pressed a prompt in PROMPT_Y should appera and ask for a new name. After entering the name and press RETURN the selected file must be renamed to the new name
- if F7 is pressed the selected file must be executed
- if F8 is pressed the application must be quit
# Dev Environment
- that is the cc65 environment
- the sample file directory are a good source to learn how to use the tinycmdr applications is to create
    - mousedemo is a good example for the column layout and the border and how to show content inside a column
    - tinyshell is the sample program to learn how to use the tinycmdr application with command describes above

# Development Tips and Error Prevention

To avoid compilation errors and warnings in the cc65 environment (especially for the C64), the following measures were taken:

- **Limiting Local Variables**: The cc65 compiler has a strict limit on the number of local variables per function. Bei komplexen Funktionen sollten lokale Variablen als `static` deklariert werden, um den "Too many local variables"-Fehler zu vermeiden.
- **Memory Optimization (BSS Segment)**: Since memory is limited on 8-bit systems like the C64, large arrays (e.g., for file lists) must be restricted in size. `MAX_FILES` wurde von 100 auf 50 reduziert, um einen Überlauf des BSS-Segments zu verhindern.
- **Platform compatibility**: Functions such as `chdir`, `rmdir`, and `getcwd` are not available on all cc65 targets (e.g., C64) in the standard library. Diese müssen mit Präprozessor-Abfragen wie `#ifdef HAVE_SUBDIRS` abgesichert werden, um Linker-Fehler ("Unresolved external") zu vermeiden.
- **Avoid unreachable code**: Since `main` often contains an infinite loop (`while(1)`), there should be no `return` statement afterward, as this triggers a warning about unreachable code.
- **Using `static` for Buffers**: Larger buffers within functions should also be `static` to relieve the stack.

- **Compilation**: To compile the program for the C64, use the command `make tinycmdr` (or `make SYS=c64 tinycmdr`) in the `samples` directory.
- **Creation of the disk image**: A .d64 disk image (e.g. for emulators) can be created with the command `make disk SYS=c64` in the `samples` directory. Dies setzt voraus, dass das Tool `c1541` (Teil von VICE) installiert ist. Das resultierende Image `samples.d64` enthält dann alle für den C64 kompilierten Beispiele, einschließlich `tinycmdr`.



