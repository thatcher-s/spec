# Design

**Flow:** `/spec:reqs` → `/spec:design` → optional `/spec:validate` → `/spec:tasks` →
`/spec:audit` → `/spec:implement` (ends with a PR) → `/spec:review-security` and `/spec:review-code`. Small
changes take `/spec:express` → `/spec:implement` instead. `/spec:feedback` runs wherever
threads are open, and `/spec:audit` can also run at any earlier stop.

Every skill runs in a fresh session. Nothing a later phase needs lives only in a
conversation: it is in the spec folder, a feedback file, git, or a PR thread.

## 1. Why one session per phase

A full spec is large: a `design.md` alone can run past 1,500 lines. Drafting the
requirements, iterating on feedback, drafting the design, iterating again, writing tasks
and implementing, all in one conversation, piles every one of those documents and
discussions into a single context. Splitting the process at each phase, and at each
human review stop, keeps every session's context to what that phase needs.

The plugin serves every project the same way. What differs between projects (repository,
product doc, docs to update, toolchain, extra steps) comes from a per-project config file
(§12), never from a project-specific copy of the skills.

## 2. Principles

1. **One phase, one session.** Each skill starts cold, reads what it needs from disk, and
   ends by writing everything it decided to disk.
2. **Running the next command is the approval.** There is no approval marker. A skill
   refuses to start while an earlier phase still has an open thread (§5.3).
3. **The human decides; Claude proposes.** Review output (validation, PR review) is
   written as threads for the operator to accept, reject or adjust. No review edits the thing
   it reviewed.
4. **Threads are the history.** Feedback files and PR comment threads hold the verbatim
   back-and-forth. A decision made while drafting, before any feedback file exists, goes
   in the Decision Log.
5. **The session model plans and reviews; cheaper models implement** (§9). Every skill that
   reasons (planning, design, spec writing, review, feedback) refuses to run below Opus:
   it runs on Opus or Fable. `audit`, a fixed checklist, also runs on Sonnet. Only implementation subagents use Sonnet, for mechanical work. This
   is a plugin default, not per-project config.
6. **Project facts come from the project.** The plugin never hardcodes a repository,
   toolchain or doc path. It reads `specs/.config.md` (§12) and the project's CLAUDE.md.

## 3. Skills

All skills set `disable-model-invocation: true`: they run only when typed, never because
Claude matched a description.

| Skill | Argument | Reads | Writes | Description (autocomplete text) |
|---|---|---|---|---|
| `init` | `[notes]` | the codebase, CLAUDE.md, docs, manifests, remote | `specs/.config.md` on a branch, PR | Set up a project for the spec plugin: draft specs/.config.md from the codebase, confirm the judgment calls, and open a PR. |
| `reqs` | `[description or #issue]` | config, product doc, codebase | issue, worktree, `requirements.md`, empty `requirements-feedback.md` | Start a spec: issue, worktree, and the requirements draft. Suggests express when the change is small. |
| `design` | `[spec folder]` | `requirements.md`, codebase | `design.md`, empty `design-feedback.md` | Draft the technical design from approved requirements, then recommend whether to run validate. |
| `validate` | `[spec folder]` | `requirements.md`, `design.md` excerpts, repo | `validation.md`, `validation-feedback.md` | Pressure-test the riskiest design decisions before tasks are written. Each becomes a falsifiable statement: an advocate argues it holds, a skeptic argues it fails, and a judge checks the evidence and rules. Optional, for complex specs. |
| `tasks` | `[spec folder]` | `requirements.md`, `design.md` | `tasks.md`, empty `tasks-feedback.md` | Break the approved design into phased, test-first tasks with parallel-safe tags. |
| `express` | `[description or #issue]` | config, codebase | issue, worktree, `spec.md`, empty `spec-feedback.md` | One-file spec for a small change: problem, criteria, approach, files, tasks. |
| `feedback` | `[phase [folder] \| thread URL \| pr [N]]` | the named feedback file or PR threads | replies, spec edits, fix commits | Answer open feedback threads in a spec file or on the PR, and apply what was agreed. |
| `audit` | `[spec folder]` | the spec folder | findings as feedback threads | Structural check that the spec is ready to implement. |
| `implement` | `[spec folder] [phase]` | the whole spec | code, tests, `tasks.md` checkboxes, PR | Implement the spec phase by phase through subagents, then open the PR. |
| `review-security` | `[PR]` | PR diff, config's security register | one GitHub PR review | Security review of the PR, posted as inline comments. |
| `review-code` | `[PR]` | PR diff, the spec | one GitHub PR review | Correctness and quality review of the PR, posted as inline comments. |

**Naming rule:** one verb, one meaning. `validate` tests design decisions, `review` is
PR review only, `audit` is the structural readiness check, `feedback` works threads. A
verb takes a suffix only when it has more than one target (`review-security`,
`review-code`).

Every local file path a skill shows the user is absolute, because spec files live in a
worktree until the branch merges and an editor resolves relative paths against the main
checkout. Paths written inside files stay repository-relative.

Every skill ends by printing the exact next command, for example
`Next: /clear, then /spec:design gh-42-csv-export`.

## 4. Shared preamble

Every skill except `reqs` and `express` (which create the folder) starts with the same
steps, kept once in `shared/preamble.md` and read via `${CLAUDE_PLUGIN_ROOT}`:

1. **Resolve the spec folder** from the argument (`gh-42`, `gh-42-csv-export`, or a
   path). With no argument, use the only folder whose worktree is the current directory,
   or ask.
2. **Enter its worktree.** If the current directory is not that spec's worktree, find it
   in `git worktree list` and call `EnterWorktree(path: ...)`.
3. **Read `specs/.config.md`** and the project CLAUDE.md.
4. **Check earlier phases** (§5.3).

## 5. Feedback threads

### 5.1 Feedback files

Each drafted document gets a sibling feedback file with the same section headings and no
content: `requirements-feedback.md`, `design-feedback.md`, `tasks-feedback.md`,
`spec-feedback.md` (express), and `validation-feedback.md` (written by `validate`, not
empty). The operator adds threads under the heading they concern:

```markdown
## Key Interfaces
- [ ] Why does `load_config` return a dict instead of a dataclass?
    - **Opus 5.5 (responder):** The caller merges it with defaults key by key ...
        - **Operator:** OK, but document that in the docstring.
```

Claude's replies start with `**<model> <version> (responder):**`, for example
`**Opus 5.5 (responder):**` or `**Sonnet 5 (responder):**`: the model family and version
of the session that wrote the reply, taken from the model ID it is running as. Read back
later, the label shows which model made each argument. The item is checked (`[x]`) when
the thread is settled and its edit is applied to the document.

### 5.2 PR threads

The same model on GitHub. Reviews and replies post under the operator's account, so Claude's
replies carry the same `**<model> <version> (responder):**` label. A thread has three states:

| State | How the skill recognizes it | Next step |
|---|---|---|
| In discussion | Unresolved; the operator's reply is the latest | Claude responds |
| Agreed, fix pending | Unresolved; the latest reply ends `Fix pending.` | Claude commits the fix, replies with the SHA, resolves |
| Done | Resolved | None |

Only Claude writes `Fix pending.`: the user agrees in their own words, Claude confirms
the fix in a reply ending with that line, then makes it.

**Resolved means the fix is committed and pushed.** A "no change needed" outcome gets a
reply with the reason and is left for the operator to resolve, because that call is the operator's.

### 5.3 The open-thread gate

Before starting, each skill checks every earlier phase's feedback file for unchecked
`- [ ]` items and refuses with the list if any remain:

| Skill | Checks |
|---|---|
| `design` | requirements |
| `validate` | requirements, design |
| `tasks` | requirements, design, validation (if present) |
| `implement` | requirements, design, validation (if present), tasks; or `spec-feedback.md` for express |

The PR is ready to merge when it has no unresolved threads.

### 5.4 `/spec:feedback` arguments

| Argument | Works on |
|---|---|
| `requirements`, `design`, `tasks`, `validation`, `spec` | That feedback file's unchecked items |
| a PR comment URL (`…#discussion_r123`) | That one thread |
| `pr [N]` | Every unresolved thread on PR N, or the branch's PR |
| none | Everything open: feedback files first, then PR threads |

Working several threads, it answers every discussion first, then applies the agreed
changes in one batch (one commit for spec edits; for PR threads, one commit per fix with
the SHA in each thread's reply), so fixes don't land while sibling threads are still
under debate.

## 6. Spec phases

### 6.1 `reqs`

Link or create the issue, `EnterWorktree` named after
the folder (`gh-42-<slug>`, or the tracker's prefix: `proj-123-<slug>` for Jira; prefixed
by sub-project when config lists sub-projects),
create `specs/<folder>/`, draft `requirements.md` from the template, write the empty
feedback file. Requirements cite the product doc's sections instead of restating them.

**Express suggestion.** Before drafting, it checks the change against the express limits
(§8.2). If none trips and the change looks small, it asks once with AskUserQuestion
whether to switch to express; on yes it continues as express in the same session, reusing
the issue and worktree.

**Upgrading an express spec.** Given a folder that holds `spec.md`, `reqs` seeds
`requirements.md` from it (§8.2) and the full flow continues from there.

### 6.2 `design`

Sections: Approach, Data Flow, Key Interfaces with AC references in headings, Affected
Modules (with the config's docs-on-delivery list), Alternatives, Risks, Appendix A
(worked examples), Appendix B (error messages), optional Appendix C.

**Validate recommendation.** It ends by checking the design against the validate signals
(§7.1) and prints either "run `/spec:validate` next" or "skip to `/spec:tasks`", with one
line of reasoning.

### 6.3 `tasks`

Sections: Start Here, Implementation Setup quoting the project's real commands, phased
tasks with AC references, `[P]` tags, test-first sub-steps, Definition of Done,
Parallelism Cheat Sheet. Ends by committing the spec, plus the config's after-commit
steps, and hands off to `audit`, which runs in its own session so the spec is checked by a
context that did not write it.

## 7. `validate`

Three properties make validation worth its cost; losing any one turns it into theater.
The skeptic is as strong as the advocate, because a weak attack manufactures confidence
the design hasn't earned. The advocate and skeptic never see each other's work, because
shared context produces agreement, not a test. The judge verifies instead of refereeing,
because a judge given only two briefs rewards the better writer.

### 7.1 When to run it

Opt-in. `design` recommends it when the design has any of:

- **new machinery** that has never run
- **hard-to-undo effects**: migrations, deletions, writes to an external system
- **silent failure**: wrong output instead of an error
- **internal tension**: a principle applied in one place and its opposite elsewhere

Never for express.

### 7.2 Run

1. Read § Approach, § Alternatives, § Risks and the Decision Log, not the whole design.
   Propose falsifiable statements: **2 or 3** for a medium spec, **5 to 7** for a big one.
   Show the list and wait for confirmation.
2. Per statement, three agents at the session's model tier through the Workflow tool:
   - **Advocate:** the strongest case that the decision is correct.
   - **Skeptic:** the strongest case that it is wrong or fails in practice. The brief says
     outright that a weak attack is a failure of the role.
   - **Judge:** fresh context with repo access, given the statement, the design excerpt
     and both briefs. Spot-checks the load-bearing claims itself and rules UPHELD,
     OVERTURNED or UNPROVEN, stating the deciding evidence.
   Claims are grounded by execution or `file:line` citation; an uncited assertion is
   inadmissible. One judge per statement.
3. Synthesize: per statement the verdict, deciding evidence and implied change; then what
   the skeptic found that the design does not address, UNPROVEN statements and why, and
   drift between cited commits and HEAD.

Agent count is 6 to 21. A 7-statement run needs the workflow size guideline at `large`
(set per machine in `/config`).

### 7.3 Output

- `validation.md`: the full report.
- `validation-feedback.md`: one thread per OVERTURNED or UNPROVEN statement and per
  unaddressed finding, each with the deciding evidence and a proposed change naming the
  file and section:

```markdown
- [ ] S3 OVERTURNED: "The fingerprint is deterministic across Python versions."
    - Deciding evidence: `render.py:88` iterates a set; order varies by hash seed.
    - Proposed change: design.md § Key Interfaces: sort keys before hashing;
      requirements.md AC-2.3: add "stable across interpreter runs".
```

`validate` never edits the spec. `/spec:feedback validation` applies the accepted
proposals in a fresh session.

## 8. `express`

### 8.1 `spec.md`

One file, about 60 to 150 lines:

```markdown
# <Title> (express)

## Problem              2 to 5 sentences
## Acceptance Criteria  AC-1.1, AC-1.2 … (the full format, so an upgrade keeps the numbers)
## Approach             one paragraph, plus the rejected alternative in one line
## Affected Files       file | change
## Tasks                test-first checklist
## Decisions            D-1 … one line each
## Out of Scope
```

One review stop through `spec-feedback.md`, then `/spec:implement`.

### 8.2 Limits

Express checks these before it creates an issue or worktree, and stops and recommends the
full spec when the change has:

- more than one sensible approach
- a new interface contract or a new dependency
- open questions that one review round can't settle
- anything on the config's always-full-spec list

**Upgrade path:** Problem and Acceptance Criteria seed `requirements.md` with the same
numbers, Decisions seed the Decision Log, and the flow continues at `/spec:design`.

## 9. `implement`

1. Read `tasks.md` (or `spec.md` Tasks for express). With a phase argument, do only that
   phase; without one, continue from the first unchecked task.
2. **Delegation:** the session model reads, briefs and reviews. Implementation goes to
   subagents: Sonnet for mechanical work with a precise brief, Opus for judgment inside a
   known design. `[P]` tasks run in parallel. The session keeps decisions and anything the
   config marks as always-full-spec.
3. Check off tasks; when the design changes during implementation, update `design.md`.
4. After the last phase: the summary report (changes, AC coverage, deviations), push, and
   `gh pr create` following the config's PR conventions, linked to the issue the tracker's
   way (§12).
5. Print `Next: /spec:review-security, then /spec:review-code`.

## 10. PR reviews

`review-security` and `review-code` are separate skills, each in its own session, so each
review gets a clean context. Each carries its own review instructions, modeled on the
built-in `/security-review` and `/code-review` methods but able to read project context:
`review-security` reads the config's security register, `review-code` reads the spec.

**Output:** one GitHub review per skill, posted with
`gh api repos/{owner}/{repo}/pulls/{n}/reviews` and `event: COMMENT` (GitHub refuses
approve or request-changes on your own PR). Each finding is an inline comment:

```markdown
**What's wrong:** …
**Why it matters:** …
**Proposed fix:** … (a ```suggestion block when the fix is a few lines)
```

A finding on a line outside the diff goes in the review body with `file:line`, because
GitHub accepts inline comments only on diff lines. The threads are then worked with
`/spec:feedback` (§5.2).

## 11. `audit`

Scores a spec folder against criteria that predict whether a fresh session given only the
folder could implement it without asking a design question. Each criterion scores 0, 0.5
or 1, times its weight.

| File | Criterion (weight) |
|---|---|
| `requirements.md` | AC-N.M numbering (3); at least 3 AC groups of 2+ (2); Decision Log with D-N rows (2); Glossary of 5+ terms (2); Open Questions empty (3); Out of Scope with 2+ items (1); reading-order callout at the top (1) |
| `design.md` | Appendix A with 3+ worked examples (3); Appendix B error-message table (3); Key Interfaces with typed signatures (3); AC references in 3+ headings (2); Affected Modules table with a docs entry when user-facing behavior changes (2); 2+ Alternatives with reasons (1) |
| `tasks.md` | 3+ `[P]` tags (3); AC references in task titles (3); Start Here (2); Implementation Setup (2); test-first sub-steps (2); Parallelism Cheat Sheet (2); quantified Definition of Done (2); the project's real toolchain commands (1) |

**Findings become threads.** Audit writes each blocking issue and each criterion scoring
below 1 as a thread in the matching feedback file, signed with its responder label and starting
`Audit:`, with a proposed fix, and commits the
feedback files. It never edits a spec document. Every thread, recommendations included,
blocks `implement` until the user answers it; a one-word "no" settles one. A rerun skips
findings that already have a thread.

Max 45. **Ready** means at least 80% and no blocking issue: a missing file, an open
question, no AC numbering, no Appendix A or B, no `[P]` tags, or an unchecked feedback
item.

**Express profile.** For a folder with `spec.md`: numbered criteria, Affected Files
present, test-first tasks, no open questions, no unchecked feedback items. Pass or fail,
no score.

## 12. Per-project config: `specs/.config.md`

`/spec:init` drafts it: it reads CLAUDE.md, the docs, manifests, docs-site config and the
remote, proposes each section with a reason, asks the user to choose the always-full-spec
areas, and opens a PR with the file. Skills that find no config suggest it.

Holds only what differs between projects; everything else is read from the project's
CLAUDE.md, justfile or manifest. A template in `specs/.templates/` replaces the plugin's
default of the same name. Sections:

| Section | Meaning |
|---|---|
| Issue tracker | `GitHub` (default), `Jira <KEY>` or `None`: how issues are found, created,
named and linked (`shared/issues.md`). PRs and code review are always on GitHub |
| Product doc | Path; requirements cite its sections |
| Docs on delivery | Files the design's Affected Modules must consider |
| Security register | Path read by `review-security` |
| Always full spec | Areas express refuses and `implement` keeps in the session |
| Sub-projects | For monorepos: worktree prefix and where each sub-project's CLAUDE.md lives |
| After the spec commit | Extra steps, as commands |
| Issues and PRs | Board moves, release notes, merge rule |

An example:

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

## 13. Packaging

```
spec/
├── .claude-plugin/
│   ├── plugin.json            name "spec", no version (each commit is a version)
│   └── marketplace.json       this repo as a one-plugin marketplace
├── skills/
│   └── <skill>/SKILL.md       one per row of §3
├── shared/
│   ├── preamble.md            §4
│   ├── conventions.md         sessions, feedback format, responder label, git rules
│   ├── config.md              the specs/.config.md sections and their defaults
│   └── issues.md              GitHub, Jira or no issue tracker
├── templates/                 requirements, design, tasks, spec, five feedback files
└── docs/design.md
```

**Install:** `extraKnownMarketplaces` for `thatcher-s/spec` and `enabledPlugins` for
`spec@spec` in `~/.claude/settings.json` (the dotfiles copy), so every machine gets it.
**Dev loop:** `claude --plugin-dir ~/code/projects/spec` loads the working copy in place
of the installed one. The marketplace entry's source is `"."`, the repository root.

## 14. To verify in the first real run

- A skill's instructions calling the Workflow tool count as the user's opt-in.
- `EnterWorktree(path:)` from a skill in a fresh session started in the main checkout.
- Replying to and resolving review threads (`resolveReviewThread` via GraphQL).

## 15. Not doing

- Model pinning in skill frontmatter. It lasts one turn, so it would lapse at the first
  question a skill asks, and `model: opus` would downgrade a Fable session. The session
  gate in `shared/conventions.md` enforces Opus or Fable instead.
- A `/spec:pr` skill. The PR is the end of `implement`.
- Adversarial validation for express.
