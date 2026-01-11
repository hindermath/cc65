# Entwickler-Guidelines & Präferenzen

Diese Datei dient als Langzeitgedächtnis für die Zusammenarbeit an diesem Projekt. Sie enthält technische Standards, bevorzugte Workflows und spezifische Anforderungen des Entwicklers.

## Projekt-Kontext
- **Zielsystem:** Commodore 64 (C64)
- **Toolchain:** cc65 (Compiler, Assembler, Linker)
- **Hauptprojekt:** `tinycmdr` (ein Norton-Commander-ähnliches TUI-Tool)

## Technische Standards & Optimierungen
- **Speichermanagement:** Auf 8-Bit-Systemen (C64) ist der Speicher begrenzt.
    - Lokale Variablen in komplexen Funktionen sollten als `static` deklariert werden, um den cc65-Fehler "Too many local variables" zu vermeiden und den Stack zu schonen.
    - Große Arrays (z.B. Dateilisten) müssen in ihrer Größe beschränkt werden (derzeit `MAX_FILES = 50`), um BSS-Segment-Überläufe zu verhindern.
- **Plattformkompatibilität:** Funktionen wie `chdir`, `rmdir`, `getcwd` sind auf dem C64 nicht standardmäßig verfügbar und müssen über `#ifdef HAVE_SUBDIRS` abgesichert werden.
- **UI-Design:**
    - Hintergrundfarbe: Blau (`COLOR_BLUE`)
    - Textfarbe: Weiß (`COLOR_WHITE`)
    - Selektion: Gelb (`COLOR_YELLOW`)
    - Verzeichnisse: Grün (`COLOR_GREEN`)
    - Shortcuts/Prompts: Cyan (`COLOR_CYAN`) oder Rot (`COLOR_RED`) bei Fehlern/Bestätigungen.

## Workflow & Build-Prozess
- **Kompilierung:** Erfolgt über `make -C samples tinycmdr`.
- **Disk-Images:** Erstellung von `.d64` Images mittels `make -C samples disk SYS=c64` (erfordert `c1541` aus dem VICE-Paket).
- **Dateisystem:** Beim Kopieren oder Umbenennen auf C64-Systemen müssen Dateitypen (z.B. `,p` für PRG) beachtet werden.

## Verhaltensregeln für die KI
- **Informationen hinzufügen**: Der Entwickler kann mich jederzeit anweisen, neue Regeln oder Präferenzen in diese Datei aufzunehmen. Ich aktualisiere diese Datei dann eigenständig.
- Immer die bestehenden Speicheroptimierungen (`static`) beibehalten.
- Bei Änderungen an der UI sofort die Attributanzeige (`display_attributes`) aktualisieren oder sicherstellen, dass sie nach Prompts wiederhergestellt wird.
- Vor dem Löschen von Dateien immer eine Bestätigungsabfrage (zweimaliges Drücken der Löschtaste) implementieren.
- **Sprache**: Die Kommunikation erfolgt vorzugsweise auf Deutsch, während Code und technische Dokumentation in Englisch verfasst werden.
