# Project Context: cc65

cc65 is a complete cross-development package for 65(C)02 systems, including a powerful macro assembler (ca65), a C compiler (cc65), linker (ld65), archiver (ar65), simulator (sim65), and several other tools. It provides C and runtime library support for many classic 8-bit machines (Apple II, Atari, Commodore, NES, etc.).

## 🛠 Building and Running

### Core Toolchain
- **Build all:** `make` (includes tools, libraries, samples, and docs).
- **Build tools only:** `make bin`
- **Build libraries only:** `make lib`
- **Release build (no debug info):** `make DEBUG=0`
- **Clean:** `make clean` or `make mostlyclean`

### Testing and Validation
- **Run regression tests:** `make test` (requires libraries to be built first).
- **Run all checks:** `make check` (includes style checks, sorted tables, and tests).

### Samples (e.g., C64)
- **Compile a sample:** `make -C samples <sample_name>` (e.g., `make -C samples hello`).
- **Build tinycmdr:** `make -C samples tinycmdr`
- **Create C64 disk image:** `make -C samples disk SYS=c64` (requires `c1541` from VICE).

## 📏 Development Conventions

### General Standards
- **Line Endings:** Unix style (LF) only.
- **Indentation:** 4 spaces (no TABs).
- **Character Set:** Prefer ASCII; avoid non-ASCII characters.
- **Max Width:** Aim for 80 characters.

### C Coding Style (C89/C99)
- **Comments:** Use ANSI C comments `/* ... */`. **Do NOT use C++ comments `//`**.
- **Braces:** Use "cuddling" braces: `if (condition) { ... }`. Always use braces even for single statements.
- **Spacing:** Separate function names and parameter lists by one space: `func (arg)`.
- **Pointers:** Asterisk goes with the type: `int* ptr;`.
- **Variable Declarations:** Must be at the beginning of a block.
- **Headers:** Function prototypes should be on a single line and follow a standard comment block.

### Assembly Coding Style (ca65)
- **Mnemonics:** Use lower-case official mnemonics (e.g., `bcc`, `lda`).
- **Hex Constants:** Use upper-case (e.g., `$C000`).
- **Alignment:** Align comments on the right side of instructions.

### 🕹 Target Specific: Commodore 64 (C64)
- **Memory Optimization:** 
    - Declare local variables as `static` in complex functions to avoid "Too many local variables" and save stack space.
    - Limit large arrays (e.g., `MAX_FILES = 144`) to fit in BSS segments.
- **UI Colors:**
    - Background: `COLOR_BLUE`
    - Text: `COLOR_WHITE`
    - Selection: `COLOR_YELLOW`
    - Directories: `COLOR_GREEN`
- **Portability:** Use `#ifdef HAVE_SUBDIRS` for file system operations like `chdir` or `getcwd`.

## 📁 Project Structure

- `src/`: Source code for the cc65 tools (compiler, assembler, linker, etc.).
- `libsrc/`: Source code for the runtime and target-specific libraries.
- `include/`: Public C header files.
- `asminc/`: Public assembly include files.
- `cfg/`: Linker configuration files for various targets.
- `samples/`: Example programs and the `tinycmdr` project.
- `test/`: Regression test suite.
- `doc/`: Documentation (LinuxDoc format).

---


## Gemeinsame Governance-Ergaenzung / Shared Governance Addendum

- `Programmierung #include<everyone>` gilt repo-weit als verbindlicher Leitsatz.
- `Programmierung #include<everyone>` is a binding repository-wide guiding principle.

- Alle nutzerseitigen Artefakte muessen barrierefrei gedacht und geprueft werden: CLI-Ausgaben, Dokumentation, HTML, UI und generierte Templates; WCAG 2.2 Level AA ist die Standard-Basis, sobald die Kriterien auf das Artefakt anwendbar sind.
- All user-facing artefacts must be designed and reviewed for accessibility: CLI output, documentation, HTML, UI, and generated templates; WCAG 2.2 Level AA is the default baseline wherever the criteria apply.

- Gemeinsame Guidance folgt DE zuerst, EN danach; fuer grosse normative Dokumente ist eine synchron gepflegte `.EN.md`-Parallelfassung zulaessig.
- Shared guidance follows DE first, EN second; for large normative documents, a synchronised `.EN.md` sidecar is acceptable.

- Shared guidance wird immer gemeinsam in `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` und `.github/copilot-instructions.md` gepflegt; Abweichungen muessen in derselben Aenderung dokumentiert werden.
- Shared guidance must be maintained together in `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and `.github/copilot-instructions.md`; any intentional divergence must be documented in the same change.

- Fuer C#/.NET-Repositories gilt standardmaessig eine Thorsten-Solo-Basis von `125` Zeilen/Arbeitstag, sofern das Repo keinen abweichenden, begruendeten Wert dokumentiert.
- The default Thorsten-solo baseline for C#/.NET repositories is `125` lines/workday unless the repository documents a justified deviation.

## Hinweise / Notes

- Diese Datei bleibt bewusst kompakt und ergänzt die projektspezifische Dokumentation.
- This file intentionally stays compact and complements the project-specific documentation.
