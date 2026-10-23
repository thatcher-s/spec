---
name: express
description: "One-file spec for a small change: problem, criteria, approach, files, tasks."
argument-hint: "[description or #issue]"
disable-model-invocation: true
---

# Express spec

## Model gate (mandatory, before anything else)

This skill requires **Opus or Fable**. Before reading any file or calling any tool, check the
model ID you are running as. If it is **a Sonnet or Haiku model**, do not start the skill, not even
partly: print exactly the two lines below and end your turn.

```
/spec:express needs Opus or Fable; this session is running <your model ID>.
Next: /model fable (or /model opus), then run /spec:express again.
```

This is not a recommendation. A request to proceed anyway does not lift it; only switching
the session's model does.

Write a one-file spec (`spec.md`) for a small change, with one review stop before
`/spec:implement`. This skill creates the spec folder, so it does not run the preamble's
folder resolution or gate.

Conventions for sessions, decisions, feedback files and git are in
`${CLAUDE_PLUGIN_ROOT}/shared/conventions.md`. Read it before drafting.

**Templates.** For every template named below, use `specs/.templates/<name>.md` when the
project has one, otherwise `${CLAUDE_PLUGIN_ROOT}/templates/<name>.md`.

If this skill was entered from `/spec:reqs` after the user chose express, the issue,
worktree and folder already exist: start at step 4.

## 1. Understand the request

The argument is a description of the change or an issue reference (`#42`, `PROJ-123`;
forms in `${CLAUDE_PLUGIN_ROOT}/shared/issues.md`). With
neither, summarize what the user has said in this session; if there is nothing to go on,
ask for a description. For an issue reference, read it as `shared/issues.md` says for the project's tracker.

## 2. Check the express limits first

Check before creating anything, so a refusal leaves no issue or worktree behind. Read
`specs/.config.md` (if present) and the project CLAUDE.md from the current checkout, and
explore the code the change touches enough to judge.

Express is the wrong tool when the change has any of:

- more than one sensible approach
- a new interface contract or a new dependency
- open questions that one review round can't settle
- anything on the config's Always full spec list

If any limit trips, refuse. Name the limit and the evidence in one or two lines, then:

```
Next: /spec:reqs <#issue or the description>
```

## 3. Link or create the issue, then the worktree

Read the config's `## Issue tracker` section (GitHub when absent), then follow
`${CLAUDE_PLUGIN_ROOT}/shared/issues.md` § Link or create.

Folder name: `<issue prefix>-<short-desc>` (prefix from `shared/issues.md`) with an issue, `<short-desc>` without one (two to four
lowercase hyphenated words). Worktree name: the folder name, prefixed
`<sub-project>-<folder>` when the config lists sub-projects and the change belongs to one.

Call `EnterWorktree(name: "<worktree name>")`, then `mkdir -p specs/<folder>` at the
worktree root. Run preamble step 3 only (`${CLAUDE_PLUGIN_ROOT}/shared/preamble.md`)
inside the worktree; there is no earlier phase to gate on.

## 4. Draft `spec.md`

Draft from the `spec` template. One file, about 60 to 150 lines:

- **Title:** `# <Title> (express)`.
- **Problem:** two to five sentences. Cite the config's Product doc section when the
  change implements part of it.
- **Acceptance Criteria:** the full `AC-N.M` format, grouped (`AC-1` then `AC-1.1`, …),
  each testable. The numbers are stable: if the spec is upgraded to the full flow, they
  carry into `requirements.md` unchanged.
- **Approach:** one paragraph, plus the rejected alternative in one line.
- **Affected Files:** a `file | change` table. Include a docs row when user-facing
  behavior, commands, config or workflows change, considering the config's Docs on
  delivery list (default `README.md` and `CLAUDE.md`).
- **Tasks:** a test-first checklist (`- [ ]` items): write the failing test, see it fail,
  implement, see it pass. Cite AC numbers in each task. Use the project's real commands
  from its CLAUDE.md, justfile or manifest.
- **Decisions:** `D-1`, `D-2`, … one line each. Every choice made while drafting goes
  here: AskUserQuestion answers, interpretations of an ambiguous request, scope cuts.
- **Out of Scope:** explicit boundaries.

There is no Open Questions section: settle questions now with AskUserQuestion and log the
answer as a decision. A question the user wants to settle in review goes in
`spec-feedback.md` as a thread.

Write `specs/<folder>/spec.md`, then `specs/<folder>/spec-feedback.md` from the
`spec-feedback` template: the same section headings as `spec.md`, no threads.

Do not iterate on the draft in this session; review happens through the feedback file and
`/spec:feedback`. A small correction the user makes in chat before the session ends is
applied to `spec.md` and logged as a decision.

## 5. Commit the spec

1. Run the config's After the spec commit steps, if any, now, so the files they produce
   go into the same commit. Substitute `<folder>` where they name it, and check that each
   step succeeded.
2. Commit from the worktree root, checking the branch in the same command:

   ```bash
   test "$(git branch --show-current)" = "<worktree branch>" && git add specs/<folder>/ <files from the after-commit steps> && git commit -m "spec: <short-desc> <issue suffix>"
   ```

   The suffix is the tracker's (`shared/issues.md`); drop it when there is no issue. Add any project docs the spec itself changed.
   Follow the project's commit-message conventions from its CLAUDE.md for the message
   body and trailers.

## 6. Hand off

Tell the user, briefly, with every file as an absolute path (conventions.md, Paths shown
to the user): the issue, the worktree path and branch, the commit, that
`specs/<folder>/spec.md` is ready, that feedback goes in `specs/<folder>/spec-feedback.md`
as `- [ ]` items under the heading each concerns, and the decisions made while drafting.

End with the Next line, choosing by whether the user has feedback:

```
Next: /clear, then /spec:feedback spec <folder>           (feedback written)
Next: /clear, then /spec:implement <folder>      (no feedback)
```
