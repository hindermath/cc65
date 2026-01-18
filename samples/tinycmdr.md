# TinyCmdr

## Purpose
TinyCmdr ia a simple (Tiny) Text User Interface (TUI) file commander like DOS Norton Commander oder Linux Midnight Commander.

## Text User Interface
- 2 columns layout that contains only the filenames, subdirectory names and the block size (on CBM targets).
  - the types of the files should also displayed correct, whether they are executable, archive, or other
  - if the file selection goes beyond the bottom of the column, the content should scroll up and vice versa.
  - each column have a border around them
  - at the bottom of each column, the used and free blocks on the disk are displayed in yellow (e.g., `Used:123  Free:541 `).
- 2 rows the bottom have a special meaning:
  - the bottom row have the short cut informations for the F1-F8 functions keys
  - the row above the bottom row is used for prompts (like for F1 and F3) and can also be used for messages.
- Changing from the left to the right column and vice versa is done by pressing the left and right cursor keys
- Navigating in each column up und down of the listed files are with the up and down cursor keys
- a selected file is highlighted with a different color
- actions to a selected file are made by using/pressing the functions keys. The commands they do are described above
- pressing the key 'l' (left) or 'r' (right) allows changing the drive for the respective column.
  - The application asks for the drive number (8, 9, 10, or 11).
  - Both plain numbers (e.g., `8`) and numbers with a colon (e.g., `8:`) are accepted.
- pressing the key 'd' starts the built-in debugger.
- colors:
  - the selected file is highlighted with a different color
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

## Functions
- if the system/operatingsystem does not support directories on disk the the commands F4-F6 must be disables and the color should be COLOR_GREY.
- if the selected file is not an executable file then the command F7 must be disabled and the color should be COLOR_GREY.
- if the key 'd' was pressed then go into the debugger. For an example see the sample program mousedemo.c.
- if F1 is pressed a prompt in PROMPT_Y should appera and ask for the destination drive (8-11) and then for a new name. If the file already exists at the destination, it asks for confirmation. Press F1 again to overwrite. After the copy the content must be refreshed. *Important* If the file is copied the type of the destination file must be the same as the source file.
- if F2 is pressed the selected file must be deleted. Ask the user wit a prompt with an appropriated message. Press F2 again to delete the selected file absolutely.
- if F3 is pressed a prompt in PROMPT_Y should appera and ask for a new name. After entering the name and press RETURN the selected file must be renamed to the new name.
- if F7 is pressed the selected file must be executed.
- if F8 is pressed the application must be quit.
- if the key 'r' is pressed, the application asks in the prompt area for the drive number. Allowed values are 8,9,10,and 11. Check only of this numbers. After entering the drive number, the right column should list the files list of the entered drive.
- if the key 'l' is pressed, the application asks in the prompt area for the drive number. Allowed values are 8,9,10,and 11. Check only of this numbers. After entering the drive number, the left column should list the files list of the entered drive.
- the Copy (CP) function must be enhanced to ask the destination drive and asks for the drive number. Allowed values are 8,9,10,11. If the file that should be copied present in the destination the Copy Function (CP) must ask for overwriting the file. Pressing F1 (CP) again the file overwrites the existing file in the destination drive.

## Dev Environment
- that is the cc65 environment
- the sample file directory are a good source to learn how to use the tinycmdr applications is to create
    - mousedemo is a good example for the column layout and the border and how to show content inside a column
    - tinyshell is the sample program to learn how to use the tinycmdr application with command describes above

## Development Tips and Error Prevention
To avoid compilation errors and warnings in the cc65 environment (especially for the C64), the following measures were taken:
- **Limiting Local Variables**: The cc65 compiler has a strict limit on the number of local variables per function. Bei komplexen Funktionen sollten lokale Variablen als `static` deklariert werden, um den "Too many local variables"-Fehler zu vermeiden.
- **Memory Optimization (BSS Segment)**: Since memory is limited on 8-bit systems like the C64, large arrays (e.g., for file lists) must be restricted in size. `MAX_FILES` wurde auf 144 erhöht, um alle möglichen Dateien eines .d64 Disk-Images (max. 144) anzeigen zu können. Dies belegt ca. 10 KB im BSS-Segment, was für den C64 tragbar ist.
- **Platform compatibility**: Functions such as `chdir`, `rmdir`, and `getcwd` are not available on all cc65 targets (e.g., C64) in the standard library. Diese müssen mit Präprozessor-Abfragen wie `#ifdef HAVE_SUBDIRS` abgesichert werden, um Linker-Fehler ("Unresolved external") zu vermeiden.
- **CBM Drive Access**: On CBM systems, `opendir()` only supports ".", "0:", or "1:". To change the active device, `chdir()` must be called with the device number (e.g., `chdir("8")`). TinyCmdr handles this by first switching the device and then using `opendir(".")` to read the directory.
- **Disk Capacity and Block Calculation**: On CBM targets, the total number of used blocks is calculated by summing up the blocks of all directory entries. The number of free blocks is determined by subtracting the used blocks from the standard capacity of a 1541 floppy disk (664 usable blocks). These values are automatically refreshed after every file operation (copy, delete, rename).
- **File Copying on CBM**:
    - **Drive Switching**: Since `open()` doesn't support drive prefixes on all CBM targets, the program performs a `chdir()` to the source drive, opens the file, and then a `chdir()` to the destination drive to create the copy. It restores the original device afterwards using `getcurrentdevice()`.
    - **File Types**: When creating files on CBM, the global `_filetype` variable (from `cc65.h`) is used to set the correct type (e.g., 'p' for PRG). Adding suffixes like `,p` manually to the destination filename can lead to errors because the library adds them automatically based on `_filetype` during `O_CREAT`. For reading, explicit suffixes (like `filename,p`) are used to ensure the correct file is accessed.
    - **Path Formatting**: CBM DOS does not support Unix-style paths like `./filename`. TinyCmdr ensures that filenames are passed as plain strings after the device has been changed via `chdir()`.
- **Avoid unreachable code**: Since `main` often contains an infinite loop (`while(1)`), there should be no `return` statement afterward, as this triggers a warning about unreachable code.
- **Using `static` for Buffers**: Larger buffers within functions should also be `static` to relieve the stack.

- **Compilation**: To compile the program for the C64, use the command `make tinycmdr` (or `make SYS=c64 tinycmdr`) in the `samples` directory.
- **Creation of the disk image**: A .d64 disk image (e.g. for emulators) can be created with the command `make disk SYS=c64` in the `samples` directory. Dies setzt voraus, dass das Tool `c1541` (Teil von VICE) installiert ist. Das resultierende Image `samples.d64` enthält dann alle für den C64 kompilierten Beispiele, einschließlich `tinycmdr`. Dieser Schritt sollte nach jeder erfolgreichen Übersetzung durchgeführt werden. After successful creation, the emulator VICE can be started with the command `/opt/homebrew/bin/x64sc -8 samples.d64`.
