# cc65 Copilot Instructions

cc65 is a cross-development toolchain for 6502/65C02 systems, targeting platforms like the Commodore 64, Apple II, Atari, NES, and many others. It compiles C and assembles 6502 code on a modern host (Linux/macOS/Windows), producing binaries that run on the target machines.

## Build Commands

```bash
make              # Build everything: tools, libraries, docs, samples
make bin          # Build only host toolchain binaries (cc65, ca65, ld65, etc.)
make lib          # Build only target libraries
make DEBUG=0      # Release build (no debug info); default is DEBUG=1
make clean        # Remove all generated files
```

Build subdirectories individually:
```bash
make -C src                  # Rebuild host tools only
make -C libsrc               # Rebuild all target libraries
make -C libsrc c64           # Rebuild library for one specific target
make -C samples SYS=c64      # Build samples for one platform
```

## Test Commands

```bash
make test                        # Run compiler/assembler/linker regression tests
make check                       # Full validation: style + sorted + tests + samples + targettest
make checkstyle                  # Whitespace, line-ending, and formatting checks only
make -C targettest SYS=c64       # Build target-specific tests for one platform
```

Tests live in `test/` with subdirectories:
- `val/` — C programs that must compile and exit with `EXIT_SUCCESS`
- `err/` — C programs that must **not** compile
- `ref/` — programs whose compiler output is compared against `.cref` reference files
- `standard/` — like `val/` but compiled per C standard (C89, C99, CC65)
- `asm/` — assembler regression tests
- `dasm/` — disassembler regression tests

To run a specific test subdirectory:
```bash
make -C test/val             # Compiler validation tests only
make -C test/err             # Compiler error tests only
make -C test/standard        # C standard conformance tests only
make -C test/asm/opcodes     # Assembler opcode tests only
```

To run a single test manually, build the toolchain first (`make bin`) then compile with `bin/cc65` / `bin/ca65` / `bin/ld65` directly or use the `cl65` driver. The test suite runs binaries through `sim65` (4-billion-cycle limit per test).

## Architecture

### Compilation Pipeline

```
foo.c  →  cc65  →  foo.s  →  ca65  →  foo.o  →  ld65  →  target binary
                                  ar65  →  libfoo.a  ↗
```

`cl65` is a driver that orchestrates the full pipeline. The linker (`ld65`) is configured by a `.cfg` file from `cfg/` that defines memory areas and segments for the target platform.

### Host Tools (built in `src/`, land in `bin/`)

| Tool | Purpose |
|------|---------|
| `cc65` | C compiler: emits 6502 assembly |
| `ca65` | Macro assembler |
| `ld65` | Linker |
| `cl65` | All-in-one driver (wraps cc65/ca65/ld65) |
| `ar65` | Librarian/archiver |
| `sim65` | 6502 software simulator (used by the test suite) |
| `da65` | Disassembler |
| `od65` | Object-file dump utility |
| `co65` | Object converter |
| `sp65` | Sprite/graphics converter |
| `grc65` | GEOS resource compiler |
| `chrcvt65` | Character set converter |

Shared code for the host tools lives in `src/common/`.

### Target Platforms

Each target platform has three components:
1. **Linker config** in `cfg/<target>.cfg` — defines memory layout (RAM, ROM, zero page, etc.)
2. **Runtime library** in `libsrc/<target>/` — platform-specific C and assembly sources
3. **Target descriptor** in `target/<target>.tgt` (if present)

The `libsrc/` tree is organized as `libsrc/<platform>/` for platform-specific code and `libsrc/common/` for shared code. Subdirectories like `libsrc/conio/`, `libsrc/mouse/`, `libsrc/em/` contain generic driver frameworks.

Built libraries land in `lib/<target>.lib`. Headers shared across all targets are in `include/`; assembler macros/definitions for 6502 platforms are in `asminc/`.

## Code Style Conventions

### C Sources (host tools in `src/`)

- **Standard**: C89 with limited C99 (`stdint.h`, `inttypes.h`/`PRIX64` macros are allowed)
- **Comments**: ANSI `/* */` only — never `//`
- **Indentation**: 4 spaces, no tabs
- **Line length**: ~80 columns (soft limit)
- **Braces**: opening brace on same line for `if`/`for`/`while`; always use braces even for single-statement bodies
- **Function calls**: space before parenthesis — `foo (bar)`, not `foo(bar)`
- **Pointer declaration**: asterisk next to type — `char* p`, not `char *p`
- **Declarations**: all local variable declarations must be at the top of their block
- **Function comments**: each function must have a comment block between the signature and the opening `{` describing what it does, its parameters, and return value:

```c
int foo (int bar)
/* Add 1 to bar, returns the result */
{
    return bar + 1;
}
```

- **No warnings policy**: fix the root cause; do not hide warnings with casts

### Assembly Sources (library in `libsrc/`)

- Opcode mnemonics in **lowercase** (`lda`, `jsr`, not `LDA`, `JSR`)
- Hexadecimal values in **uppercase** (`$FF00`, not `$ff00`)
- Zero-page addresses use 2 hex digits (`$02`); non-zero-page use 4 (`$D011`)
- Fields (label, opcode, operand, comment) aligned to multiples of 8 columns
- Inline comments on the right side of instructions must be aligned within a block

### Exported Symbol Naming (library code)

Any non-standard symbol exported from library source files or appearing in standard headers:
- **C code**: must start with `__` (two underscores), e.g. `__fastcall__`
- **Assembly code**: must start with `___` (three underscores)
- Exception: symbols in non-standard (cc65-specific) headers may skip this rule

### General (all files)

- LF line endings only (configure your editor)
- No trailing whitespace; files must end with a newline
- No non-ASCII characters
- Avoid `/* */` comment-out of dead code — use `#if 0 ... #endif` instead

## Adding a New Target Platform

1. Create `cfg/<target>.cfg` with the memory map
2. Create `libsrc/<target>/` with at minimum `crt0.s` (startup code) and a `Makefile`
3. Add the target to `libsrc/Makefile`
4. Add headers to `include/` if needed
5. Add a `targettest/<target>/` entry and a `samples/` platform entry if applicable

## Developer Notes

- `bin/`, `lib/`, `libwrk/`, `wrk/`, and `html/` are generated — do not commit files there
- Style checks are enforced by scripts in `.github/checks/` and run as part of `make check`
- The project targets both Unix and Windows `cmd.exe` — Makefiles must work on both
- Every function in a separately compilable library file so the linker can strip unused code
- The primary documentation is in `doc/` (LinuxDoc format); `html/` is the generated output

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
