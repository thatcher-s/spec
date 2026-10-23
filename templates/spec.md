# <Title> (express)

<!-- This is an express spec: one file, about 60 to 150 lines, for a small, single-approach
     change. It skips the full requirements.md / design.md / tasks.md flow and its optional
     validate pass. Upgrade to the full flow — seed requirements.md from Problem and
     Acceptance Criteria (same AC numbers), seed the Decision Log from Decisions, then
     continue at `/spec:design` — if, while drafting or implementing, the change turns out
     to have more than one sensible approach, a new interface contract or a new dependency,
     an open question one review round can't settle, or touches anything on the project's
     always-full-spec list. -->

## Problem

<!-- 2 to 5 sentences: why this needs to exist, what breaks without it. -->

## Acceptance Criteria

<!-- Full AC-N.M format, same as requirements.md, so an upgrade to the full flow keeps
     the numbers. Group related criteria under one AC-N; use WHEN/THEN within each. -->

- **AC-1.1**: WHEN [trigger/condition] THEN [expected outcome]
- **AC-1.2**: WHEN [invalid input] THEN [graceful error with message]

## Approach

<!-- One paragraph. End with the rejected alternative in one line: "Rejected: [X] —
     because [reason]." -->

## Affected Files

<!-- Every file this change touches. If it grows past what fits in one short table,
     that is itself a signal to upgrade to the full flow. -->

| File | Change |
|------|--------|
| `src/...` | What changes |

## Tasks

<!-- Test-first checklist: a test sub-step before the implementation sub-step it
     verifies, not a separate testing phase at the end. -->

- [ ] 1. Write tests for [behavior] (AC-1.1)
- [ ] 2. Run tests — confirm RED
- [ ] 3. Implement [behavior]
- [ ] 4. Run tests — confirm GREEN

## Decisions

<!-- One line each, same shape as a Decision Log row: D-1 [decision] — [one-line
     rationale]. Only decisions made while drafting; feedback threads stay in
     spec-feedback.md. -->

- D-1: [decision] — [one-line rationale]

## Out of Scope

<!-- Explicit boundaries prevent scope creep. If a boundary needs its own rationale,
     record it as a Decision above rather than only stating it here. -->

- Not handling: [X]
- Deferred to later: [Y]
