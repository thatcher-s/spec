---
name: reqs
description: "Start a spec: issue, worktree, and the requirements draft. Suggests express when the change is small."
argument-hint: "[description or #issue]"
disable-model-invocation: true
---

# Requirements

## Model gate (mandatory, before anything else)

This skill requires **Opus or Fable**. Before reading any file or calling any tool, check the
model ID you are running as. If it is **a Sonnet or Haiku model**, do not start the skill, not even
partly: print exactly the two lines below and end your turn.

```
/spec:reqs needs Opus or Fable; this session is running <your model ID>.
Next: /model fable (or /model opus), then run /spec:reqs again.
```

This is not a recommendation. A request to proceed anyway does not lift it; only switching
the session's model does.

Start a full spec: link or create the issue, open the spec's worktree, and draft
`requirements.md` with its empty feedback file. This skill creates the spec folder, so it
does not run the preamble's folder resolution or gate; it reads the project's context
once the worktree exists.

Conventions for sessions, Decision Log entries, feedback files and git are in
`${CLAUDE_PLUGIN_ROOT}/shared/conventions.md`. Read it before drafting.

**Templates.** For every template named below, use `specs/.templates/<name>.md` when the
project has one, otherwise `${CLAUDE_PLUGIN_ROOT}/templates/<name>.md`.

## 1. Understand the request

The argument is a description of the change or an issue reference (`#42`, `PROJ-123`;
forms in `shared/issues.md`). With
neither, summarize what the user has said in this session and propose a short title; if
there is nothing to go on, ask for a description.

**Upgrading an express spec.** If the argument resolves to an existing spec folder that
holds `spec.md`, this is an upgrade to the full flow: enter that folder's worktree (as in
preamble step 2), seed `requirements.md` from `spec.md` (Problem becomes the Problem
Statement, Acceptance Criteria keep their exact numbers, Decisions become Decision Log
rows with their `D-n` numbers), complete the remaining sections as in step 5, write
`requirements-feedback.md`, and finish with step 6. Leave `spec.md` in place.

## 2. Link or create the issue

Read the config's `## Issue tracker` section from the current checkout (GitHub when
absent), then follow `${CLAUDE_PLUGIN_ROOT}/shared/issues.md` § Link or create.

## 3. Create the worktree and the spec folder

- **Folder name:** `<issue prefix>-<short-desc>` (`gh-42-csv-export`, `proj-123-csv-export`)
  with an issue, `<short-desc>` without one; the prefix comes from `shared/issues.md`.
  `<short-desc>` is two to four lowercase hyphenated words.
- **Worktree name:** the folder name. When `specs/.config.md` lists sub-projects and the
  change belongs to one, prefix it: `<sub-project>-<folder>`. Ask if the sub-project is
  unclear.
- Call `EnterWorktree(name: "<worktree name>")`. Every path from here on is relative to
  the worktree root.
- `mkdir -p specs/<folder>` at the worktree root (also for a sub-project spec).

Then run preamble step 3 only (`${CLAUDE_PLUGIN_ROOT}/shared/preamble.md`): read
`specs/.config.md` and the project CLAUDE.md, plus the sub-project's CLAUDE.md when one
applies. There is no earlier phase to gate on.

## 4. Suggest express when the change is small

Before drafting, check the change against the express limits. Express is the wrong tool
when the change has any of:

- more than one sensible approach
- a new interface contract or a new dependency
- open questions that one review round can't settle
- anything on the config's Always full spec list

Explore the code the change touches enough to judge this honestly. If any limit trips,
continue with the full spec without asking. If none trips **and** the change looks small
(a handful of files, one obvious approach), ask once with AskUserQuestion whether to
switch to express, naming the reason it qualifies.

If the user chooses express, do not send them to `/spec:express`: the issue, worktree and
folder already exist. Read `${CLAUDE_PLUGIN_ROOT}/skills/express/SKILL.md` and continue in
this session from its drafting step through its commit and Next line. Record the switch
as `D-1` in `spec.md`'s Decisions.

## 5. Draft `requirements.md`

Draft from the `requirements` template, informed by the request, the issue body, the
codebase, and the config's Product doc. When the project has a product doc, cite the
section a requirement comes from (`§3`, `docs/product.md § Imports`) instead of restating
it.

Content each section needs:

- **Reading-order callout** at the top: a short block telling an implementer which files
  to read in which order (requirements, design, tasks, the feedback files).
- **Problem Statement:** why this needs to exist, in the user's terms.
- **User Stories:** who benefits and how.
- **Acceptance Criteria:** numbered `AC-N.M`, never free-form bullets, grouped by category
  (`AC-1` heading, then `AC-1.1`, `AC-1.2`, …). Aim for at least three groups of two or
  more. Each criterion is testable and observable. The numbers are stable: design and tasks
  cite them, and they are never renumbered after this draft is reviewed.
- **Out of Scope:** explicit boundaries, at least two, each with a one-line reason.
- **Open Questions:** must be empty before tasks are written. Resolve real decisions now
  with AskUserQuestion rather than leaving them open. When none remain, write `None.` as
  plain text, never as a checkbox. A question the user genuinely wants to settle in review
  goes in `requirements-feedback.md` as a thread instead.
- **Decision Log:** a table of `D-n` rows, one line of rationale each. Every choice made
  while drafting goes here: AskUserQuestion answers, an interpretation of an ambiguous
  request, a scope cut, the express check's outcome when it was close.
- **Glossary:** every domain-specific term the criteria use, at least five where the
  domain allows, so implementers share one vocabulary.

Write it to `specs/<folder>/requirements.md`. Then write
`specs/<folder>/requirements-feedback.md` from the `requirements-feedback` template: the
same section headings as `requirements.md`, no threads.

## 6. Hand off

Do not iterate on the draft in this session; review happens through the feedback file
and `/spec:feedback`. If the user makes a small correction in chat before the session
ends, apply it to `requirements.md` and log it as a `D-n` row.

Tell the user, briefly, with every file as an absolute path (conventions.md, Paths shown
to the user):

- the issue (number and URL, or none), the worktree path and branch, and the folder
- that the requirements draft is ready at `specs/<folder>/requirements.md`
- that feedback goes in `specs/<folder>/requirements-feedback.md` as `- [ ]` items under
  the heading each concerns
- the Decision Log entries made while drafting, one line each

End with the Next line, choosing by whether the user has feedback:

```
Next: /clear, then /spec:feedback requirements <folder>      (feedback written)
Next: /clear, then /spec:design <folder>            (no feedback)
```
