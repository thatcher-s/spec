# Project config: `specs/.config.md`

A project describes what is specific to it in `specs/.config.md`, a Markdown file with
these sections. `/spec:init` drafts it from the codebase. Every section is optional. Facts the project already records elsewhere
(toolchain, commands, conventions) are read from its CLAUDE.md, justfile or package
manifest, not repeated here.

| Section | Meaning | Default when absent |
|---|---|---|
| `## Product doc` | Path of the product or design document the project implements. Requirements cite its sections instead of restating them. | None; requirements stand alone |
| `## Docs on delivery` | Files the design's Affected Modules must consider when user-facing behavior, commands, config or workflows change | `README.md` and `CLAUDE.md` |
| `## Security register` | Path of the project's record of known security limits; `review-security` reads it and checks changes against it | None |
| `## Always full spec` | Areas a change may not touch under express; `implement` keeps work in these areas in the session instead of delegating | None |
| `## Sub-projects` | For repositories holding several projects: each sub-project's folder. Worktrees are prefixed with the sub-project name, and its `CLAUDE.md` is read from its folder | Single project |
| `## After the spec commit` | Extra steps run after the spec files are committed, written as commands or precise instructions | None |
| `## Issue tracker` | `GitHub`, `Jira <PROJECT KEY>` or `None`; how issues are found, created, named and linked is in `shared/issues.md`. Pull requests and code review are always on GitHub | `GitHub` |
| `## Issues and PRs` | Board moves, labels, release notes and merge rules | No board |

Templates: a file in `specs/.templates/` replaces the plugin's template of the same name
(`${CLAUDE_PLUGIN_ROOT}/templates/`).

Example:

```markdown
# Spec config

## Issue tracker
GitHub

## Product doc
docs/product.md

## Docs on delivery
README.md, CLAUDE.md, docs/architecture.md

## Security register
docs/security.md

## Always full spec
- authentication and session handling
- database migrations
- a new public API endpoint or file format
- a new runtime dependency

## After the spec commit
`make docs`, then check that docs/_build/specs/<folder>/ exists.

## Issues and PRs
- Move the issue to In Review when the PR opens
- One changelog entry per change
- Never merge; the PR title and body become the squash commit
```
