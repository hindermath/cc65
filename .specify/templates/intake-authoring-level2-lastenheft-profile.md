# Level-2 Lastenheft Authoring Profile

## Identity

- Profile ID: `level2-lastenheft`
- Applies when: An active Level-2 requirements document is prepared for one later Spec Kit feature.
- Target path rule: Preserve the repository-owned `Lastenheft_*.md` path and processing order.
- Language rule: German first and English second, CEFR B2.

## Required Sections

Preserve purpose, current and target state, scope, non-goals, atomic
requirements, quality and governance boundaries, dependencies, risks,
expected artifacts, evidence, measurable acceptance, assumptions, and
ordering. Every active intake ends with exactly one copy-ready Specify prompt
and one copy-ready Autonomous prompt. Creating or reviewing an intake starts
no feature.

## Naming And Ordering

Preserve stable filenames, predecessor gates, and archived feature suffixes.
Ordering conflicts are material and must not be guessed.

## Quality Gates

The primary cc65 C89 and 6502 assembly stack is intentionally non-MSL. Preserve its documented justification and require bounds checks, safe string APIs, explicit input validation, and target-specific proof without treating MSL status as fulfilled.

Apply repository security, privacy, architecture, A11Y, agent-parity,
cross-platform, statistics, and evidence rules. Use text-first WCAG 2.2 AA
where applicable. The Autonomous prompt defaults to `LocalImplementation`
and grants no remote, bypass, secret, provider, or follow-up-feature authority.
