# Tasks: <Feature Name>

## Start Here (for implementers)

If you are a fresh session picking up this spec, read in this order:

1. **`requirements.md` -> "Acceptance Criteria" + "Glossary"** — the contract. Every
   behavior is anchored to an AC number.
2. **`design.md` -> "Key Interfaces / Contracts"** — signatures and data shapes. Copy
   these verbatim.
3. **`design.md` -> "Appendix A: Worked Examples"** — exact artifact shapes. Use as
   test fixture seeds.
4. **`design.md` -> "Appendix B: Error Message Reference"** — exact text for every
   operator-facing message.
5. **`design.md` -> "Affected Modules"** — canonical file list. If you're modifying a
   file not in that table, stop and check the design.
6. **This file** — phased tasks. Within each task, follow the test-first sub-steps.

**Picking up mid-spec**: tasks marked `[P]` are safe to assign to independent
subagents. Check the Parallelism Cheat Sheet at the bottom before claiming a task.

## Implementation Setup

### Prerequisites — run once before starting Phase 0

<!-- Quote the project's real commands from its CLAUDE.md, justfile, package manifest
     and pre-commit config at the time of writing — don't paste a remembered version.
     Shape: -->

```bash
# Example only — confirm every line against the project's own toolchain files
<install/sync dependencies>
<run the test suite; confirm it is currently green>
<run lint and type-check>
<install any pre-commit/pre-push hooks, once per clone>
```

### Branch + commit cadence

<!-- Specify: stay on current branch or create new? Commit per phase or per task? PR
     strategy? -->

### Test layout

<!-- Where do tests go for each module type? Reference existing test directories. -->

### Existing-pattern crib sheet

<!-- Table of patterns implementers should reuse instead of inventing: -->

| Pattern | Reference file | Notes |
|---------|----------------|-------|
| [pattern] | `src/...` | [when to use] |

### Codebase conventions

<!-- Non-obvious rules that implementers must follow. Include anything that a fresh
     session would get wrong without being told — logging, linting, import style,
     test isolation, etc. Pull from the project's own CLAUDE.md (if any) and add any
     spec-specific constraints. Shape to adapt (fill in with the project's actual
     conventions, not these labels):

     - **Logging**: [convention, if any]
     - **Lint/format**: [the project's actual linter/formatter — check its config
       files rather than assuming]
     - **Errors**: [how errors are raised/surfaced in this project]
     - **Import/module style**: [convention, if any]
     - **Test isolation / mocking**: [where to patch, what not to mock]
     - **[spec-specific rule]**: [explanation]
-->

---

> **Parallelism tag `[P]`** marks tasks safe to assign to independent subagents.
> Tasks without `[P]` either depend on a prior task's output or touch a file that
> another task in the same phase also touches.
>
> **Test-first within each task**: every task that adds production code requires
> tests written first (RED), then implementation (GREEN).

## Phase 0: [Foundation / Setup]

### Task 0.1 [P] — [description] (AC-N.M, AC-N.M)

- [ ] 1. Write tests in `tests/<path>/test_<module>.*`
  - Test cases: [list derived from ACs]
  - Fixture seeds: design.md Appendix A.N
- [ ] 2. Run tests — confirm RED (all fail)
- [ ] 3. Implement `src/<path>/<module>.*`
  - Copy signatures from design.md Key Interfaces
  - Error messages from design.md Appendix B
- [ ] 4. Run tests — confirm GREEN

## Phase 1: [Core Implementation]

<!-- Continue with phased tasks. Each phase groups tasks by dependency. Mark
     parallelizable tasks with [P]. -->

## Phase N: Documentation

- [ ] Update the docs specs/.config.md's "Docs on delivery" section names, if
  user-facing behavior changed
- [ ] Update CLAUDE.md if architecture changed

## Definition of Done

<!-- Quantify against the project's actual test/lint tooling — don't assume a
     coverage tool or linter exists. If the project has neither (e.g. a docs-only
     folder), state what "done" means without them. -->

- [ ] All acceptance criteria from `requirements.md` (AC-1 through AC-N) verified
- [ ] Tests pass [the project's coverage bar, if it has one]
- [ ] No lint/typecheck errors on new or modified files [the project's actual commands]
- [ ] Relevant docs updated: [list specific docs]
- [ ] PR description references this spec at `specs/<folder-name>/`
- [ ] No silent behavior changes to existing functionality

## Parallelism Cheat Sheet

<!-- For a fleet of subagents executing in parallel, the natural fan-out is: -->

| Phase | Parallel tasks | Max concurrency | Notes |
|-------|----------------|-----------------|-------|
| Phase 0 | [task list] | **N** | [why these are safe] |
| Phase 1 | [task list] | **N** | [dependencies] |

**Maximum useful concurrency**: N subagents during Phase X.
