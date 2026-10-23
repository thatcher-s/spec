---
name: review-code
description: Correctness and quality review of the PR, posted as inline comments.
argument-hint: "[PR number or URL]"
disable-model-invocation: true
---

# Code review of a pull request

## Model gate (mandatory, before anything else)

This skill requires **Opus or Fable**. Before reading any file or calling any tool, check the
model ID you are running as. If it is **a Sonnet or Haiku model**, do not start the skill, not even
partly: print exactly the two lines below and end your turn.

```
/spec:review-code needs Opus or Fable; this session is running <your model ID>.
Next: /model fable (or /model opus), then run /spec:review-code again.
```

This is not a recommendation. A request to proceed anyway does not lift it; only switching
the session's model does.

Review one PR for correctness and quality and post the result as **one** GitHub review of
inline comments. The review never edits code: the operator works the threads afterward
with `/spec:feedback pr <n>`.

## 1. Resolve the PR and read context

1. The argument is a PR number or URL. With none, use the current branch's PR:
   `gh pr view --json number -q .number`. If that fails, ask for the number and stop.
2. `gh pr view <n> --json number,url,headRefName,headRefOid,baseRefName,title,body,isDraft`.
   Keep `headRefOid` as the **head SHA**; every comment is posted against it.
3. `gh repo view --json nameWithOwner -q .nameWithOwner` gives `{owner}/{repo}`.
4. Read `${CLAUDE_PLUGIN_ROOT}/shared/conventions.md`, `specs/.config.md` if present
   (sections in `${CLAUDE_PLUGIN_ROOT}/shared/config.md`) and the project's `CLAUDE.md`
   in full. Its conventions (logging, error handling, docstrings, naming, spelling, test
   style) are review criteria.
5. **Spec folder.** If the branch name or PR body names a spec folder (`<issue prefix>-<slug>`, see `shared/issues.md`) that
   exists under `specs/`, read it: `requirements.md` (every AC, the Decision Log, Out of
   Scope), `design.md` § Key Interfaces and Appendix B (error messages), and `tasks.md`; or
   `spec.md` for an express spec. Without a spec, review against the PR description.

## 2. Get the diff, the code and the line map

- If `git worktree list` shows a worktree on `headRefName`, `EnterWorktree` into it and
  confirm `git rev-parse HEAD` equals the head SHA (pull if behind). Otherwise
  `git fetch origin pull/<n>/head` and read files with `git show <head SHA>:<path>`.
  Run tests or reproductions only inside a checkout at the head SHA.
- `gh pr diff <n>` for the diff; `gh pr diff <n> --name-only` for the changed files.
  Read every changed file in full at the head SHA, plus the callers of changed functions.
- **Line map.** GitHub accepts an inline comment only on a line inside a diff hunk. From
  each hunk header `@@ -a,b +c,d @@`, the commentable RIGHT-side lines of that file are the
  added (`+`) and context (` `) lines, numbered from `c`. Build the map before writing any
  comment (`$SCRATCH` is a directory from `mktemp -d`, or the session's
  scratchpad directory when one is given):

  ```bash
  gh pr diff <n> > "$SCRATCH/pr.diff"
  python3 - "$SCRATCH/pr.diff" <<'EOF'
  import re, sys, json, collections
  m, f, ln, prev = collections.defaultdict(list), None, 0, ''
  for l in open(sys.argv[1]):
      l, prev, was = l.rstrip('\n'), l, prev
      if l.startswith('+++ ') and was.startswith('--- '):
          f = l[6:] if l.startswith('+++ b/') else None; continue
      h = re.match(r'@@ -\d+(?:,\d+)? \+(\d+)', l)
      if h: ln = int(h.group(1)); continue
      if f and l[:1] in '+ ': m[f].append(ln); ln += 1
  print(json.dumps(m))
  EOF
  ```

  A finding whose line is not in the map goes in the review body as `path:line`. A
  multi-line comment's whole range must sit inside one hunk.

## 3. Review method

Look for defects first, then quality:

1. **Logic errors:** wrong condition, off-by-one, inverted check, wrong variable, a branch
   that can never run, state updated in the wrong order.
2. **Broken edge cases:** empty, missing or duplicate input; boundaries; encodings; time
   zones; a retry or a second run of the same operation.
3. **Error handling:** a failure caught and logged or ignored instead of raised; a broad
   `except` that hides a bug; an error message that misleads; partial work left behind.
4. **Spec contract** (when a spec exists): an AC the diff claims but does not satisfy; a
   signature, type or return shape that differs from § Key Interfaces; an error message
   that differs from Appendix B; behavior a Decision Log entry or Out of Scope rules out.
   Cite the reference qualified with the folder's issue prefix (`gh-42 AC-1.2`). A deviation is a
   finding even when the code works, unless `design.md` was updated to record it.
5. **Missing tests for decided behavior:** an AC or a decided error path with no test
   that would fail if it broke. Name the behavior and the test to add.
6. **Concurrency and resources:** shared state without a lock, check-then-act races,
   files, connections, processes or temp directories not closed or cleaned up on the
   error path.
7. **Project conventions:** a violation of a rule in CLAUDE.md or the config, quoting the
   rule.
8. **Reuse and simplification**, only when concrete and worth a change: an existing
   helper the diff duplicates (name it with `path:line`), dead code the diff adds, a
   construction that a much simpler one replaces with identical behavior.

Leave out style the project's formatter or linter already enforces, taste, and
pre-existing problems the diff neither touches nor makes worse. Security issues belong to
`/spec:review-security`; mention one only if it is also a correctness bug.

## 4. Verify every finding

Before a finding is written, read the surrounding code and its callers at the head SHA and
confirm the failure scenario is real: trace concrete inputs or state to the wrong outcome.
When it is cheap, prove it: run the relevant test, or a short reproduction in the
scratchpad. Drop anything speculative, and anything guarded elsewhere. Fewer findings with
high confidence beat a long list. Rank by severity:

| Severity | Meaning |
|---|---|
| Critical | Data loss or corruption, a wrong external write, the main path broken |
| High | Wrong result or swallowed failure on a realistic input; an AC not met |
| Medium | Edge-case defect, contract deviation, missing test for decided behavior, leak |
| Low | Convention violation, worthwhile reuse or simplification |

## 5. Post one review

Each inline comment body is exactly:

````markdown
**<Severity>: <short title>**

**What's wrong:** <the defect, in the code at this line>
**Why it matters:** <inputs or state → path → concrete wrong outcome>
**Proposed fix:** <the fix; a ```suggestion block when it is a few lines on the commented lines>
````

A `suggestion` block replaces exactly the commented line range, so it must contain the
full corrected text of those lines. The review `body` is: a `**Code review**` heading
line, the responder label from conventions.md (for example `**Opus 5.5 (responder):**`),
one paragraph summarizing scope, the spec checked against and the outcome, then any
out-of-diff findings in the same format prefixed with `path:line`. Write the payload to
the scratchpad and post it:

```json
{
  "commit_id": "<head SHA>",
  "event": "COMMENT",
  "body": "**Code review**\n\n**Opus 5.5 (responder):** <summary>\n\n<out-of-diff findings>",
  "comments": [
    {"path": "src/app/config.py", "line": 42, "side": "RIGHT", "body": "**High: ...**\n\n..."},
    {"path": "src/app/store.py", "start_line": 10, "start_side": "RIGHT",
     "line": 14, "side": "RIGHT", "body": "**Medium: ...**\n\n..."}
  ]
}
```

```bash
gh api repos/{owner}/{repo}/pulls/<n>/reviews --method POST --input "$SCRATCH/review.json"
```

`event` is always `COMMENT`: GitHub refuses approve or request-changes on your own PR.
If the post fails with a 422 about a line, recheck that line against the map, move the
finding to the body if it is outside the diff, and post again. Never post more than one
review.

**Zero findings:** post the review with no `comments`, and a body that says no issues
were found and lists what was checked (files, ACs, interfaces, conventions).

## 6. Finish

Print the counts by severity, the review URL (`html_url` from the response), then:

```
Next: /clear, then /spec:feedback pr <n>
```
