# Command Template: `/speckit.checklist`

Use this command to generate review checklists for a feature or release.

## Required Actions

1. Build checklist items from `spec.md`, `plan.md`, and `tasks.md`.
2. Include governance checks for:
   - branch/PR compliance
   - constitution gate compliance
   - test evidence completeness
   - cc65 C/C89, 6502 assembler, and target-platform alignment
   - selected GNU `make` build/test commands and their results
   - Makefile-chain evidence for build-target changes
   - generated artefact handling from the nearest project-local `.gitignore`
     (`bin/`, `wrk/`, `lib/`, `libwrk/`, `html/`, `info/`, `target/`,
     `testwrk/`, object/list/map/debug outputs, target binaries, disk/tape
     images)
   - permanent `.dev-tools/` fork-surface review when hook or secret-scan
     behaviour changed
   - C89/limited-C99 style and secure-C/CERT-C review
   - real DE/EN guidance evidence where bilingual checks are relevant
   - generated Spec-Kit skill/command/agent surface parity where templates or
     presets changed
   - dependency and supply-chain documentation when release artefacts change
   - documentation completeness (bilingual + generated docs where required)

## Validation Checklist

- Checklist items are actionable and testable.
- Each item maps to a concrete artifact or command output.
