---
name: tasks
description: "Break the approved design into phased, test-first tasks with parallel-safe tags."
argument-hint: "[spec folder]"
disable-model-invocation: true
---

# Tasks

## Model gate (mandatory, before anything else)

This skill requires **Opus or Fable**. Before reading any file or calling any tool, check the
model ID you are running as. If it is **a Sonnet or Haiku model**, do not start the skill, not even
partly: print exactly the two lines below and end your turn.

```
/spec:tasks needs Opus or Fable; this session is running <your model ID>.
Next: /model fable (or /model opus), then run /spec:tasks again.
```

This is not a recommendation. A request to proceed anyway does not lift it; only switching
the session's model does.

Read and follow `${CLAUDE_PLUGIN_ROOT}/shared/preamble.md` and
`${CLAUDE_PLUGIN_ROOT}/shared/conventions.md`. The preamble's gate for this skill:

| Skill | Checks |
|---|---|
| `tasks` | requirements, design, validation (if present) |

**Templates.** For every template named below, use `specs/.templates/<name>.md` when the
project has one, otherwise `${CLAUDE_PLUGIN_ROOT}/templates/<name>.md`.

## 1. Read

- `specs/<folder>/requirements.md` and `design.md` in full; `validation.md` if present.
- The project's real commands: its CLAUDE.md, task runner (justfile, Makefile, package
  scripts), package manifest, and hook config. Note the exact commands for setup, lint,
  format, type check and tests.
- The test layout and an existing test or two in the area the design touches, so the
  tasks follow its patterns.

## 2. Draft `tasks.md`

Draft from the `tasks` template. Content each section needs:

- **Start Here:** five or six numbered steps giving a fresh implementer the reading order
  (which spec files and sections, which source files) before touching code.
- **Implementation Setup:** prerequisites, branch cadence (the spec's worktree branch is
  already in use; cadence means a commit per task or per phase), test layout, a crib sheet
  of existing patterns to copy, and codebase conventions. Quote the commands found in step
  1 verbatim; never a remembered or generic stack.
- **Phased tasks**, ordered by dependency, each completable in one sitting. Every task
  title cites the criteria it implements, e.g. `### Task 2.1: Parse the config (AC-1.1,
  AC-1.2) [P]`. Each task names the files it touches and the design section it builds.
- **`[P]` tags** on every task safe for a parallel subagent. Within one phase, `[P]` tasks
  never touch the same file. Aim for at least three across the spec; when the work is
  truly serial, say so in the cheat sheet.
- **Test-first sub-steps** in every task that changes behavior: 1. write the tests (from
  Appendix A examples and Appendix B messages where they apply), 2. run them and see RED,
  3. implement, 4. run them and see GREEN. Name the test file and the command.
- **Definition of Done:** quantified. A coverage target if the project has a coverage
  tool, or an explicit statement that it has none; the specific modules delivered; the
  specific docs updated (from design's Affected Modules); every AC covered by a named test;
  lint, type check and tests passing with the quoted commands.
- **Parallelism Cheat Sheet:** the last section, a table with Phase, Parallel tasks, Max
  concurrency and Notes columns.

Every AC is cited by at least one task. Every file in design's Affected Modules appears in
at least one task.

Write `specs/<folder>/tasks.md`, then `specs/<folder>/tasks-feedback.md` from the
`tasks-feedback` template: the same section headings as `tasks.md`, no threads.

## 3. Record decisions

Every choice made while drafting (phase boundaries drawn between real options, a task
split or merge, an AskUserQuestion answer) gets a `D-n` row continuing the numbering in
the Decision Log of `requirements.md`, unless the tasks template carries its own Decision
Log section, in which case log it there. One line of rationale each.

Do not iterate on the draft in this session; review happens through the feedback file and
`/spec:feedback`. A small correction the user makes in chat before the session ends is
applied directly and logged.

## 4. Commit the spec

1. Run the config's After the spec commit steps, if any, now, so the files they produce
   go into the same commit. Substitute `<folder>` where they name it, and check that each
   step succeeded.
2. Commit from the worktree root, checking the branch in the same command:

   ```bash
   test "$(git branch --show-current)" = "<worktree branch>" && git add specs/<folder>/ <files from the after-commit steps> <project docs the spec changed> && git commit -m "spec: <short-desc> <issue suffix>"
   ```

   The commit carries the whole spec folder: requirements, design, tasks, validation if
   present, and every feedback file. The suffix is the tracker's (`${CLAUDE_PLUGIN_ROOT}/shared/issues.md`); drop it when
   there is no issue. Follow the
   project's commit-message conventions from its CLAUDE.md for the body and trailers.

## 5. Hand off

Tell the user, briefly, with every file as an absolute path (conventions.md, Paths shown
to the user): the commit, that `specs/<folder>/tasks.md` is
ready, to look closest at phase order and the `[P]` tags, that feedback goes in
`specs/<folder>/tasks-feedback.md` as `- [ ]` items under the heading each concerns, and
the decisions logged while drafting.

End with the Next line:

```
Next: /clear, then /spec:feedback tasks <folder>  (feedback written)
Next: /clear, then /spec:audit <folder>           (no feedback)
```
