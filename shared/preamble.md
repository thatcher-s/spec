# Preamble: locate the spec and check earlier phases

Run these steps in order before the skill's own work. Stop and tell the user if any step
fails; never guess a folder or skip the gate.

## 1. Resolve the spec folder

The argument may be an issue id in the project's tracker form (`42`, `#42`, `gh-42`,
`PROJ-123`; see `${CLAUDE_PLUGIN_ROOT}/shared/issues.md`), a folder name
(`gh-42-csv-export`), or a path (`specs/gh-42-csv-export/`).

- Match it against `specs/*/` in the repository and in every worktree listed by
  `git worktree list`. An issue id matches the folder that starts with its prefix (`gh-42-`, `proj-123-`).
- With no argument: if the current directory is a worktree holding exactly one spec
  folder that is not on the main checkout's default branch, use it. Otherwise ask with
  AskUserQuestion, listing the candidate folders.
- Exactly one match is required. On several, list them and ask. On zero, say so; when
  the repository has no spec folders at all, a spec starts with `/spec:reqs` or
  `/spec:express`.

## 2. Enter the spec's worktree

Each spec lives in its own git worktree and branch, named after the folder.

- If the current directory is already that worktree, continue.
- Otherwise find its path in `git worktree list` (the branch name contains the folder
  name) and call `EnterWorktree(path: "<worktree path>")`. Every path from here on is
  relative to that worktree root.
- If no worktree exists for a folder that does exist on a branch, tell the user and stop:
  the spec was started outside this workflow.

## 3. Read the project's context

- `specs/.config.md`, if present. Its sections are described in
  `${CLAUDE_PLUGIN_ROOT}/shared/config.md`. When it is missing, say once that the
  project has no spec config, suggest `/spec:init` to create one, and continue with the
  defaults described there.
- The project's `CLAUDE.md` (root, and the sub-project's when the config lists
  sub-projects and the spec belongs to one).

## 4. Check earlier phases for open threads

Read every feedback file this skill's gate lists (the gate table is in the skill). An
open thread is any line matching `- [ ]` in a feedback file. If any exist, stop and print:

```
Open threads block <skill>:
  <absolute path to file>: <section heading> — <first line of the item, trimmed to 80 chars>
  ...
Next: /spec:feedback <phase>
```

Do not offer to continue anyway. Running the next phase is the user's approval of the
earlier ones, and an open thread means that approval isn't given yet.
