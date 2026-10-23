---
name: feedback
description: Answer open feedback threads in a spec file or on the PR, and apply what was agreed.
argument-hint: "[requirements|design|tasks|validation|spec [folder] | <PR comment URL> | pr [N]]"
disable-model-invocation: true
---

# /spec:feedback

## Model gate (mandatory, before anything else)

This skill requires **Opus or Fable**. Before reading any file or calling any tool, check the
model ID you are running as. If it is **a Sonnet or Haiku model**, do not start the skill, not even
partly: print exactly the two lines below and end your turn.

```
/spec:feedback needs Opus or Fable; this session is running <your model ID>.
Next: /model fable (or /model opus), then run /spec:feedback again.
```

This is not a recommendation. A request to proceed anyway does not lift it; only switching
the session's model does.

Work the open threads for one spec: answer what the user asked, apply what the user agreed
to, and leave everything else waiting on the user. The user decides; this skill proposes,
explains and carries out.

## 0. Setup

Read `${CLAUDE_PLUGIN_ROOT}/shared/preamble.md` and `${CLAUDE_PLUGIN_ROOT}/shared/conventions.md`,
then run the preamble with these adaptations:

- **Step 1 (folder).** A phase word may be followed by the spec folder
  (`/spec:feedback design gh-42`); resolve that as the preamble does. For a phase word
  alone or no argument, use the preamble's no-argument resolution. For a PR comment URL or `pr N`, take the PR
  number from the URL path or the argument; for bare `pr`, use
  `gh pr view --json number,headRefName` on the current branch. The spec folder is the one
  named in the PR's head branch.
- **Step 4 (gate): skip it.** This skill is what clears the gate.

Work out your responder label now (conventions.md, Responder label), for example
`**Opus 5.5 (responder):**`. Every reply you write starts with it.

## 1. What to work on

| Argument | Works on |
|---|---|
| `requirements`, `design`, `tasks`, `spec` | That phase's feedback file |
| `validation` | `validation-feedback.md` |
| a PR comment URL (`…#discussion_r123`) | That one PR thread |
| `pr [N]` | Every unresolved thread on PR N, or on the branch's PR |
| none | Every feedback file in the folder that has a `- [ ]` item, then the PR threads if a PR exists for the branch |

Each feedback file and the document its edits land in:

| Feedback file | Edits land in |
|---|---|
| `requirements-feedback.md` | `requirements.md` |
| `design-feedback.md` | `design.md` |
| `tasks-feedback.md` | `tasks.md` |
| `spec-feedback.md` | `spec.md` |
| `validation-feedback.md` | `requirements.md` and/or `design.md`, as each item's "Proposed change" names; never `validation.md` |

## 2. Whose turn is it

A thread is a top-level `- [ ]` item and everything indented under it. An entry is the
user's unless its text starts with a responder label (`**<model> <version> (responder):**`).
Users sign replies however they like (`**Operator:**`, their name, nothing), so key on the
label's absence, never on a particular name. The top-level line is itself a user entry, so a
thread with no replies is the user's turn.

Three exceptions, where the first entry is Claude's proposal, not the user's question:

- **Audit threads** (top line starting with a responder label, then `Audit:`) were written by `audit`. With no user reply they wait on the user;
  answered, they follow the accept / reject / adjust table under Validation threads.
- **`validation-feedback.md` items** were written by `validate`. With no user reply they
  wait on the user to accept, reject or adjust.
- **PR threads holding only a review finding** (posted by `review-security` or
  `review-code`) wait on the user the same way.

Never apply an audit or validation proposal, or fix a review finding, the user has not
answered.

Sort every open thread into one of:

- **Answer:** the user's entry is latest and asks, objects or proposes something.
- **Apply:** the user's latest entry agrees to a specific edit or fix (yours or theirs).
- **Settle:** the user's latest entry agrees that no edit is needed.
- **Waiting on the user:** the latest entry is a responder reply or an unanswered proposal.
  Leave it untouched.

## 3. Feedback files

**Answer first, every thread, before any edit.** For each Answer thread, read the thread and
the section of the document it concerns (and the code it refers to, when it refers to code),
then append one or more indented responder bullets under the thread's last line. A good
reply:

- answers the question directly in its first sentence, then gives the reason: the
  constraint, the trade-off, the evidence (`file:line`, a requirement, a decision);
- when you disagree, says so and why, and offers the alternative you would accept;
- when the right edit is plain, proposes it in words exact enough to apply;
- ends by naming what changed in the document ("Reworded D-10 in `requirements.md` to …")
  or saying no change and why.

A purely clarifying edit that changes no behavior (expanding an acronym, rewording a
misleading sentence) may be applied in the same run; say so in the reply. Anything that
changes behavior, scope or an acceptance criterion waits for the user's agreement.

Your reply never checks the item. After you answer, the thread waits on the user.

**Then apply, in one batch.** For every Apply thread, make the agreed edit in the target
document, append a short responder bullet naming the file and section edited, and check
the item (`- [x]`). For every Settle thread, check the item. Edits that ripple (a renamed
term, a changed AC number) are followed through every section of the document, and into
the other spec documents when they reference it.

**Validation and audit threads.** The user answers a proposal one of three ways:

| User's answer | Action |
|---|---|
| Accepts | Apply the proposed change to the file and section it names; check the item |
| Rejects | Append a responder bullet recording the reason given; check the item; no edit |
| Adjusts | Apply the adjusted change; record what differed from the proposal; check the item |

A decision taken in a validation thread that alters the design also gets a Decision Log row
in the document it changes.

**Commit once.** When the batch is done, commit the feedback files and documents together,
checking the branch in the same command:

```bash
test "$(git branch --show-current)" = "<spec branch>" && git add specs/<folder>/ && git commit -m "spec: apply <phase> feedback <issue suffix>"
```

`<phase>` is the phase worked, or a comma-separated list when several were. Follow the
project's commit conventions (CLAUDE.md). If the branch has an upstream, push.

## 4. PR threads

The operator's account posts both the user's comments and Claude's replies, so the author
login cannot tell them apart: the responder label does.

**Read the threads.** Get the owner and name from `gh repo view --json owner,name`, then:

```bash
gh api graphql -F owner=<owner> -F name=<name> -F number=<n> -f query='
query($owner:String!,$name:String!,$number:Int!){
  repository(owner:$owner,name:$name){
    pullRequest(number:$number){
      reviewThreads(first:100){
        nodes{
          id isResolved isOutdated path line
          comments(first:50){
            nodes{ databaseId url body createdAt author{ login } }
          }
        }
      }
    }
  }
}'
```

Skip resolved threads. For a single comment URL, take the number after `#discussion_r` and
work only the thread containing the comment with that `databaseId`.

**States** (exactly these three):

| State | How to recognize it | Action |
|---|---|---|
| In discussion | Unresolved; the latest comment is the user's (no responder label) | Respond |
| Agreed, fix pending | Unresolved; the latest comment ends `Fix pending.` | Commit the fix, push, reply with the SHA, resolve |
| Done | Resolved | None |

`Fix pending.` is written only by you, never by the user. The user agrees in their own
words ("yes, do that", "go with your fix"); you confirm the fix in a reply ending with that
line, and the fix is made in this run's fix batch. The marker exists so a run that stops
between the reply and the fix knows to finish it next time.

Unresolved threads whose latest comment is a responder reply not ending `Fix pending.`, or
a review finding with no user reply, are waiting on the user.

**Respond to every In-discussion thread first.** Read the finding, the code at `path:line`
on the branch head, and the spec section it concerns. Reply in the style of §3. Three
outcomes:

- **The user agrees to a fix** (in this comment, or by asking for one): reply confirming
  exactly what you will change, ending with the line `Fix pending.` This run's fix batch, or
  the next run, picks it up.
- **No change needed:** reply with the reason and leave the thread unresolved. Resolving it
  is the user's call.
- **Still open:** answer, propose, and leave it waiting on the user.

Reply to a thread by posting to its first comment:

```bash
gh api repos/<owner>/<name>/pulls/<n>/comments/<first comment databaseId>/replies \
  -f body='**Opus 5.5 (responder):** ...'
```

**Then fix, one commit per thread.** For each Fix-pending thread (including those you
just marked): make the fix, run the tests and lint the project's CLAUDE.md or tasks.md names
for the touched code, and commit with a message that describes the fix, checking the branch
in the same command. A fix that changes the design also updates `design.md`. When every fix
is committed, push once. Only after the push succeeds, for each thread: reply with the
responder label, what changed and the short SHA, then resolve it:

```bash
gh api graphql -F id=<thread node id> -f query='
mutation($id:ID!){ resolveReviewThread(input:{threadId:$id}){ thread{ isResolved } } }'
```

A fix that fails its tests is not committed: reply on the thread with what failed, drop
the `Fix pending.` ending, and leave it for the user.

## 5. End

Print what was done and what is still open:

```
Answered: <n>   Applied: <n>   Fixed: <n> (<SHAs>)
Waiting on you:
  <absolute path>/design-feedback.md: Key Interfaces — <first line, trimmed to 80 chars>
  PR #<n>: <thread URL> — <first line of the finding>
```

Then the Next line. When a feedback file still has open threads:
`Next: reply in <file>, then /spec:feedback <phase> <folder>`. When every feedback file the next
phase's gate checks is clear, name that phase, for example
`Next: /clear, then /spec:tasks <folder>`. For PR threads with replies still waiting:
`Next: reply on the PR, then /spec:feedback pr <n>`; when none are unresolved, the PR is
ready for the user to merge.
