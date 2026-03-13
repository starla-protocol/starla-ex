# Claim Status

## Current Target

- claim: `Core + Tools`
- binding: `HTTP Binding v1`
- protocol seed:
  - `/home/alan/projects/starla-protocol/conformance/v1/claims/core-tools-http-claim-seed.md`
  - `/home/alan/projects/starla-protocol/conformance/v1/reports/core-tools-http-report-seed.md`

## Current Decision

- local status: provisional local pass
- basis:
  - route-level claimant tests in `test/starla_ex/http/router_test.exs`
  - automated external run through `scripts/run-core-tools-http-claim.sh`

## Covered Surface

- agent definition routes
- agent instance routes
- session routes
- execution listing and inspection
- `submit work`
- `cancel execution`
- `delegate execution`
- tool definition listing and inspection
- `invoke tool`
- context inspection
- deterministic synthetic progression

## Remaining Work

- execute and record the dated external `Core + Tools` report
- keep excluded tool surfaces excluded
