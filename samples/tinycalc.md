# TinyCalc

## Purpose
TinyCalc is a simple (Tiny) spreadsheet calculation application designed to perform basic arithmetic operations and calculations on a grid-based interface.

## Analysing results of CALC.PAS

### Data Structures and Types
- `CellRec`: Record structure for a cell.
  - `CellStatus`: Set of attributes (`Constant`, `Formula`, `Txt`, `OverWritten`, `Locked`, `Calculated`).
  - `Contents`: String[70] for formulas or text.
  - `Value`: Real (floating-point number) for the result.
  - `DEC`, `FW`: Formatting (decimal places and column width).
- `Sheet`: 2D-Array (`array['A'..'G', 1..21]`) of `CellRec`.

### Program Modules and Functions
- **MC-MOD00 (Utilities)**: Helper functions for messages (`Msg`), blink effects (`Flash`), keyboard adjustment (`IBMCh`), and auto-calculation switching.
- **MC-MOD01 (Initialization/Grid)**: Drawing the grid (`Grid`), initializing memory (`Init`), and clearing the worksheet (`Clear`).
- **MC-MOD02 (Navigation/Display)**: Cell navigation (`MoveUp`, `MoveDown`, etc.) and display update (`Update`, `GotoCell`, `LeaveCell`).
- **MC-MOD03 (I/O & Help)**: File access (`Load`, `Save`), printing (`Print`), and display of the help file `tinycalc.hlp`.
- **MC-MOD04 (Formula Evaluation)**: A recursive parser for mathematical expressions (`Evaluate`). Supports basic arithmetic, powers (`^`), and standard functions (`ABS`, `SQRT`, `SIN`, `COS`, etc.) as well as cell references (e.g., `A1`).
- **MC-MOD05 (Cell Editing)**: Input of data into cells (`GetCell`), text editing (`GetLine`), and formatting settings (`Format`).

### Critical Aspects for Porting to C (cc65)
- **Floating-point numbers**: Pascal uses `Real`. In cc65, the performance of `float` or `double` on the 6502 must be considered.
- **Memory Management**: An array of 147 `CellRec` (7 columns * 21 rows) with ~80 bytes each occupies approx. 11.7 KB RAM. This is unproblematic on the C64, but the organization in memory (structs instead of Pascal records) is important.
- **Recursion**: The formula parser is highly recursive (`Expression` -> `SimpleExpression` -> `Term` -> `Factor` -> `Expression`). On the C64, the stack is limited; caution is required here, or an iterative solution is preferable.
- **UI/Terminal**: Pascal commands like `GotoXY`, `ClrEol`, and `HighVideo/LowVideo` must be mapped to the `conio.h` functions of cc65.
- **Sets**: The Pascal `set of Attributes` must be mapped in C via bitmasks (`#define` or `enum`).
- **Strings**: Pascal strings (length byte at the beginning) must be converted to C strings (null-terminated).


## C64 Screen Adaptation

The original Pascal version `CALC.PAS` is designed for an 80-character resolution (e.g., CP/M or IBM PC). The C64 has a screen resolution of **40x25 characters**. This requires an adaptation of the grid and column widths.

### Column and Row Adaptation
- **Original (`CALC.PAS`)**: 7 columns (A-G), 21 rows. Column width default is 11 characters (10 data + 1 separator). `XPOS`: 3, 14, 25, 36, 47, 58, 68.
- **C64 Adaptation**:
  - To allow for a reasonable display, the default column width is reduced to **9 characters**.
  - This allows **3 columns** (A, B, C) simultaneously on the screen.
  - **XPOS (C64)**:
    - Row numbers (columns 1-3): 1-2 digits + space.
    - Column A: Start at 4.
    - Column B: Start at 14.
    - Column C: Start at 24.
  - The remaining 6 characters (34-40) can be used for status displays or scroll indicators.
  - **Rows**: 20 rows (FYMax) are retained, as the C64 offers 25 rows (20 for data, 5 for header/status/input).

### UI Layout on the C64 (40 columns)
1. **Line 1**: Column headers (A, B, C).
2. **Line 2-21**: Table data (rows 1-20).
3. **Line 22**: Separator line or status.
4. **Line 23**: Cell info (e.g., `A1: Formula`).
5. **Line 24**: Input line / error messages.
6. **Line 25**: Function menu (e.g., `/ for Commands`).

### Technical Implementation (cc65)
- `FXMax`: Limited to 'C' (for the initial view).
- `FYMax`: 20.
- `XPOS`: `uint8_t xpos[] = {4, 14, 24};`
- Scrolling: If more columns are needed, a horizontal "viewport" must be implemented (cells A-C, B-D, etc.).
- This is the cc65 environment.
- The sample file directory is a good source to learn how to use the TinyCalc application:
  - `CALC.PAS` is the Pascal source file for the TinyCalc application. In this example, AI assistants like Junie can see and learn how to transfer the functionality to the TinyCalc cc65 C application.
  -
## Development Tips and Error Prevention
To avoid compilation errors and warnings in the cc65 environment (especially for the C64), the following measures were taken:
- **Limiting Local Variables**: The cc65 compiler has a strict limit on the number of local variables per function. For complex functions, local variables should be declared as `static` to avoid the "Too many local variables" error.
- **Avoiding Uninitialized Variables**: Always initialize variables before using them to prevent "uninitialized variable" warnings.
- **Using `const` Correctly**: Use `const` for variables that should not be modified to avoid accidental modifications and potential bugs.
- **Memory Management**: Be mindful of memory usage, especially on systems with limited resources like the C64, to avoid "out of memory" errors.
- **Error Handling**: Implement proper error handling to gracefully manage unexpected situations and prevent crashes.

- **Compilation**: To compile the program for the C64, use the command `make tinycalc` (or `make SYS=c64 tinycalc`) in the `samples` directory.
- **Creation of the disk image**: A .d64 disk image (e.g. for emulators) can be created with the command `make disk SYS=c64` in the `samples` directory. This assumes that the `c1541` tool (part of VICE) is installed. The resulting image `samples.d64` then contains all examples compiled for the C64, including `tinycalc`. This step should be carried out after every successful compilation. After successful creation, the emulator VICE can be started with the command `/opt/homebrew/bin/x64sc -8 samples.d64`.
