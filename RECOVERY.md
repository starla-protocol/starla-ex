# Recovery

Use this file after context loss.

Keep it narrow.

Update it only when:

- the target claim changes
- the working branch changes
- the verification command changes
- the immediate next step changes materially

## Current Target

- repo: `starla-ex`
- branch: `implement/core-http-claimant`
- claim: `Core`
- binding: `HTTP Binding v1`

## Read Order

1. `README.md`
2. `AGENTS.md`
3. `IMPLEMENTATION_DECISIONS.md`
4. `IMPLEMENTATION_PLAN.md`

## Verify Current State

Run:

```bash
git branch --show-current
git status --short
mix test
```

Expected:

- branch is `implement/core-http-claimant`
- working tree is clean
- tests pass

## Current Boundary

- do not broaden beyond the seeded `Core` HTTP claim without an explicit scope change
- do not add approvals, tools, channels, stream, persistence, or product UI work here
- keep module boundaries aligned with `StarlaEx.Domain`, `StarlaEx.Store`, `StarlaEx.Runtime`, and `StarlaEx.HTTP`

## Immediate Next Step

After bootstrap:

- add the initial HTTP stack and claimant module split
- then implement the first seeded `Core` routes
