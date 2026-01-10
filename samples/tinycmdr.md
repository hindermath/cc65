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
  - delete -> short DL associated to F2
  - rename -> short RN associated to F3
  - chdir -> short CD associated to F4
  - makedir -> short MD associated to F5
  - removedir -> short RD associated to F6
  - execute -> short EX associated to F7
  - quit -> short Q associated to F8
# Functions
- for the commands describes above the tinyshell is the sample program to learn how to use the the command and is a good source as an example how to code this functions

# Dev Environment
- that is the cc65 environment
- the sample file directory are a good source to learn how to use the tinycmdr applications is to create
    - mousedemo is a good example for the column layout and the border and how to show content inside a column
    - tinyshell is the sample program to learn how to use the tinycmdr application with command describes above

# Entwicklungshinweise und Fehlervermeidung

Um Kompilierungsfehler und Warnungen in der cc65-Umgebung (insbesondere für den C64) zu vermeiden, wurden folgende Maßnahmen ergriffen:

- **Begrenzung lokaler Variablen**: Der cc65-Compiler hat ein striktes Limit für die Anzahl lokaler Variablen pro Funktion. Bei komplexen Funktionen sollten lokale Variablen als `static` deklariert werden, um den "Too many local variables"-Fehler zu vermeiden.
- **Speicheroptimierung (BSS-Segment)**: Da der Speicher auf 8-Bit-Systemen wie dem C64 begrenzt ist, müssen große Arrays (z. B. für Dateilisten) in ihrer Größe beschränkt werden. `MAX_FILES` wurde von 100 auf 50 reduziert, um einen Überlauf des BSS-Segments zu verhindern.
- **Plattformkompatibilität**: Funktionen wie `chdir`, `rmdir` und `getcwd` sind nicht auf allen cc65-Targets (z. B. C64) in der Standardbibliothek verfügbar. Diese müssen mit Präprozessor-Abfragen wie `#ifdef HAVE_SUBDIRS` abgesichert werden, um Linker-Fehler ("Unresolved external") zu vermeiden.
- **Vermeidung unerreichbaren Codes**: Da `main` oft eine Endlosschleife (`while(1)`) enthält, sollte danach kein `return`-Statement stehen, da dies eine Warnung über unerreichbaren Code ("Unreachable code") auslöst.
- **Verwendung von `static` für Puffer**: Größere Puffer innerhalb von Funktionen sollten ebenfalls `static` sein, um den Stack zu entlasten.

- **Kompilierung**: Um das Programm für den C64 zu kompilieren, wird im Verzeichnis `samples` der Befehl `make tinycmdr` (oder `make SYS=c64 tinycmdr`) verwendet.
- **Erstellung des Disk-Images**: Ein .d64-Disk-Image (z. B. für Emulatoren) kann mit dem Befehl `make disk SYS=c64` im `samples`-Verzeichnis erstellt werden. Dies setzt voraus, dass das Tool `c1541` (Teil von VICE) installiert ist. Das resultierende Image `samples.d64` enthält dann alle für den C64 kompilierten Beispiele, einschließlich `tinycmdr`.



