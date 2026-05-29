# Command Template: `/speckit.tasks`

Use this command to generate an executable task list from `plan.md` and `spec.md`.

## Required Actions

1. Organize tasks by user story for independent delivery.
2. Include Red-Green-Refactor test tasks before implementation tasks.
3. Include documentation tasks:
   - bilingual updates (German block first, then English)
   - `doc/`, `samples/`, generated `html/`, and user-facing CLI text updates
     where relevant
4. Include cc65 build, test, and artefact tasks:
   - Makefile-chain reading before changing target behaviour
   - focused GNU `make` target(s) for the changed area
   - regression or reference-file updates under `test/` when behavior changes
   - `targettest` or sample disk-image checks when target output changes
   - generated artefact classification from the nearest project-local
     `.gitignore` so build outputs are not committed accidentally
   - `scripts/` plus permanent `.dev-tools/` review when hook or secret-scan
     behaviour changes in this fork
   - generated Spec-Kit skill/command/agent parity checks when templates,
     presets, or shared guidance change
5. Include PR preparation task (purpose, touched projects, test evidence, config/API impact).

## Validation Checklist

- Every code change has corresponding tests.
- Documentation and governance tasks are present.
- Task ordering supports incremental, verifiable delivery.
- Build, regression, target, sample, and dependency/supply-chain tasks are
  explicitly scheduled where applicable.
