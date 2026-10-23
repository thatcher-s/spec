---
name: design
description: "Draft the technical design from approved requirements, then recommend whether to run validate."
argument-hint: "[spec folder]"
disable-model-invocation: true
---

# Design

## Model gate (mandatory, before anything else)

This skill requires **Opus or Fable**. Before reading any file or calling any tool, check the
model ID you are running as. If it is **a Sonnet or Haiku model**, do not start the skill, not even
partly: print exactly the two lines below and end your turn.

```
/spec:design needs Opus or Fable; this session is running <your model ID>.
Next: /model fable (or /model opus), then run /spec:design again.
```

This is not a recommendation. A request to proceed anyway does not lift it; only switching
the session's model does.

Read and follow `${CLAUDE_PLUGIN_ROOT}/shared/preamble.md` and
`${CLAUDE_PLUGIN_ROOT}/shared/conventions.md`. The preamble's gate for this skill:

| Skill | Checks |
|---|---|
| `design` | requirements |

If the folder holds `spec.md` and no `requirements.md`, it is an express spec: stop and
say the upgrade to the full flow starts with `/spec:reqs <folder>`.

**Templates.** For every template named below, use `specs/.templates/<name>.md` when the
project has one, otherwise `${CLAUDE_PLUGIN_ROOT}/templates/<name>.md`.

## 1. Read

- `specs/<folder>/requirements.md` in full, and `requirements-feedback.md` for the
  settled threads behind its current wording.
- The config's Product doc sections the requirements cite.
- The code the requirements touch: every module that changes, its callers, its tests, and
  the existing patterns the new code should follow. Read enough that Key Interfaces and
  Affected Modules are grounded in real files, not guesses.

## 2. Draft `design.md`

Draft from the `design` template. Content each section needs:

- **Approach:** the high-level strategy, and the principle behind it.
- **Data Flow:** how data moves through the system, from input to every output and side
  effect. A diagram in a code block helps when there are more than three hops.
- **Key Interfaces:** copy-paste-ready signatures with types, defaults and a docstring
  each, for every new or changed function, class, schema, file format or command. Each
  heading cites the criteria it implements, e.g. `### Config loader (AC-1, AC-3.2)`; at
  least three headings carry AC references.
- **Affected Modules:** a table with File, Change Type, Description columns listing every
  file that changes. Consider each file on the config's Docs on delivery list (default
  `README.md` and `CLAUDE.md`) and add a row for each one that needs updating whenever the
  change adds or renames user-facing behavior, commands, config options or workflows.
- **Alternatives:** at least two, each with the reason it was rejected.
- **Risks:** what could go wrong and the tradeoff accepted, including failure modes that
  produce wrong output instead of an error.
- **Appendix A: Worked Examples:** verbatim inputs and outputs (files, payloads, command
  output) for every artifact the implementation reads or writes. At least three; six to
  ten for a complex spec. They become test fixtures, so make them exact.
- **Appendix B: Error Messages:** a table with AC, Trigger, Exit, Destination, Message
  columns, giving the exact text with placeholders. Tests assert on these strings.
- **Appendix C** (optional): pseudocode for any algorithm that must behave identically
  at more than one call site.

Every AC in `requirements.md` is covered somewhere in Key Interfaces or Data Flow. If
drafting shows a criterion is wrong or missing, do not renumber: raise it as a thread in
`requirements-feedback.md` or, for an obvious gap, add a new number at the end of its
group and log why.

Write `specs/<folder>/design.md`, then `specs/<folder>/design-feedback.md` from the
`design-feedback` template: the same section headings as `design.md`, no threads.

## 3. Record decisions

Every choice made while drafting (an AskUserQuestion answer, a library or pattern picked
between real options, an interpretation of a criterion) gets a `D-n` row continuing the
numbering in the Decision Log of `requirements.md`, unless the design template carries
its own Decision Log section, in which case log it there. One line of rationale each.

Do not iterate on the draft in this session; review happens through the feedback file
and `/spec:feedback`. A small correction the user makes in chat before the session ends is
applied directly and logged.

## 4. Recommend validate or not

Check the design against the validate signals. Recommend `/spec:validate` when it has any
of:

- **new machinery** that has never run
- **hard-to-undo effects:** migrations, deletions, writes to an external system
- **silent failure:** wrong output instead of an error
- **internal tension:** a principle applied in one place and its opposite elsewhere

Print exactly one of these, with one line of reasoning naming the signal (or the absence
of all four):

```
Recommendation: run /spec:validate next — <reason>. Size: medium (2–3 statements).
Recommendation: run /spec:validate next — <reason>. Size: big (5–7 statements).
Recommendation: skip to /spec:tasks — <reason>.
```

The size is medium for a design with one or two risky decisions, big when several
decisions carry the risk or the design spans many modules.

## 5. Hand off

Tell the user, briefly, with every file as an absolute path (conventions.md, Paths shown
to the user): that `specs/<folder>/design.md` is ready, to look closest at
Affected Modules and Alternatives, that feedback goes in `specs/<folder>/design-feedback.md`
as `- [ ]` items under the heading each concerns, and the decisions logged while drafting.

End with the Next line:

```
Next: /clear, then /spec:feedback design <folder>          (feedback written)
Next: /clear, then /spec:validate <folder>        (no feedback, validate recommended)
Next: /clear, then /spec:tasks <folder>           (no feedback, validate skipped)
```
