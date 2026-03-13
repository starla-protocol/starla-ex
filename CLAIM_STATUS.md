# Claim Status

## Current Target

- claim: `Core`
- binding: `HTTP Binding v1`
- protocol seed:
  - `/home/alan/projects/starla-protocol/conformance/v1/claims/core-http-claim-seed.md`
  - `/home/alan/projects/starla-protocol/conformance/v1/reports/core-http-report-seed.md`

## Current Decision

- local status: provisional pass
- basis:
  - route-level claimant tests in `test/starla_ex/http/router_test.exs`
  - manual external run through `starla-protocol/scripts/run-core-http-claim.py`

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

- automate the external claim path inside this repo
- record a dated implementation report in `starla-protocol`
- keep the claimant surface narrow until that report is recorded
