---
name: audit
description: "Structural check that the spec is ready to implement."
argument-hint: "[spec folder]"
disable-model-invocation: true
---

# Audit a spec folder

## Model gate (mandatory, before anything else)

This skill requires **Sonnet, Opus or Fable**. Before reading any file or calling any tool, check the
model ID you are running as. If it is **a Haiku model**, do not start the skill, not even
partly: print exactly the two lines below and end your turn.

```
/spec:audit needs Sonnet, Opus or Fable; this session is running <your model ID>.
Next: /model sonnet (or a stronger model), then run /spec:audit again.
```

This is not a recommendation. A request to proceed anyway does not lift it; only switching
the session's model does.

Scores a spec folder against criteria that predict whether a fresh session, given only
the folder, could implement it without asking a design question.

**It proposes, never fixes.** Audit writes each finding as a thread in the matching
feedback file and commits those files. It never edits `requirements.md`, `design.md`,
`tasks.md` or `spec.md`; the user answers each thread and `/spec:feedback` applies the
accepted fixes. It runs at any stop.

## 1. Locate the folder

Read `${CLAUDE_PLUGIN_ROOT}/shared/conventions.md` first.

Resolve the folder and enter its worktree as in `${CLAUDE_PLUGIN_ROOT}/shared/preamble.md`
steps 1 and 2. Skip the open-thread gate: audit reports open threads instead of refusing on
them. Read `specs/.config.md` (defaults in
`${CLAUDE_PLUGIN_ROOT}/shared/config.md` when absent), the project CLAUDE.md and its manifest
(`pyproject.toml`, `package.json`, justfile, `.pre-commit-config.yaml`, whichever exist)
for the toolchain criterion.

Read **every** `*-feedback.md` file in the folder. Each unchecked `- [ ]` item is a
blocking issue, listed with its file and section heading.

Pick the profile: **express** if the folder holds `spec.md`, otherwise **full**.

## 2. Full profile

Score each criterion 0 (missing), 0.5 (partial) or 1 (present), times its weight.

| File | Criterion | Weight | How to check |
|---|---|---|---|
| `requirements.md` | AC-N.M numbering | 3 | Every criterion uses `AC-N.M`, not free-form bullets |
| | AC coverage | 2 | At least 3 AC groups with 2+ criteria each |
| | Decision Log | 2 | `## Decision Log` with `D-N` rows |
| | Glossary | 2 | `## Glossary` with 5+ defined terms |
| | Open Questions empty | 3 | No unchecked item and no unanswered question under `## Open Questions` |
| | Out of Scope | 1 | At least 2 items |
| | Reading order | 1 | A callout at the top pointing to the reading order |
| `design.md` | Appendix A | 3 | 3+ worked examples, verbatim artifacts in code blocks |
| | Appendix B | 3 | Error-message table (trigger, destination, message, AC) |
| | Key Interfaces | 3 | Signatures with types, defaults and docstrings |
| | AC references in headings | 2 | At least 3 section headings cite ACs |
| | Affected Modules | 2 | Table of file, change, description; includes a docs entry when user-facing behavior, commands or config change (check the config's Docs on delivery, not an assumed file) |
| | Alternatives | 1 | 2+ alternatives, each with its rejection reason |
| `tasks.md` | `[P]` tags | 3 | At least 3 tasks tagged `[P]` |
| | AC references in task titles | 3 | Task titles cite ACs |
| | Start Here | 2 | `## Start Here` with a numbered reading order |
| | Implementation Setup | 2 | Prerequisites, branch cadence, test layout, conventions |
| | Test-first sub-steps | 2 | Numbered sub-steps, failing test before code |
| | Parallelism Cheat Sheet | 2 | Table of phase, parallel tasks, max concurrency |
| | Quantified Definition of Done | 2 | Coverage target (or an explicit no-coverage-tool statement), module and doc names |
| | Real toolchain | 1 | Commands match the project's actual toolchain, not a generic example |

**Max** is the sum of the weights in the table: compute it from the table and per file,
never from a remembered number.

A missing file scores 0 on all its criteria. At an earlier stop (before `tasks.md`
exists) that is expected; the report still says the folder is not ready.

**Blocking issues:**

- a missing `requirements.md`, `design.md` or `tasks.md`
- an open question in `requirements.md`
- no `AC-N.M` numbering
- no Appendix A or no Appendix B in `design.md`
- no `[P]` tags in `tasks.md`
- an unchecked `- [ ]` item in any feedback file

**Ready** means a score of at least 80% of the max and zero blocking issues.

Report:

```
**Spec audit: `<folder>`** (full profile)

**Score: X / <max> (Z%)**

| File | Score | Max | Missing / partial |
|---|---|---|---|
| requirements.md | … | … | criteria scoring below 1 |
| design.md | … | … | … |
| tasks.md | … | … | … |

**Ready:** Yes / No

**Blocking issues:**
- <issue>, with file and section

**Recommendations** (improve quality, not blocking):
- <item>
```

## 3. Express profile

Pass or fail per check, no score:

| Check | Pass when |
|---|---|
| Numbered criteria | `## Acceptance Criteria` uses `AC-N.M` throughout |
| Affected Files | `## Affected Files` present with file and change |
| Test-first tasks | `## Tasks` puts a failing test before each change |
| No open questions | No unchecked item or unanswered question anywhere in `spec.md` |
| No open feedback | No unchecked `- [ ]` item in `spec-feedback.md` |

**Ready** means every check passes. Report:

```
**Spec audit: `<folder>`** (express profile)

| Check | Result | Detail |
|---|---|---|
| … | Pass / Fail | what is missing, with section |

**Ready:** Yes / No
```

## 4. Write the findings as threads

Every finding becomes one thread in the feedback file of the document it concerns
(`requirements-feedback.md`, `design-feedback.md`, `tasks-feedback.md`, or
`spec-feedback.md` for express), under the heading it concerns: each blocking issue, and
each criterion scoring below 1 as a recommendation. Unchecked items already in feedback
files are reported, not rewritten. When the feedback file does not exist yet, create it from its
template (`specs/.templates/` first, then `${CLAUDE_PLUGIN_ROOT}/templates/`).

The thread's first line starts with your responder label, so `/spec:feedback` knows it is
a proposal waiting on the user:

```markdown
## Appendix B: Error Messages
- [ ] **Sonnet 5 (responder):** Audit: the table has no Destination column.
    - Proposed fix: add a Destination column (stderr, page or log) and fill it per row.
```

Start the finding with `Audit:`. Every proposed fix is concrete enough
to apply without another question; when it needs content only the user can supply, say
what is needed instead.

**Reruns.** Before writing, read the file's existing `Audit:` threads. Skip a finding
that already has one, open or checked: an open one is still waiting on the user, and a
checked one was answered, including a "no".

Commit the feedback files you changed, checking the branch in the same command:

```bash
test "$(git branch --show-current)" = "<spec branch>" && git add specs/<folder>/*-feedback.md && git commit -m "spec: audit findings for <folder>"
```

## 5. End

Audit runs in its own session so the spec is checked by a context that did not write
it. Report the score and list the threads written, each with the absolute path of its
feedback file. Then print the next command for where the folder stands:

- **Any open thread** (written now or before): `Next: reply to the threads in <absolute
  path of the first file>, then /clear and /spec:feedback <phase> <folder>`. A one-word
  "yes" or "no" under a finding is enough.
- **No open threads, with `tasks.md` (or express `spec.md`) present:**
  `Next: /clear, then /spec:implement <folder>`.
- **No open threads at an earlier stop:** the next phase in the flow for the latest document
  present (`/spec:design` or `/spec:tasks`, with the folder).

When the folder does not exist, print no score; say so, and end with
`Next: /spec:reqs <description or #issue>` (or `/spec:express` for a small change).
