# Command Template: `/speckit.plan`

Use this command to produce an implementation plan from an approved specification.

## Required Actions

1. Populate technical context with real stack details.
2. Execute the Constitution Check gates explicitly:
   - branching and PR flow
   - cc65 C/C89, 6502 assembler, and target-platform alignment
   - GNU `make` build/test path selection
   - generated artefact ownership and cleanup expectations
   - architecture/module boundaries across host tools, runtime libraries,
     target descriptors, tests, samples, and docs
   - C89/limited-C99 style and secure-C/CERT-C review
   - bilingual CEFR B2 documentation scope
   - non-MSL justification for cc65 C89 / 6502 assembly where relevant
   - regression, targettest, sample-build, and documentation validation scope
   - dependency and supply-chain evidence for host tools and release artefacts
   - serialization/data conventions
3. Document concrete project structure for this feature.
4. Record justified exceptions in Complexity Tracking.

## Validation Checklist

- No gate is left unresolved without rationale.
- Build, test, generated artefact, dependency, and documentation impacts are
  planned before implementation.
