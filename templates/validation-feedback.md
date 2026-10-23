# Validation Feedback

## Overturned

<!-- One thread per OVERTURNED statement, in the format from design.md § 7.3:
- [ ] S3 OVERTURNED: "The fingerprint is deterministic across process restarts."
    - Deciding evidence: `render.py:88` iterates a set; order varies by hash seed.
    - Proposed change: design.md § Key Interfaces: sort keys before hashing;
      requirements.md AC-2.3: add "stable across interpreter runs".
-->

## Unproven

<!-- One thread per UNPROVEN statement, in the same format:
- [ ] S5 UNPROVEN: "The retry queue drains within one minute under normal load."
    - Deciding evidence: no load test exercises the queue; `worker.py:140` has no
      timing instrumentation to check against.
    - Proposed change: design.md § Risks & Tradeoffs: record the one-minute bound as
      an assumption, not a guarantee, until a load test exists.
-->

## Not addressed by the design

<!-- One thread per finding the skeptic raised that the design does not address,
     even where the statement itself was UPHELD:
- [ ] S2 skeptic finding: concurrent writers to the same record are never discussed.
    - Deciding evidence: `store.py:52` has no lock and no optimistic-concurrency
      check around the write.
    - Proposed change: design.md § Risks & Tradeoffs: add a risk for concurrent
      writers; requirements.md: add an AC for the conflict behavior.
-->
