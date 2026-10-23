---
name: review-security
description: Security review of the PR, posted as inline comments.
argument-hint: "[PR number or URL]"
disable-model-invocation: true
---

# Security review of a pull request

## Model gate (mandatory, before anything else)

This skill requires **Opus or Fable**. Before reading any file or calling any tool, check the
model ID you are running as. If it is **a Sonnet or Haiku model**, do not start the skill, not even
partly: print exactly the two lines below and end your turn.

```
/spec:review-security needs Opus or Fable; this session is running <your model ID>.
Next: /model fable (or /model opus), then run /spec:review-security again.
```

This is not a recommendation. A request to proceed anyway does not lift it; only switching
the session's model does.

Review one PR for exploitable security vulnerabilities and post the result as **one**
GitHub review of inline comments. The review never edits code: the operator works the
threads afterward with `/spec:feedback pr <n>`.

## 1. Resolve the PR and read context

1. The argument is a PR number or URL. With none, use the current branch's PR:
   `gh pr view --json number -q .number`. If that fails, ask for the number and stop.
2. `gh pr view <n> --json number,url,headRefName,headRefOid,baseRefName,title,body,isDraft`.
   Keep `headRefOid` as the **head SHA**; every comment is posted against it.
3. `gh repo view --json nameWithOwner -q .nameWithOwner` gives `{owner}/{repo}`.
4. Read `${CLAUDE_PLUGIN_ROOT}/shared/conventions.md`, `specs/.config.md` if present
   (sections in `${CLAUDE_PLUGIN_ROOT}/shared/config.md`) and the project's `CLAUDE.md`.
5. **Spec folder (optional).** If the branch name or PR body names a spec folder (`<issue prefix>-<slug>`, see `shared/issues.md`)
   folder that exists under `specs/`, read its requirements and design sections on trust
   boundaries, credentials and error handling. A PR without a spec is reviewed the same way.
6. **Security register.** If the config has `## Security register`, read that file in full.
   Each recorded limit is a known, accepted gap; you check changes against it in step 3.

## 2. Get the diff, the code and the line map

- If `git worktree list` shows a worktree on `headRefName`, `EnterWorktree` into it and
  confirm `git rev-parse HEAD` equals the head SHA (pull if behind). Otherwise
  `git fetch origin pull/<n>/head` and read files with `git show <head SHA>:<path>`.
  Run tests or reproductions only inside a checkout at the head SHA.
- `gh pr diff <n>` for the diff; `gh pr diff <n> --name-only` for the changed files.
  Read every changed file in full at the head SHA, not only its hunks.
- **Line map.** GitHub accepts an inline comment only on a line inside a diff hunk. From
  each hunk header `@@ -a,b +c,d @@`, the commentable RIGHT-side lines of that file are the
  added (`+`) and context (` `) lines, numbered from `c`. Save the diff to the scratchpad and
  build the map before writing any comment (`$SCRATCH` is a directory from `mktemp -d`,
  or the session's scratchpad directory when one is given):

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

Work like a careful security reviewer. First map the attack surface, then hunt.

1. **Trust boundaries and untrusted inputs touched by the diff.** List every input that
   crosses a boundary: HTTP requests, files read from shared or synced locations, CLI
   arguments, environment, webhook payloads, model output, third-party API responses,
   uploaded documents. Note which process holds which credential.
2. **Check each category against those inputs:**
   - Injection: shell (`subprocess` with `shell=True`, string-built commands), SQL (string
     formatting into queries), path traversal (user-controlled path joined without
     normalization and containment check), template injection and unescaped HTML output.
   - Authentication and authorization: a new endpoint or action reachable without the
     check its siblings enforce; a listener bound wider than intended; CSRF on
     state-changing routes.
   - Secrets: credentials logged, written to disk, put in URLs, error messages, synced
     files, client-side code, or sent to a host that should not receive them.
   - Unsafe deserialization (`pickle`, `yaml.load`, `eval`, `exec`) on untrusted data.
   - SSRF: a request URL or host derived from untrusted input.
   - File permissions and locations: secrets or private data in world-readable files,
     temp files with predictable names, writes outside the intended directory.
   - Dependency additions: a new package, an unpinned or typo-adjacent name, a dependency
     pulled from a non-default index.
   - Data exposure: private or personal data in logs, errors, telemetry or responses.
   - TOCTOU and races: check-then-use on files, double processing that duplicates an
     external write, missing locking around a shared resource.
3. **Security register.** For each change that touches an area a register entry covers,
   decide whether the change widens that limit (more exposure, a new path to the same
   gap, a weaker mitigation). Flag a widening that does not add or update a register
   entry in the same PR, naming the entry by its heading. Flag a new gap of the same kind
   that has no entry at all.

**Report only what has a concrete exploit path:** who controls the input, how it reaches
the sink, and what they gain. Exclude:

- hardening wishes, defense-in-depth suggestions and theoretical issues without a path;
- denial of service, resource exhaustion and rate-limit-only issues;
- test-only code, fixtures and dev scripts, unless they ship or run in production;
- issues present before this PR that the diff does not touch or make reachable.

## 4. Verify every finding

Before a finding is written, read the surrounding code and the callers, and trace the
input from its source to the sink at the head SHA. When it is cheap, prove it: run the
relevant test, or a short reproduction in the scratchpad. Drop anything you cannot trace
end to end, and anything the code already guards against elsewhere. Fewer findings with
high confidence beat a long list. Rank by severity:

| Severity | Meaning |
|---|---|
| Critical | Remote or unauthenticated compromise, credential disclosure, arbitrary code execution |
| High | Exploitable by a realistic attacker with modest preconditions; private data exposed |
| Medium | Exploitable under narrower preconditions, or a register limit widened without an entry |
| Low | Real but minor exposure with a concrete path |

## 5. Post one review

Each inline comment body is exactly:

````markdown
**<Severity>: <short title>**

**What's wrong:** <the vulnerable code and the missing check>
**Why it matters:** <attacker-controlled input or state → path → concrete wrong outcome>
**Proposed fix:** <the fix; a ```suggestion block when it is a few lines on the commented lines>
````

A `suggestion` block replaces exactly the commented line range, so it must contain the
full corrected text of those lines. The review `body` is: a `**Security review**` heading
line, the responder label from conventions.md (for example `**Opus 5.5 (responder):**`),
one paragraph summarizing scope, trust boundaries checked and the outcome, then any
out-of-diff findings in the same format prefixed with `path:line`. Write the payload to
the scratchpad and post it:

```json
{
  "commit_id": "<head SHA>",
  "event": "COMMENT",
  "body": "**Security review**\n\n**Opus 5.5 (responder):** <summary>\n\n<out-of-diff findings>",
  "comments": [
    {"path": "src/app/server.py", "line": 42, "side": "RIGHT", "body": "**High: ...**\n\n..."},
    {"path": "src/app/files.py", "start_line": 10, "start_side": "RIGHT",
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

**Zero findings:** post the review with no `comments`, and a body that says no
exploitable issues were found and lists what was checked (inputs, categories, register
entries).

## 6. Finish

Print the counts by severity, the review URL (`html_url` from the response), then:

```
Next: /clear, then /spec:review-code <n>
```
