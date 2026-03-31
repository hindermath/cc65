# Repository Guidelines

## Project Structure & Module Organization

`cc65` is a 6502 cross-development suite. Core host tools live in `src/` (`cc65`, `ca65`, `ld65`, `cl65`, `sim65`, and shared code in `src/common`). Runtime libraries and target-specific support live in `libsrc/`, with headers in `include/`, linker configs in `cfg/`, assembler includes in `asminc/`, and target descriptors in `target/`. Regression tests are split between `test/` (compiler/assembler/linker validation) and `targettest/` (platform-specific builds). `samples/` contains reference programs; `doc/` holds user and developer documentation. Treat `bin/`, `wrk/`, `lib/`, `libwrk/`, and `html/` as generated output.

## Build, Test, and Development Commands

Use GNU `make` from the repository root:

- `make` builds tools, libraries, docs, utilities, and samples.
- `make DEBUG=0` builds a release-style host toolchain without debug info.
- `make bin` rebuilds only the host executables in `bin/`.
- `make test` runs the regression suite in `test/`.
- `make check` runs style checks plus regression, sample, and platform validation.
- `make checkstyle` runs the whitespace, line-ending, and related checks from `.github/checks/`.
- `make -C targettest SYS=c64` builds target-specific test code for one platform.

## Coding Style & Naming Conventions

Follow `.editorconfig`: spaces only, 4-space indentation, trimmed trailing whitespace, and a final newline. Prefer LF line endings and keep most lines near 80 columns. C code is largely C89 with limited C99 use (`stdint.h`, `inttypes.h` macros). Use ANSI `/* ... */` comments, keep declarations at the start of blocks, always use braces for `if` statements, and place a space before function parentheses: `foo (bar)`. For exported library symbols, follow the underscore rules in `Contributing.md`.

## Testing Guidelines

There is no numeric coverage gate; contributors are expected to add or update regression tests for every behavior change. Place tests in the closest matching suite under `test/` (`err`, `val`, `ref`, `standard`, `asm`, etc.). When diagnostics or emitted output change, update the corresponding reference files as part of the same change. Run `make test` locally before opening a PR; use `make check` for broader validation.

## Commit & Pull Request Guidelines

Keep each commit and PR focused on one issue. Recent history uses short, imperative subjects, often with a touched area first, for example `Update Makefile: ...` or `Add disk usage tracking ...`. PRs should include a concise summary, link the relevant issue when one exists, confirm codestyle compliance, and note any new tests or documentation updates. Follow `.github/PULL_REQUEST_TEMPLATE.md`.
