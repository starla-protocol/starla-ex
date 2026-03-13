# Claim Status

## Current Target

- claim: `Core`
- binding: `HTTP Binding v1`
- protocol seed:
  - `/home/alan/projects/starla-protocol/conformance/v1/claims/core-http-claim-seed.md`
  - `/home/alan/projects/starla-protocol/conformance/v1/reports/core-http-report-seed.md`

## Current Decision

- local status: dated external pass recorded
- basis:
  - route-level claimant tests in `test/starla_ex/http/router_test.exs`
  - automated external run through `scripts/run-core-http-claim.sh`
  - recorded report at `/home/alan/projects/starla-protocol/conformance/v1/reports/starla-ex-core-http-2026-03-13.md`

## Covered Surface

- agent definition routes
- agent instance routes
- session routes
- execution listing and inspection
- `submit work`
- `cancel execution`
- `delegate execution`
- context inspection
- deterministic synthetic progression

## Remaining Work

- review and merge `implement/core-http-claimant`
- keep the claimant surface narrow until merge
