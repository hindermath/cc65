<!--
Sync Impact Report
- Version change: 1.0.0 -> 1.1.0
- Bump rationale:
  - MINOR: Added workspace-baseline alignment guidance from the repository root `constitution.md` without removing repository-specific principles.
- Modified principles:
  - None
- Added sections:
  - Workspace Baseline Alignment / Observability & Continuous Measurement
  - Workspace Baseline Alignment / Programmierung #include<everyone> — Inclusion & Accessibility By Default
  - Workspace Baseline Alignment / DE-First / EN-Second Delivery
  - Workspace Baseline Alignment / Four-Agent Guidance Parity
  - Workspace Baseline Alignment / Runtime Guidance References
- Removed sections:
  - None
- Templates requiring updates:
  - .specify/templates/plan-template.md: pending review
  - .specify/templates/spec-template.md: pending review
  - .specify/templates/tasks-template.md: pending review
  - .specify/templates/commands/constitution.md: pending review
- Follow-up TODOs:
  - Review template and runtime-guidance wording for repository-specific propagation where needed.
-->

# cc65 Constitution

## Core Principles

### I. Toolchain Stability

The cc65 toolchain (cc65, ca65, ld65, cl65, ar65, da65, sim65) MUST remain
backward-compatible at the user-facing level. Breaking changes to compiler
output format, error/warning messages, or linker configuration syntax MUST
update all affected reference files in `test/ref/` and be explicitly
described in the PR. New features MUST NOT silently alter existing behavior.

**Rationale**: Downstream projects—including many vintage-computing projects
targeting the 27+ supported platforms—depend on stable, predictable toolchain
behavior. Silent regressions erode community trust and break third-party
build pipelines without warning.

### II. Code Style & ANSI C Compliance

All C source in `src/` MUST conform to the project coding conventions
enforced by `make checkstyle`:

- **Line endings**: Unix LF only — no CRLF, ever.
- **Indentation**: 4 spaces — no TABs anywhere in source files.
- **Comments**: `/* ... */` ANSI C style only; `//` C++ line comments are
  FORBIDDEN.
- **Braces**: Cuddling style (`if (cond) {`); braces MUST be used even for
  single-statement blocks.
- **Variable declarations**: At the beginning of a block (C89 style).
- **Function calls**: One space between function name and argument list
  (`func (arg)`).
- **Pointers**: Asterisk adjacent to the type (`int* ptr`).
- **Exported identifiers**: Non-standard exported symbols MUST start with
  `__` (C) or `___` (assembly); see `libsrc/NameClashes.md`.

Assembly source (ca65) MUST use lower-case mnemonics and upper-case hex
constants (e.g., `bcc`, `lda #$C0`).

**Rationale**: Consistent style reduces review friction and keeps the
codebase legible across a long-lived open-source project. The C89 constraint
matches the self-hosting goal and the oldest supported host compilers.

### III. Platform Portability

cc65 targets 27+ platforms. Changes to `libsrc/` MUST remain isolated to
the affected platform directory unless a cross-platform fix is explicitly
justified in the PR. Build and toolchain source MUST compile cleanly on
Linux, macOS, and Windows. Platform-specific APIs (`chdir`, `rmdir`,
`getcwd`) MUST be guarded with appropriate `#ifdef` macros (e.g.,
`HAVE_SUBDIRS`).

**Rationale**: Supporting a wide range of vintage platforms is cc65's core
value proposition. Accidental cross-contamination of one platform's runtime
into another produces hard-to-trace regressions on target hardware.

### IV. Test-First Validation (NON-NEGOTIABLE)

Every change MUST pass `make check` (style checks + sorted-table checks +
full regression suite) before merging. When compiler output format changes
(error/warning messages), the developer MUST update the affected reference
files in `test/ref/` as part of the same PR. New compiler features and bug
fixes MUST be accompanied by a test case in the appropriate `test/`
subdirectory (`val/`, `err/`, `ref/`, or `standard/`).

**Rationale**: The regression test suite is the primary safety net for a
self-hosting cross-compiler. Skipping it allows silent regressions that are
extremely expensive to diagnose on real hardware.

### V. Memory Discipline

Code targeting 8-bit platforms MUST respect tight hardware memory limits:

- Local variables in complex functions MUST be declared `static` where
  required to avoid the cc65 "Too many local variables" error and to reduce
  stack pressure.
- Array size constants (e.g., `MAX_FILES = 144`) MUST be justified against
  the BSS segment budget.
- Heap allocation on target platforms SHOULD be avoided unless explicitly
  required and documented with a memory-impact comment.

**Rationale**: 8-bit 6502 systems have severely constrained RAM (commonly
less than 64 KB total). Ignoring these limits produces code that compiles
successfully but crashes or corrupts memory on real hardware.

## C64 / tinycmdr Development Standards

The primary active sample project `samples/tinycmdr` (a Norton
Commander-style file manager for C64) carries these additional rules:

- **UI colors**: Background `COLOR_BLUE`, text `COLOR_WHITE`, selection
  `COLOR_YELLOW`, directories `COLOR_GREEN`, shortcuts/prompts `COLOR_CYAN`,
  errors/confirmations `COLOR_RED`. Deviations MUST be approved explicitly.
- **Screen state**: After any prompt or destructive operation,
  `display_attributes()` MUST be called to restore the screen state.
- **Deletion safety**: File deletion MUST require a two-keypress
  confirmation sequence before executing.
- **CBM file types**: Copy and rename operations MUST preserve the CBM file
  type suffix (e.g., `,p` for PRG files).
- **Platform guards**: `chdir`, `rmdir`, `getcwd` MUST be wrapped with
  `#ifdef HAVE_SUBDIRS` because they are unavailable on C64.

## Build & CI Standards

- `make` builds everything: tools, libraries, documentation, and samples.
- `make check` is the full validation gate and MUST pass before any PR is
  considered mergeable.
- `make checkstyle` MUST pass on every committed file, including new files.
- Release artifacts use `make DEBUG=0`.
- The shared library (`src/common/`) MUST be fully built before individual
  tools are linked.
- All samples (including `tinycmdr`) MUST build without errors after any
  toolchain change.

## Workspace Baseline Alignment

This Spec-Kit constitution inherits the binding workspace-family governance from `constitution.md` in the repository root. Project-specific rules remain in force; where both apply, the stricter rule wins.

### A. Observability & Continuous Measurement

Every repository MUST maintain `docs/project-statistics.md` as a living statistics ledger. The conservative manual reference is `80` lines/workday. If this repository later documents a project-specific Thorsten-Solo baseline, it MUST be recorded consistently across `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and `.github/copilot-instructions.md`. The TVöD workday baseline is `7.8 h` (`7h 48m`). Shared statistics guidance MUST stay consistent across `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and `.github/copilot-instructions.md`.

### B. Programmierung #include<everyone> — Inclusion & Accessibility By Default

`Programmierung #include<everyone>` is a binding repository-wide principle. All user-facing artefacts — including CLI output, documentation and Markdown, HTML and generated websites, graphical user interfaces, and generated templates or scaffolding — MUST follow WCAG 2.2 Level AA wherever the criteria are applicable. They MUST remain usable with keyboard-only interaction, screen readers, Braille displays, and text browsers. Accessibility review is part of completion, not post-processing.

### C. DE-First / EN-Second Delivery

German is the canonical first language for user-facing governance and documentation in this repository family; English follows directly after it. User-facing and learner-facing guidance MUST remain bilingual at approximately CEFR-B2 readability, and materially changed guidance MUST update both language tracks in the same change.

### D. Four-Agent Guidance Parity

Shared operational guidance MUST be kept aligned across `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and `.github/copilot-instructions.md`. Shared rules MUST NOT be updated in only one file. Any intentional deviation MUST be documented explicitly in the same change. The same shared rules MUST also be propagated to the relevant project templates and `.specify/memory/constitution.md`.

### E. Runtime Guidance References

Governance text that references runtime guidance MUST name all four maintained agent surfaces: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and `.github/copilot-instructions.md`.

## Governance

This constitution supersedes all informal conventions in the cc65 repository.
Where a convention in CLAUDE.md or a PR description conflicts with a
principle here, this constitution takes precedence.

**Amendment procedure**: Amendments MUST be proposed as a PR modifying
`.specify/memory/constitution.md`. Each amendment MUST:

1. Increment `CONSTITUTION_VERSION` according to semantic versioning:
   - MAJOR: backward-incompatible governance change or principle removal.
   - MINOR: new principle or section added, or materially expanded guidance.
   - PATCH: clarifications, wording, or typo fixes.
2. Set `LAST_AMENDED_DATE` to the date the PR is merged.
3. Prepend an updated Sync Impact Report in the HTML comment at the top of
   this file.
4. Propagate any required changes to `.specify/templates/` in the same PR.

**Compliance review**: All PR descriptions and plan documents MUST include a
"Constitution Check" confirming compliance with active principles. Justified
deviations MUST be recorded in the plan's "Complexity Tracking" table.

**Runtime guidance**: For AI-assistant conventions and build command
reference, see `CLAUDE.md` at the repository root.

**Version**: 1.1.0 | **Ratified**: 2026-03-31 | **Last Amended**: 2026-04-20
