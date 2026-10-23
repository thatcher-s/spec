---
name: implement
description: Implement the spec phase by phase through subagents, then open the PR.
argument-hint: "[spec folder] [phase]"
disable-model-invocation: true
---

# /spec:implement

## Model gate (mandatory, before anything else)

This skill requires **Opus or Fable**. Before reading any file or calling any tool, check the
model ID you are running as. If it is **a Sonnet or Haiku model**, do not start the skill, not even
partly: print exactly the two lines below and end your turn.

```
/spec:implement needs Opus or Fable; this session is running <your model ID>.
Next: /model fable (or /model opus), then run /spec:implement again.
```

This is not a recommendation. A request to proceed anyway does not lift it; only switching
the session's model does.

Turn an approved spec into code, phase by phase. This session reads, briefs, reviews and
decides; subagents write the code. The skill ends with an open pull request, never a merge.

## 0. Setup

Read `${CLAUDE_PLUGIN_ROOT}/shared/preamble.md` and `${CLAUDE_PLUGIN_ROOT}/shared/conventions.md`,
then run the preamble. The argument is an optional spec folder followed by an optional phase
(`2` or `Phase 2`); a lone number that matches no spec folder is a phase.

**Express or full.** The spec is express when the folder holds `spec.md`.

**Gate** (preamble step 4). Open items in any of these block the run:

| Spec | Feedback files checked |
|---|---|
| Full | `requirements-feedback.md`, `design-feedback.md`, `validation-feedback.md` (if present), `tasks-feedback.md` |
| Express | `spec-feedback.md` |

## 1. Load the spec

- **Full:** read `requirements.md` (Acceptance Criteria, Glossary, Decision Log),
  `design.md` and `tasks.md`. Read `tasks.md` § Start Here and § Implementation Setup
  closely: they hold the reading order, the real commands, the commit cadence and the
  Parallelism Cheat Sheet.
- **Express:** read `spec.md`; its Tasks section is the task list and its checkboxes are
  the ones you check.

Take the test and lint commands from § Implementation Setup. If it lacks them, read them
from the project's CLAUDE.md, justfile or package manifest. Run the test command once
before any change: a red baseline is reported to the user before work starts, not
discovered later.

**Scope.** With a phase argument, do only that phase. Without one, start at the phase of
the first unchecked task and continue through the last phase.

## 2. Delegation

| Who | Takes |
|---|---|
| This session | Reading, decisions, briefs, diff review, checking tasks off; any task in an area the config's `## Always full spec` lists; any task that changes `design.md` |
| Sonnet subagent | Mechanical work a precise brief fully describes: moves, fixtures, tests for decided behavior, docs from a draft in the design |
| Opus subagent | Judgment inside the known design: a module from its interface and algorithm, UI iteration, a non-trivial refactor |
| The user | Tasks the task text assigns to the user (manual verification on a device, a signing step, an account action) |

When the task text names a model, follow it.

**Parallel tasks.** `[P]` tasks in the same phase launch together, in one message with one
Agent call each. Before launching, compare their file lists (the Parallelism Cheat Sheet,
each task's Files): two tasks that touch the same file run one after the other, whatever
their tags. Subagents work in this session's worktree; never give one a second worktree.

**Every brief contains:**

1. The task's title and number, and the spec folder's absolute path.
2. Its acceptance criteria, quoted from `requirements.md` or `spec.md`, and the
   `design.md` sections to read (interfaces, worked examples, error-message table).
3. The files it may create or change, as absolute paths, and a line saying not to touch
   any other.
4. The test-first steps from the task: write the failing test, run it and see it fail,
   implement, run it and see it pass.
5. The project's real test and lint commands, quoted, and the instruction to run both
   before reporting.
6. The project conventions that apply (CLAUDE.md: logging, docstrings, spelling, spec
   references qualified with the issue id outside the spec folder).
7. What to report: files changed, tests added, command results, anything the spec did
   not decide.
8. That it must not commit, push or edit spec files.

A subagent that hits a design question stops and reports it; it does not decide. The
session decides, records the decision (§4), and re-briefs.

**User tasks.** Stop at the task, say what the user needs to do and why, and wait with
AskUserQuestion. Check it off only when the user confirms it passed. If the user is not
available now, commit what is done and end with the phase's Next line (§5).

## 3. Review before checking off

For each finished task, this session:

1. Reads the diff (`git diff` and new files), not just the subagent's report.
2. Checks it against the task's acceptance criteria, the design's interfaces and error
   messages, and the files the brief allowed.
3. Runs the task's tests.
4. Sends back anything wrong with a precise correction, or fixes a small slip directly.
5. Checks the task's box in `tasks.md` (`spec.md` for express) and commits per the
   cadence in § Implementation Setup (default: one commit per task), checking the branch
   in the same command as the commit.

## 4. When the design changes

Implementation can show the design was wrong or incomplete. When it does, the session
decides (asking the user with AskUserQuestion when the change alters behavior or an
acceptance criterion), then:

- updates the affected `design.md` section (or `spec.md` Approach for express) so the
  document describes the code that exists;
- adds a Decision Log row (`D-n`) with the reason;
- notes it for the summary's Deviations.

Never let the code and the design drift apart silently.

## 5. End of each phase

Run the project's full test and lint commands, not only the tests a task touched. Both
must pass before the next phase starts; a failure is fixed (or delegated with a brief)
first. Commit anything left from the phase.

If this was the requested phase, or the run stopped on a user task, end with:

```
Next: /clear, then /spec:implement <folder> <next phase>
```

## 6. After the last phase

**Summary report**, printed for the user:

```markdown
**Implementation summary**: <absolute path to specs/<folder>/>

**Changes**
- `<file>`: <what changed>

**Acceptance criteria coverage**
| AC | Status | Evidence |
|----|--------|----------|
| AC-1.1 | Met / Partially met / Not met | <test name or file:line> |

**Deviations from the spec**: <each, with its D-n>, or none.
```

Every acceptance criterion gets a row. A Partially met or Not met row is raised with the
user before the PR opens.

**Project steps before the PR.** Do what the config's `## Issues and PRs` section and the
project's CLAUDE.md require of a PR (release notes, changelog fragments, docs on delivery),
and commit them.

**Push and open the PR.**

```bash
git branch --show-current
git push -u origin <branch>
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<what the change does and why, in a few bullets>

## Acceptance criteria
<the coverage table>

## Deviations
<from the summary, or none>

## Spec
`specs/<folder>/`

<the tracker's PR link line, if any>
EOF
)"
```

Follow the project's PR conventions for the title and body (for example, when the PR is
squash-merged, the title and body become the commit). Spec references in the PR text are
qualified with the folder's issue prefix (`gh-42 AC-1.2`, `proj-123 AC-1.2`). The PR is
linked to the issue as `${CLAUDE_PLUGIN_ROOT}/shared/issues.md` says: a `Closes #42` line
for GitHub, a `PROJ-123: ` title prefix for Jira. Then make any board moves the config names
for an opened PR.

**Never merge the pull request.** Merging is the user's action.

## 7. End

Print the PR URL, then:

```
Next: /clear, then /spec:review-security <PR#>
```

and say that `/spec:review-code <PR#>` follows it in its own fresh session.
