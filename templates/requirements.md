# Requirements: <Feature Name>

> **Reading order**: read this file first, then `design.md` (interfaces, data flow,
> worked examples), then `tasks.md` (phased implementation). Past decisions are in the
> Decision Log below; open discussion lives in `requirements-feedback.md`.

## Problem Statement

<!-- Why does this need to exist? What problem does it solve? What breaks without it?
     If specs/.config.md names a product doc, cite its sections instead of restating
     them. -->

## User Stories

- As a **[persona]**, I want **[capability]** so that **[benefit]**
- As a **[persona]**, I want **[capability]** so that **[benefit]**

## Acceptance Criteria

<!-- All ACs are numbered AC-N.M and cross-referenced by design.md and tasks.md.
     AC numbers must NOT be renumbered after the requirements are approved — they are
     the contract. Group ACs by category. Use WHEN/THEN format within each AC. -->

### AC-1: [Category name]

- **AC-1.1**: WHEN [trigger/condition] THEN [expected outcome]
- **AC-1.2**: WHEN [invalid input] THEN [graceful error with message]

### AC-2: [Category name]

- **AC-2.1**: WHEN [trigger/condition] THEN [expected outcome]
- **AC-2.2**: WHEN [edge case] THEN [expected behavior]

<!-- For a CLI-heavy spec, add a Subcommand Surface section here with CLI signatures
     and exit codes. -->

## Out of Scope

<!-- Explicit boundaries prevent scope creep. Record the decision that drew each
     boundary in the Decision Log below, not just the boundary itself. -->

- Not handling: [X]
- Deferred to later: [Y]

## Open Questions

<!-- Decisions still needed before this spec moves to design. As each resolves, move
     the decision to the Decision Log below with a one-line rationale, and the
     discussion that settled it to requirements-feedback.md. This section must be
     empty before `/spec:design` runs. When there is nothing open, write "None" as
     plain text — never an empty `- [ ]` item or checkbox list. -->

None

## Decision Log

<!-- Decisions reached while drafting, before any feedback thread existed. A decision
     that grew out of a feedback thread stays in that thread; only its outcome is
     summarized here. -->

| # | Decision | Reasoning |
|---|----------|-----------|
| D-1 | [decision] | [one-line rationale] |

## Glossary

<!-- Definitions for terms used throughout the Acceptance Criteria.
     Implementers should treat these as authoritative. -->

| Term | Definition |
|------|------------|
| **[Term]** | [Definition] |
