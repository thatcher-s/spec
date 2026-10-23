---
name: validate
description: "Pressure-test the riskiest design decisions before tasks are written. Each becomes a falsifiable statement: an advocate argues it holds, a skeptic argues it fails, and a judge checks the evidence and rules. Optional, for complex specs."
argument-hint: "[spec folder]"
disable-model-invocation: true
---

# Validate a design

## Model gate (mandatory, before anything else)

This skill requires **Opus or Fable**. Before reading any file or calling any tool, check the
model ID you are running as. If it is **a Sonnet or Haiku model**, do not start the skill, not even
partly: print exactly the two lines below and end your turn.

```
/spec:validate needs Opus or Fable; this session is running <your model ID>.
Next: /model fable (or /model opus), then run /spec:validate again.
```

This is not a recommendation. A request to proceed anyway does not lift it; only switching
the session's model does.

Adversarial validation of a drafted design. For each decision under test, an **advocate**
and a **skeptic** argue opposite sides from independent context, and a **judge** checks
the evidence itself and rules.

**This skill produces a verdict report, never revisions.** It never edits
`requirements.md` or `design.md`. The operator accepts, rejects or adjusts each proposed
change, and `/spec:feedback validation <folder>` applies the accepted ones in a fresh session.

## 0. Preamble

Read and follow `${CLAUDE_PLUGIN_ROOT}/shared/preamble.md`, then
`${CLAUDE_PLUGIN_ROOT}/shared/conventions.md`.

Gate (preamble step 4): `requirements-feedback.md` and `design-feedback.md`. Refuse while
either holds an unchecked `- [ ]` item.

An express folder (`spec.md`) is never validated: stop with `Next: /clear, then /spec:implement <folder>`.

## Why the structure is what it is

Three properties make validation worth its cost. Losing any one turns it into theater:

1. **The skeptic is as strong as the advocate.** A weak attack lets the judge uphold
   and manufactures confidence the design has not earned, which is worse than skipping
   validation, because the decision now looks tested. All three roles run at the same
   model tier: the session's model. Never cheapen the skeptic.
2. **The advocate and skeptic never see each other's work.** Shared context produces
   agreement, not a test.
3. **The judge verifies instead of refereeing.** A judge given only two briefs rewards
   the better writer. It gets repo access and an explicit mandate to spot-check the
   load-bearing claims itself.

## 1. Propose statements

Read `design.md` § Approach, § Alternatives, § Risks, and the Decision Log and Open
Questions in `requirements.md`. Do not load a large design wholesale, here or into any
agent; pull the specific excerpt each statement rests on.

Each statement is a **falsifiable claim**, not a topic:

- Good: "The render fingerprint is deterministic across Python versions, dict ordering
  and locale."
- Bad: "The fingerprint approach."

Bias toward decisions that are:

- **newly invented**: machinery this design introduces, which has never run
- **hard to undo**: migrations, deletions, writes to an external system
- **silent on failure**: wrong output rather than an error
- **internally tense**: a principle applied in one place and its opposite elsewhere
- **already flagged**: items awaiting the operator's confirmation gain more from an
  adversarial read than from assent

Skip mechanical acceptance criteria and anything the design already verified by
citation; spend the budget on judgment.

Count: **2 or 3** for a medium spec, **5 to 7** for a big one. Number them `S1`, `S2`, ….
Show the list, each with the design section it tests and one line on why it is risky,
and **wait for confirmation** (AskUserQuestion, or a plain reply). Apply any edits the
operator makes, and record the confirmed list in `validation.md` § Statements.

## 2. Fan out

Record `git rev-parse HEAD` for the drift check. Call the **Workflow** tool with the
script below and `args`:

```json
{
  "folder": "specs/<folder>",
  "head": "<sha>",
  "statements": [
    {"id": "S1", "statement": "<claim>", "section": "design.md § <heading>", "excerpt": "<verbatim design text>"}
  ]
}
```

Agent count is three per statement: 6 to 21. A run above the machine's workflow size
guideline (7 statements, 21 agents, needs it at `large`, set per machine in `/config`) may
be refused; if so, split the statements into batches and run the script once per batch.
If you need the Workflow API beyond this script, load the `workflow-authoring` skill
before calling it.

```js
export const meta = {
  name: 'spec-validate',
  description: 'Advocate, skeptic and judge per design statement',
  phases: [
    { title: 'Argue', detail: 'advocate and skeptic per statement, independent context' },
    { title: 'Judge', detail: 'one judge per statement, spot-checks the evidence' },
  ],
}

const EVIDENCE = `Evidence rule: ground every claim by execution or citation. Run the code,
run any scripts under ${args.folder}/evidence/, grep the repo, and cite file:line. An
uncited assertion is inadmissible and will be discarded. Where the design cites
verification against a specific commit, check that citation against HEAD (${args.head})
and report any drift. Do not edit any file.`

const context = (s) => `Spec folder: ${args.folder}
Statement ${s.id}: "${s.statement}"
Design excerpt (${s.section}):
"""
${s.excerpt}
"""
You may read requirements.md and design.md in the spec folder, but read only the sections
you need.`

const advocate = (s) => `You are the ADVOCATE for one design decision.
${context(s)}
Build the strongest case that this statement holds and the decision is correct.
Steelman it: find the evidence in the repository that vindicates it.
${EVIDENCE}
Return a brief: the claims your case rests on, each with its evidence.`

const skeptic = (s) => `You are the SKEPTIC for one design decision.
${context(s)}
Build the strongest case that this statement is false or that the decision fails in
practice. Hunt for the failure mode, the unhandled case, the assumption that does not
hold, the place the design contradicts itself or the code. A weak or token attack is a
failure of this role: it lets an unearned decision pass as tested. Attack as hard as
the evidence allows.
${EVIDENCE}
Also list anything you found that the design does not address at all, even if it does
not bear on this statement.
Return a brief: the claims your case rests on, each with its evidence.`

const judge = (s, pro, con) => `You are the JUDGE for one design decision.
${context(s)}
ADVOCATE brief:
"""
${pro ?? '(the advocate returned nothing)'}
"""
SKEPTIC brief:
"""
${con ?? '(the skeptic returned nothing)'}
"""
Do not referee the rhetoric. Identify the load-bearing factual claims on both sides and
spot-check them yourself in the repository: open the cited lines, run what can be run.
A claim without execution or a file:line citation is inadmissible. Then rule:
- UPHELD: the decision survives; the skeptic's case failed on evidence.
- OVERTURNED: the skeptic's case is correct; the design must change.
- UNPROVEN: neither side is decisive, usually because the claim is untestable as written.
State the deciding evidence, not a summary of both sides. For OVERTURNED or UNPROVEN,
name the change the spec needs (file, section, change). List skeptic findings the design
does not address and you confirmed, and any drift between cited commits and HEAD
(${args.head}). Do not edit any file.`

const VERDICT = {
  type: 'object',
  properties: {
    verdict: { type: 'string', enum: ['UPHELD', 'OVERTURNED', 'UNPROVEN'] },
    deciding_evidence: { type: 'string', description: 'The finding that decided it, with file:line or the command run' },
    implied_change: {
      type: 'object',
      properties: {
        file: { type: 'string', description: 'requirements.md or design.md, or "none"' },
        section: { type: 'string' },
        change: { type: 'string' },
      },
      required: ['file', 'section', 'change'],
    },
    unproven_reason: { type: 'string', description: 'Why the claim resisted testing; empty unless UNPROVEN' },
    unaddressed: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          finding: { type: 'string' },
          evidence: { type: 'string' },
          file: { type: 'string' },
          section: { type: 'string' },
          change: { type: 'string' },
        },
        required: ['finding', 'evidence', 'file', 'section', 'change'],
      },
    },
    drift: { type: 'array', items: { type: 'string' } },
  },
  required: ['verdict', 'deciding_evidence', 'implied_change', 'unproven_reason', 'unaddressed', 'drift'],
}

return await pipeline(
  args.statements,
  (s) => parallel([
    () => agent(advocate(s), { label: `${s.id} advocate`, phase: 'Argue' }),
    () => agent(skeptic(s), { label: `${s.id} skeptic`, phase: 'Argue' }),
  ]),
  ([pro, con], s) => agent(judge(s, pro, con), { label: `${s.id} judge`, phase: 'Judge', schema: VERDICT })
    .then((ruling) => ({ id: s.id, statement: s.statement, section: s.section, ruling, advocate: pro, skeptic: con })),
)
```

A `null` ruling (an agent skipped or failed) is not a verdict: rerun that statement
alone, resuming the run, before synthesizing. Never fill one in yourself.

## 3. Synthesize

You, the session model, read every ruling. Check each OVERTURNED and UNPROVEN deciding
citation yourself before writing it down. Merge duplicate unaddressed findings across
statements. **Never soften an OVERTURNED verdict** because the design is otherwise good;
report it plainly and let the operator decide.

## 4. Write the output

`specs/<folder>/validation.md`, the full report:

```markdown
# Validation: <folder>

Run against <sha> on <date>. Statements confirmed by the operator before the run.

## Statements
| ID | Statement | Tests | Verdict |

## S1: <statement>
- **Verdict:** OVERTURNED
- **Deciding evidence:** …
- **Implied change:** design.md § … : …

## Not addressed by the design / ## Unproven, and why / ## Drift
```

The last three sections say "None." when empty; the not-addressed findings are the most
valuable output of the run, so list each with its evidence.

`specs/<folder>/validation-feedback.md`: copy
`${CLAUDE_PLUGIN_ROOT}/templates/validation-feedback.md` (or the project's
`specs/.templates/` override) and add one `- [ ]` thread per OVERTURNED statement,
UNPROVEN statement and not-addressed finding, under the matching heading:

```markdown
- [ ] S3 OVERTURNED: "The fingerprint is deterministic across Python versions."
    - Deciding evidence: `render.py:88` iterates a set; order varies by hash seed.
    - Proposed change: design.md § Key Interfaces: sort keys before hashing;
      requirements.md AC-2.3: add "stable across interpreter runs".
```

Not-addressed findings use `- [ ] Not addressed: <finding>` with the same two sub-bullets.
Every proposed change names the file and section. UPHELD statements get no thread.

## 5. Commit

Commit only the two files on the spec branch, checking the branch in the same command:

```bash
b=$(git branch --show-current) && [ "$b" != "<default branch>" ] && git add specs/<folder>/validation.md specs/<folder>/validation-feedback.md && git commit -m "spec: validation for <folder>"
```

Follow the project's commit conventions for the message trailer.

## 6. End

Report the verdict per statement in one line each, with the count of threads written.
Then print:

- With any thread in `validation-feedback.md`: `Next: /clear, then /spec:feedback validation <folder>`
- When every statement was UPHELD and nothing unaddressed was found (the feedback file
  has no threads): `Next: /clear, then /spec:tasks <folder>`
