# Conventions shared by every spec skill

## Sessions and state

- Each skill runs in a fresh session and assumes nothing from earlier conversations.
  Everything it needs is in the spec folder, a feedback file, git, or a PR thread.
- Before a skill ends, everything it decided is on disk: in the document it drafted, its
  Decision Log, a feedback-file reply, a commit, or a PR comment. A decision that exists
  only in the conversation is lost when the session ends.
- Decisions made with the user while drafting (AskUserQuestion answers, corrections in
  chat) go in the document's Decision Log (`D-1`, `D-2`, …) with a one-line rationale.

## Paths shown to the user

Every local file path in output meant for the user (hand-offs, refusals, lists of open
threads, audit reports, summaries) is absolute: `/Users/me/repo/.claude/worktrees/gh-42-x/specs/gh-42-x/design.md`,
never `specs/gh-42-x/design.md`. Spec files live in a worktree until the branch merges, and
an editor resolves a relative path against its workspace root, which is the main checkout,
where the file does not exist yet. Get the root with `git rev-parse --show-toplevel` from
inside the worktree. Paths inside files (spec documents, commit messages, PR text,
`file:line` citations in GitHub comments) stay repository-relative.

## Ending a skill

The plugin's commands are exactly: `/spec:init`, `/spec:reqs`, `/spec:express`, `/spec:design`,
`/spec:validate`, `/spec:tasks`, `/spec:feedback`, `/spec:audit`, `/spec:implement`,
`/spec:review-security`, `/spec:review-code`. Never name any other `/spec:` command.

The full flow is `reqs` → `design` → (`validate`) → `tasks` → `audit` → `implement` →
`review-security` → `review-code`, with `feedback` wherever a feedback file or the PR
has open threads. Express is `express` → `implement`.

Every skill ends with one line naming the exact next command, for example:

```
Next: /clear, then /spec:design gh-42-csv-export
```

## Feedback files

A feedback file sits beside the document it reviews and repeats that document's section
headings. The user adds threads under the heading they concern:

```markdown
## Key Interfaces
- [ ] Why does `load_config` return a dict instead of a dataclass?
    - **Opus 5.5 (responder):** The caller merges it with defaults key by key ...
        - **Operator:** OK, but document that in the docstring.
```

- A thread is a top-level `- [ ]` item and everything indented under it.
- Reply by appending an indented bullet under the thread's last line.
- Check the item (`- [x]`) only when the thread is settled **and** the agreed edit is
  applied to the document.

## Responder label

Every reply Claude writes, in a feedback file or on GitHub, starts with
`**<model> <version> (responder):**`: the model family and version of the running
session, read from its model ID. `claude-opus-5-5` is `Opus 5.5`, `claude-sonnet-5` is
`Sonnet 5`, `claude-fable-5-1` is `Fable 5.1`. Never write a generic `Claude`.

## Spec references

Inside a spec folder, `AC-1.2` and `D-3` stay bare. Anywhere else (code, tests, commit
messages, PR text, other docs), qualify them with the folder's issue id
(`gh-42 AC-1.2`, `proj-123 AC-1.2`) or describe the behavior instead.

## Models

**Session gate, checked before anything else.** Each skill states its own gate at the top;
this is the rule behind it. Every spec skill except `audit` plans,
designs, writes spec files, reviews or decides, so the session must run Opus or Fable.
`audit` checks a spec against a fixed checklist and may also run on Sonnet. Read your own
model ID: if it is below the skill's minimum, stop before doing any work and print:

```
/spec:<skill> needs <Opus or Fable | Sonnet or above>; this session is running <model>.
Next: /model <a model that meets it>, then run /spec:<skill> again.
```

Never continue on Sonnet or Haiku, and never downgrade a Fable session to Opus.

**Subagents.** Work a skill fans out for judgment (validate's advocate, skeptic and judge)
inherits the session model. Only implementation is delegated to cheaper models: Sonnet for
mechanical work with a precise brief (moves, fixtures, tests for decided behavior, docs from
a draft), Opus for complex coding and judgment inside a known design. Spec files are never
written by a Sonnet subagent. A project's config may name areas the session keeps for
itself.

## Git

- Check the current branch in the same command as any commit; never commit to the
  default branch.
- Never merge a pull request. Opening one is the end of the workflow; merging is the
  user's action.
- Follow the project's commit-message and PR conventions from its CLAUDE.md and the
  config's Issues and PRs section.
