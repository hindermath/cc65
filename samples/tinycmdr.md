# TinyCmdr

# Purpose
TinyCmdr ia a simple (Tiny) Text User Interface (TUI) file commander like DOS Norton Commander oder Linux Midnight Commander.

# Text User Interface
- 2 columns layout that contains only the filenames and subdirectory names.
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
  - rename -> short REN associated to F2
  - chdir -> short CD associated to F3
  - delete -> short DEL associated to F4
  - makedir -> short MD associated to F5
  - removedir -> short RD associated to F6
  - execute -> short EXE associated to F7
  - quit -> short Q associated to F8
# Functions
- for the commands describes above the tinyshell is the sample program to learn how to use the the command and is a good source as an example how to code this functions

# Dev Environment
- that is the cc65 environment
- the sample file directory are a good source to learn how to use the tinycmdr applications is to create
  - mousedemo is a good example for the column layout and the border and how to show content inside a column
  - tinyshell is the sample program to learn how to use the tinycmdr application with command describes above


