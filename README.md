# spec

A [Claude Code](https://code.claude.com) plugin for spec-driven development. A change is
specified, reviewed and built one phase at a time, each phase in a fresh session, so no
single session carries the whole process in its context. Every review, of the spec or of
the pull request, happens in threads you answer, and nothing moves on while a thread is
open.

```
/spec:reqs → /spec:design → (/spec:validate) → /spec:tasks → /spec:audit → /spec:implement → /spec:review-security → /spec:review-code
/spec:express → /spec:implement        for small changes
/spec:feedback                         wherever threads are open
```

## Requirements

- Claude Code, on **Opus or Fable**. Every skill except `/spec:audit` refuses to run on
  Sonnet or Haiku; implementation work is delegated to cheaper subagents where it fits.
- `git` and an authenticated [`gh`](https://cli.github.com) CLI. Pull requests and code
  review are on GitHub; issues can be GitHub, Jira (through a connected Jira MCP server)
  or none.
- Workflows enabled (`"enableWorkflows": true` in settings) for `/spec:validate`.

## Install

In Claude Code:

```
/plugin marketplace add thatcher-s/spec
/plugin install spec@spec
```

Or in `~/.claude/settings.json`, so every machine with your settings gets it:

```json
{
  "extraKnownMarketplaces": {
    "spec": { "source": { "source": "github", "repo": "thatcher-s/spec" } }
  },
  "enabledPlugins": { "spec@spec": true }
}
```

Then start a new session, or run `/reload-plugins`. Installs track `main`: run
`/plugin update spec@spec` (or turn on auto-update for the marketplace) to pick up changes.

## Set up a project

Run `/spec:init` at the repository root. It reads the codebase and drafts
`specs/.config.md`, the one file that holds what is specific to the project:

- the issue tracker (GitHub, Jira or none)
- the product or design document requirements should cite
- the docs to update when behavior changes
- a security register the security review checks against
- the areas that always need a full spec, never the express path
- extra steps after a spec is committed, such as adding it to a docs site
- issue and PR conventions (boards, changelog entries, merge rules)

It asks you about the judgment calls, then opens a PR with the file. Everything else
(toolchain, test and lint commands, code conventions) is read from the project's own
`CLAUDE.md`, task runner and manifests. The sections and defaults are in
[shared/config.md](shared/config.md). A project can override any template by putting a
file of the same name in `specs/.templates/`.

## How a spec runs

Each command does one phase, writes its result to `specs/<folder>/` in a dedicated git
worktree, and ends by printing the exact next command. Run `/clear` between phases.

| Command | Does |
|---|---|
| `/spec:reqs` | Links or creates the issue, opens the worktree, drafts `requirements.md` |
| `/spec:design` | Drafts `design.md` and says whether `/spec:validate` is worth running |
| `/spec:validate` | Optional, for risky designs: an advocate, a skeptic and a judge test each key decision |
| `/spec:tasks` | Breaks the design into phased, test-first tasks and commits the spec |
| `/spec:audit` | Checks the spec is implementable; findings become feedback threads |
| `/spec:implement` | Builds the spec phase by phase through subagents, then opens the PR |
| `/spec:review-security`, `/spec:review-code` | Each posts one GitHub review with inline comments: what's wrong, why it matters, the proposed fix |
| `/spec:express` | A one-file spec for a small change, then straight to `/spec:implement` |
| `/spec:feedback` | Answers open threads and applies what you agreed to |

**Feedback threads.** Each document gets a sibling feedback file (`design-feedback.md`).
You add `- [ ]` items under the heading they concern; `/spec:feedback design` replies,
applies the edits you agree to and checks the items off. The next phase refuses to start
while an earlier one has an open thread, so running the next command is your approval.
On a pull request the same loop runs on review comments, and a thread is resolved only
when its fix is pushed.

The full design is in [docs/design.md](docs/design.md).

## Develop

```bash
just init                  # pre-push hook (release check)
claude --plugin-dir .      # load this checkout in place of the installed copy
just validate              # check the plugin and marketplace manifests
```

Releases use [release-fragments](https://github.com/thatcher-s/release-fragments). A
change to `skills/`, `shared/`, `templates/`, `.claude-plugin/` or the workflows adds a
fragment, one per distinct change:

```bash
just fragment <added|changed|fixed|removed|deprecated|security|breaking> "<what changed>"
```

Merging a PR with fragments writes `CHANGELOG.md`, bumps the version and publishes a
GitHub release.

## Contributing

This is a personal tool, published so it is easy to install anywhere. Issues are turned
off and outside pull requests aren't reviewed. Fork it freely under the license.

## License

[MIT](LICENSE)
