---
name: init
description: "Set up a project for the spec plugin: draft specs/.config.md from the codebase, confirm the judgment calls, and open a PR."
argument-hint: "[notes about the project]"
disable-model-invocation: true
---

# Initialize a project

## Model gate (mandatory, before anything else)

This skill requires **Opus or Fable**. Before reading any file or calling any tool, check the
model ID you are running as. If it is **a Sonnet or Haiku model**, do not start the skill, not even
partly: print exactly the two lines below and end your turn.

```
/spec:init needs Opus or Fable; this session is running <your model ID>.
Next: /model fable (or /model opus), then run /spec:init again.
```

This is not a recommendation. A request to proceed anyway does not lift it; only switching
the session's model does.

Draft `specs/.config.md` for this repository by reading it, ask the user only what the
code cannot answer, and deliver the file as a pull request. Read
`${CLAUDE_PLUGIN_ROOT}/shared/conventions.md` and `${CLAUDE_PLUGIN_ROOT}/shared/config.md`
(the sections, their meaning and their defaults) and `${CLAUDE_PLUGIN_ROOT}/shared/issues.md`
first.

## 1. Check the starting point

- Run from the repository root (`git rev-parse --show-toplevel`). If `specs/.config.md`
  already exists, show it and ask with AskUserQuestion whether to revise it or stop. A
  revision keeps every line the user wrote unless the code now contradicts it, and says
  which lines changed and why.
- Note any `specs/.templates/*.md`: they override the plugin's templates. Report them; do
  not change them.

## 2. Read the project

Read, in this order, and stop reading a source once it has answered what it can:

1. `CLAUDE.md` (root and any nested ones), `README.md`, `CONTRIBUTING.md`.
2. `docs/` index pages, and any page CLAUDE.md or the README calls the design, product,
   architecture, status, decisions (ADRs) or security document.
3. The task runner and manifests: `justfile`, `Makefile`, `package.json`,
   `pyproject.toml`, `Cargo.toml`, `go.mod`, `.pre-commit-config.yaml`, CI workflows.
4. The docs-site config, if any: `zensical.toml`, `mkdocs.yml`, `docusaurus.config.*`,
   `conf.py`. Check whether it renders anything under `specs/`.
5. `git remote -v`, and `gh repo view --json nameWithOwner,hasIssuesEnabled`.
6. Existing `specs/*/` folders, if any, for how past specs were named and linked.

Use the notes in the argument, if given, as extra facts from the user.

## 3. Draft each section

For each section in `shared/config.md`, write a value only when the repository supports
it, and keep a one-line reason for each (shown to the user in step 4, not written to the
file). Leave out a section whose default is right.

| Section | How to decide |
|---|---|
| Issue tracker | `GitHub` when the remote is GitHub with issues enabled and past specs or CLAUDE.md use issue numbers. `Jira <KEY>` only when CLAUDE.md, the README, branch names or past spec folders show Jira keys; confirm the key with the user. `None` when nothing tracks issues. |
| Product doc | A product or design document CLAUDE.md or the README tells readers to consult before designing. Not the README itself. |
| Docs on delivery | README.md and CLAUDE.md, plus pages the project's own rules say to update with each change (status, changelog-adjacent docs, ADR logs, rule or contract pages). Say what each is for in a few words. |
| Security register | A document recording known security limits or threat decisions, when one exists. |
| Always full spec | Candidates only; the user picks in step 4. Draw them from what CLAUDE.md marks as load-bearing, architectural rules, security-sensitive paths (credentials, auth, external writes, data migrations), public contracts and file formats, and new dependencies when the project records them as decisions. |
| Sub-projects | Only when the repository holds several independently built projects, each with its own manifest or CLAUDE.md. |
| After the spec commit | Steps needed for specs to appear wherever the project publishes them (a docs-site nav entry, symlinks, an index page), as exact commands. Omit when specs are just files in the repo. |
| Issues and PRs | Rules the project states for issues and PRs: a project board and its fields, labels, milestones, changelog or release fragments, merge style, who merges. Always include "Never merge a PR; merging is the operator's action." |

Never invent a path: every file named in the draft exists. Never copy a rule the
project's CLAUDE.md already states in full; point to it in a few words instead.

## 4. Confirm with the user

Show the full draft with each section's one-line reason, then ask with AskUserQuestion:

1. **Always full spec** (multi-select): each candidate area as an option, with what makes
   it risky in the description. The user may add others in their reply.
2. **Anything uncertain** from step 3, one question each, at most three: the Jira key, a
   product doc between two candidates, whether a docs-site step is wanted.

Apply the answers. If the user edits the draft in chat, apply the edits.

## 5. Deliver as a pull request

1. Create a branch from the default branch: `git switch -c spec-config` (or
   `spec-config-2` if it exists).
2. Write `specs/.config.md`, starting with:

   ```markdown
   # Spec config

   Read by the `spec` Claude Code plugin (`/spec:*`). Sections and defaults:
   https://github.com/thatcher-s/spec/blob/main/shared/config.md
   ```

3. Commit it alone, checking the branch in the same command:

   ```bash
   test "$(git branch --show-current)" = "spec-config" && git add specs/.config.md && git commit -m "chore: configure the spec plugin"
   ```

   Follow the project's commit conventions from its CLAUDE.md for the message and
   trailers, and add whatever the project requires of a PR (a release fragment only if
   the project requires one for non-shipping changes).
4. Push with `-u` and open the PR with `gh pr create`: the title is the commit subject;
   the body lists each section and the reason for its value. Never merge it.

## 6. End

Print the PR URL and the absolute path of the drafted file, then:

```
Next: merge the PR, then /spec:reqs <description or issue> (or /spec:express for a small change)
```
