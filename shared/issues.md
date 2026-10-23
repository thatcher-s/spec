# Issue trackers

Specs link to an issue in whatever tracker the project uses, named by the config's
`## Issue tracker` section (`GitHub` when the section is absent). Pull requests and code
review are always on GitHub (`gh pr ...`), whatever the tracker.

| | GitHub (default) | Jira (`Jira PROJ`) | None |
|---|---|---|---|
| Issue id | `#42`; folder prefix `gh-42` | `PROJ-123`; folder prefix `proj-123` | none |
| Spec folder | `gh-42-<slug>` | `proj-123-<slug>` | `<slug>` |
| Arguments that resolve to it | `42`, `#42`, `gh-42` | `PROJ-123`, `proj-123` | the slug |
| Validate an existing issue | `gh issue view 42 --repo <repo>` | a connected Jira MCP tool; without one, accept the key as given | n/a |
| Create a new issue | `gh issue create --repo <repo> --title ... --body ...` | a connected Jira MCP tool; without one, ask the user to create it and give the key | n/a |
| Commit message suffix | `(#42)` | `(PROJ-123)` | none |
| PR link | a `Closes #42` line in the body | the title starts with `PROJ-123: ` | none |
| Spec references outside the folder | `gh-42 AC-1.2` | `proj-123 AC-1.2` | the folder name, `csv-export AC-1.2` |

`<repo>` comes from `gh repo view --json nameWithOwner -q .nameWithOwner`. Never call a
tracker that the config does not name, and never invent an issue key.

## Link or create (used by `reqs` and `express`)

If the argument already names an issue, validate it and skip the question. Otherwise ask
with AskUserQuestion, one question, three options:

- **Existing issue:** the user gives the id; validate it as the table says. If it is not
  found, say so and ask again.
- **Create a new issue:** create it as the table says, with a title and two or three
  sentences from the request, and capture the id. Then apply what the config's Issues and
  PRs section says about new issues (a board, labels, a milestone).
- **No issue:** the spec has no issue id; the folder is `<slug>`.

With the tracker set to None, skip the question: there is no issue.
