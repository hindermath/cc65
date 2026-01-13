# TinyCalc

## Purpose
TinyCalc is a simple (Tiny) spreadsheet calculation application designed to perform basic arithmetic operations and calculations on a grid-based interface.

## Analysing results of CALC.PAS

### Datenstrukturen und Typen
- `CellRec`: Record-Struktur für eine Zelle.
  - `CellStatus`: Set von Attributen (`Constant`, `Formula`, `Txt`, `OverWritten`, `Locked`, `Calculated`).
  - `Contents`: String[70] für Formeln oder Text.
  - `Value`: Real (Fließkommazahl) für das Ergebnis.
  - `DEC`, `FW`: Formatierung (Nachkommastellen und Spaltenbreite).
- `Sheet`: 2D-Array (`array['A'..'G', 1..21]`) von `CellRec`.

### Programmmodule und Funktionen
- **MC-MOD00 (Utilities)**: Hilfsfunktionen für Nachrichten (`Msg`), Blink-Effekte (`Flash`), Tastaturanpassung (`IBMCh`) und Auto-Berechnungs-Umschaltung.
- **MC-MOD01 (Initialisierung/Grid)**: Zeichnen des Gitters (`Grid`), Initialisierung des Speichers (`Init`) und Löschen des Arbeitsblatts (`Clear`).
- **MC-MOD02 (Navigation/Anzeige)**: Zellnavigation (`MoveUp`, `MoveDown`, etc.) und Anzeigeaktualisierung (`Update`, `GotoCell`, `LeaveCell`).
- **MC-MOD03 (I/O & Hilfe)**: Dateizugriff (`Load`, `Save`), Drucken (`Print`) und Anzeige der Hilfedatei `CALC.HLP`.
- **MC-MOD04 (Formelauswertung)**: Ein rekursiver Parser für mathematische Ausdrücke (`Evaluate`). Unterstützt Grundrechenarten, Potenzen (`^`) und Standardfunktionen (`ABS`, `SQRT`, `SIN`, `COS`, etc.) sowie Zellreferenzen (z.B. `A1`).
- **MC-MOD05 (Zellbearbeitung)**: Eingabe von Daten in Zellen (`GetCell`), Texteditierung (`GetLine`) und Formatierungseinstellungen (`Format`).

### Kritische Aspekte für die Portierung nach C (cc65)
- **Fließkommazahlen**: Pascal nutzt `Real`. In cc65 muss die Performance von `float` oder `double` auf dem 6502 beachtet werden.
- **Speichermanagement**: Ein Array von 147 `CellRec` (7 Spalten * 21 Zeilen) mit jeweils ~80 Bytes belegt ca. 11,7 KB RAM. Das ist auf dem C64 unproblematisch, aber die Organisation im Speicher (structs statt Pascal-Records) ist wichtig.
- **Rekursion**: Der Formel-Parser arbeitet stark rekursiv (`Expression` -> `SimpleExpression` -> `Term` -> `Factor` -> `Expression`). Auf dem C64 ist der Stack begrenzt; hier ist Vorsicht geboten oder eine iterative Lösung vorzuziehen.
- **UI/Terminal**: Pascal-Befehle wie `GotoXY`, `ClrEol` und `HighVideo/LowVideo` müssen auf die `conio.h` Funktionen von cc65 abgebildet werden.
- **Sets**: Die Pascal `set of Attributes` müssen in C über Bitmasken (`#define` oder `enum`) abgebildet werden.
- **Strings**: Pascal-Strings (Längenbyte am Anfang) müssen in C-Strings (null-terminiert) umgewandelt werden.


## C64 Screen Adaptation

Die ursprüngliche Pascal-Version `CALC.PAS` ist für eine 80-Zeichen-Auflösung (z.B. CP/M oder IBM PC) konzipiert. Der C64 verfügt über eine Bildschirmauflösung von **40x25 Zeichen**. Dies erfordert eine Anpassung des Grids und der Spaltenbreiten.

### Spalten- und Zeilenanpassung
- **Original (`CALC.PAS`)**: 7 Spalten (A-G), 21 Zeilen. Spaltenbreite standardmäßig 11 Zeichen (10 Daten + 1 Trenner). `XPOS`: 3, 14, 25, 36, 47, 58, 68.
- **C64 Anpassung**:
  - Um eine sinnvolle Anzeige zu ermöglichen, wird die Standardspaltenbreite auf **9 Zeichen** reduziert.
  - Das ermöglicht **3 Spalten** (A, B, C) gleichzeitig auf dem Bildschirm.
  - **XPOS (C64)**:
    - Zeilennummern (Spalte 1-3): 1-2 Stellen + Leerzeichen.
    - Spalte A: Start bei 4.
    - Spalte B: Start bei 14.
    - Spalte C: Start bei 24.
  - Die restlichen 6 Zeichen (34-40) können für Statusanzeigen oder Scroll-Indikatoren genutzt werden.
  - **Zeilen**: 20 Zeilen (FYMax) bleiben erhalten, da der C64 25 Zeilen bietet (20 für Daten, 5 für Header/Status/Eingabe).

### UI-Layout auf dem C64 (40 Spalten)
1. **Zeile 1**: Spaltenköpfe (A, B, C).
2. **Zeile 2-21**: Tabellendaten (Zeilen 1-20).
3. **Zeile 22**: Trennlinie oder Status.
4. **Zeile 23**: Zellinfo (z.B. `A1: Formula`).
5. **Zeile 24**: Eingabezeile / Fehlermeldungen.
6. **Zeile 25**: Funktionsmenü (z.B. `/ for Commands`).

### Technische Umsetzung (cc65)
- `FXMax`: Auf 'C' begrenzt (für die initiale Sicht).
- `FYMax`: 20.
- `XPOS`: `uint8_t xpos[] = {4, 14, 24};`
- Scrollen: Falls mehr Spalten benötigt werden, muss ein horizontaler "Viewport" implementiert werden (Zellen A-C, B-D, etc.).
- that is the cc65 environment
- the sample file directory are a good source to learn how to use the tinycalc applications is to create
  - CALC.PAS ist the Pascal Source file for the TinyCalc application. At this example AI Assistent and Junie should see and learn how to transfer the functionality to the tinycalc cc65 C application.
  -
## Development Tips and Error Prevention
To avoid compilation errors and warnings in the cc65 environment (especially for the C64), the following measures were taken:
- **Limiting Local Variables**: The cc65 compiler has a strict limit on the number of local variables per function. Bei komplexen Funktionen sollten lokale Variablen als `static` deklariert werden, um den "Too many local variables"-Fehler zu vermeiden.
- **Avoiding Uninitialized Variables**: Always initialize variables before using them to prevent "uninitialized variable" warnings.
- **Using `const` Correctly**: Use `const` for variables that should not be modified to avoid accidental modifications and potential bugs.
- **Memory Management**: Be mindful of memory usage, especially on systems with limited resources like the C64, to avoid "out of memory" errors.
- **Error Handling**: Implement proper error handling to gracefully manage unexpected situations and prevent crashes.
