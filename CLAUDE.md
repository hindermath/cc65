# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```sh
make              # Build everything: tools, libraries, docs, samples
make bin          # Build only the compiler toolchain binaries (→ /bin/)
make lib          # Build only the platform runtime libraries (→ /lib/)
make DEBUG=0      # Release build without debug symbols

make test         # Run the regression test suite (requires lib to be built first)
make check        # Full validation: style checks + sorted tables + tests
make checkstyle   # Code style checks only (line endings, tabs, trailing spaces)

make -C samples tinycmdr              # Build the tinycmdr sample
make -C samples disk SYS=c64         # Create a C64 .d64 disk image (requires c1541 from VICE)

make install PREFIX=/usr/local        # Install to system
make clean                            # Remove build artifacts
```

## Architecture Overview

cc65 is a complete cross-development toolchain for 65(C)02 systems. The repository is structured as several independent tools that share a common library:

| Directory | Purpose |
|-----------|---------|
| `src/cc65/` | C compiler (largest component, ~545 KB binary) |
| `src/ca65/` | Macro assembler |
| `src/ld65/` | Linker |
| `src/ar65/` | Archiver |
| `src/cl65/` | Compiler driver (wrapper that orchestrates the full build pipeline) |
| `src/da65/` | Disassembler |
| `src/sim65/` | 6502 software simulator |
| `src/common/` | Shared library used by all tools |
| `libsrc/` | Platform-specific runtime library sources (47 platform dirs) |
| `cfg/` | Linker configuration files, one per platform variant |
| `asminc/` | Assembly include files (.inc) for platform headers |
| `include/` | C header files (standard library + platform headers) |
| `samples/` | Example programs; `tinycmdr` is the main active project here |
| `test/` | Regression tests: `asm/`, `val/`, `err/`, `ref/`, `standard/` subdirs |

**Build flow**: `src/Makefile` builds all tools into `/bin/`. The common library (`wrk/common/common.a`) is built first and linked into each tool. Libraries for target platforms are built separately by `libsrc/Makefile`.

**Platform configuration**: Each supported target (C64, NES, Atari, Apple II, etc.) has a linker config in `cfg/` and a runtime library directory in `libsrc/`. The 27+ supported platforms are listed in README.md.

## Coding Conventions

These are enforced by `make checkstyle` and CI:

- **Line endings**: Unix LF only — configure your editor accordingly
- **Indentation**: 4 spaces, no TABs
- **Line width**: 80 characters preferred (not hard-enforced)
- **Comments**: Use `/* ... */` ANSI C style only — **never `//` C++ comments**
- **Braces**: Cuddling style (`if (cond) {`), always use braces even for single statements
- **Function calls**: One space between name and argument list: `func (arg)`
- **Pointers**: Asterisk with the type: `int* ptr;`
- **Variable declarations**: At the beginning of a block (C89 style)
- **Identifiers**: Non-standard exported symbols must start with `__` (C) or `___` (assembly) — see `libsrc/NameClashes.md`

Assembly (ca65):
- Mnemonics in lower-case (`bcc`, `lda`)
- Hex constants in upper-case (`$C000`)

## C64 / tinycmdr Specific

The primary active development is `samples/tinycmdr` — a Norton Commander-style file manager for C64.

**Memory constraints** (8-bit system):
- Declare local variables as `static` in complex functions to avoid the cc65 "Too many local variables" error and to save stack space
- `MAX_FILES = 144` — limits file list to fit in the BSS segment (fits a full D64 disk image)

**Platform guards**: `chdir`, `rmdir`, `getcwd` are not available on C64 — wrap with `#ifdef HAVE_SUBDIRS`

**UI color conventions**:
- Background: `COLOR_BLUE`
- Text: `COLOR_WHITE`
- Selection: `COLOR_YELLOW`
- Directories: `COLOR_GREEN`
- Shortcuts/prompts: `COLOR_CYAN`; errors/confirmations: `COLOR_RED`

**UI invariant**: After any prompt or destructive operation, call `display_attributes()` to restore the screen state.

**Deletion safety**: Implement two-keypress confirmation before deleting files.

**CBM file types**: When copying or renaming files on C64, preserve the file type suffix (e.g., `,p` for PRG files).

## Testing

Tests live in `test/` with subdirectories by category:
- `val/` — compiler validation (majority of tests)
- `err/` — programs that must NOT compile
- `ref/` — output compared against reference files
- `standard/` — C89/C99 conformance
- `todo/` — known failing tests (open bugs)

PRs must pass `make check` with no failures. If compiler output format changes (error/warning messages), update the affected reference files in `test/ref/`.

To compile with strict warnings: `make USER_CFLAGS=-Werror`
<!-- claude-init-done -->

## Hinweise / Notes

- Diese Datei ergaenzt die projektspezifische Dokumentation mit agentischen Arbeitsregeln.
- This file complements the project-specific documentation with agent-oriented working rules.
