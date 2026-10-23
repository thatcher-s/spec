# Design: <Feature Name>

## Approach

<!-- High-level strategy. Why this approach over alternatives? -->

## Data Flow

<!-- Describe or diagram how data moves through the system for this feature.
     ASCII diagrams, prose, or Mermaid are all fine. -->

```
Input → [Module A] → [Module B] → Output
```

## Key Interfaces / Contracts (AC-N, AC-M)

<!-- Section titles should cite which ACs they implement. Include copy-paste-ready
     function or type signatures, with types, defaults, and docstrings. Implementers
     will copy these verbatim into module files. -->

```
# Example: new or changed signatures, in the project's own language
def my_function(param: Type, *, flag: bool = False) -> ReturnType:
    """One-line docstring."""
    ...
```

## Affected Modules

<!-- The canonical list of every file that changes. If an implementer finds
     themselves modifying a file not in this table, they should stop and check the
     design. When the change affects user-facing behavior, commands, config or
     workflows, include the files specs/.config.md's "Docs on delivery" section
     names (README.md and CLAUDE.md when the config is silent). -->

| File | Change Type | Description |
|------|-------------|-------------|
| `src/...` | New / Modified / Deleted | What changes |

## Alternatives Considered

<!-- What else was evaluated and why it was rejected. Prevents relitigating decisions. -->

- **Option A**: [description] — rejected because [reason]
- **Option B**: [description] — rejected because [reason]

## Risks & Tradeoffs

<!-- What could go wrong? What are we accepting as a known limitation?
     New machinery that has never run, hard-to-undo effects (migrations, deletions,
     writes to an external system), silent failure, or internal tension between two
     applied principles are signals this spec may be worth a /spec:validate pass
     before tasks are written — call that out here if any apply. -->

- Risk: [X] — mitigation: [Y]
- Tradeoff: [X] in exchange for [Y]

## Appendix A: Worked Examples

<!-- Verbatim YAML/JSON/Markdown for every artifact the implementation must produce.
     Implementers copy these as fixture seeds for tests and as exemplars for output
     formatting. Include at least one example per new file format the implementation
     reads or writes. Target: 3-10 complete examples depending on spec complexity. -->

### A.1 [Artifact name] ([context])

```yaml
# complete, copy-pasteable example
```

## Appendix B: Error Message Reference

<!-- Every operator-facing error/warning message in one table. Implementers
     reproduce these strings verbatim — test assertions match exact text. Define
     as module-level constants in a messages module; import from both production
     code and tests. -->

| AC | Trigger | Exit | Destination | Exact message |
|----|---------|------|-------------|---------------|
| AC-N.M | [condition] | [code] | stderr/stdout | `[verbatim message with {placeholders}]` |

<!-- Optional: Appendix C for algorithm specifications, pseudocode, or hash
     computation references. Include when an algorithm must be implemented
     identically across multiple call sites. -->
