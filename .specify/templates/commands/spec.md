# Command Template: `/speckit.specify`

Use this command to create or update a feature specification.

## Required Actions

1. Create a branch for the feature (never work directly on `main`).
2. Fill `spec.md` with prioritized, independently testable user stories.
3. Define measurable outcomes and explicit edge cases.
4. Fill the Constitution Alignment section with concrete impacts:
   - cc65 C/C89 host-tool, 6502 assembler/runtime, or target-platform impact
   - GNU `make` build/test target impact (`make`, `make test`, `make check`,
     `make checkstyle`, `make -C targettest SYS=<target>`, sample disk builds)
     plus the Makefile chain that owns the affected targets
   - generated artefact impact from the nearest project-local `.gitignore`
     (`bin/`, `wrk/`, `lib/`, `libwrk/`, `html/`, `info/`, `target/`,
     `testwrk/`, sample `.o`/`.s`/`.map`/`.dbg` files, target binaries, disk
     or tape images)
   - permanent `.dev-tools/` fork-surface impact when hook or secret-scan
     behaviour changes
   - C89/limited-C99 coding-style and secure-C/CERT-C impact
   - module placement (`src/`, `libsrc/`, `include/`, `cfg/`, `asminc/`,
     `target/`, `test/`, `targettest/`, `samples/`, `doc/`)
   - bilingual documentation impact (German first, English second, CEFR B2)
   - non-MSL justification and compensating-control impact for cc65 C89 /
     6502 assembly
   - regression, target, sample, and documentation test impact
   - generated Spec-Kit skill/command/agent surface impact when templates or
     presets change
   - data contract implications

## Validation Checklist

- Each story can be tested independently.
- Requirements are implementation-agnostic.
- Constitution alignment items are complete and non-empty.
- Toolchain, generated artefact, target-platform, and test constraints are
  explicit and measurable.
