# starla-ex

Elixir reference claimant for `starla-protocol`.

## Status

- state: early implementation
- target claim:
  - `Core`
  - `HTTP Binding v1`
- protocol repo:
  - `https://github.com/starla-protocol/starla-protocol`

## Scope

This repo targets the first Elixir claimant for:

- `conformance/v1/claims/core-http-claim-seed.md`

Included:

- single OTP application
- single local HTTP daemon
- in-memory state
- deterministic synthetic execution behavior
- only the public surface needed for the seeded `Core` claim
- first `Core` HTTP slice in progress

Excluded:

- `Stream Binding v1`
- `Core + Approvals`
- `Core + Tools`
- `Core + Channels`
- durability across restart
- distribution across nodes
- provider integration
- workflow and automation behavior
- product UI and packaging

## Immediate Goal

Implement enough public HTTP behavior to satisfy:

- `conformance/v1/claims/core-http-claim-seed.md`
- `conformance/v1/reports/core-http-report-seed.md`

Implementation sequence:

- `SCOPE.md`
- `IMPLEMENTATION_PLAN.md`
- `IMPLEMENTATION_DECISIONS.md`
- `CLAIM_STATUS.md`
- `RECOVERY.md`

Claim automation:

- `scripts/run-core-http-claim.sh`
- `.github/workflows/core-http-claim.yml`

## Development

Run:

```bash
mix test
./scripts/run-core-http-claim.sh
```
