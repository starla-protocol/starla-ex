# Implementation Plan

## Current State

Built:

- repo bootstrap
- Mix OTP application
- claimant scope docs

Not built:

- HTTP daemon
- core resource state
- seeded `Core` routes
- black-box claim automation

## Target

Pass the seeded `Core` claim over `HTTP Binding v1`.

Do not activate excluded optional surfaces.

## Implementation Sequence

1. define internal core state and resource records
2. implement the narrow HTTP surface required by the seeded report
3. close remaining `Core` HTTP vectors against the seeded report
4. run the external conformance runner from `starla-protocol`
5. only then broaden the claimant or bindings

## Acceptance

- `conformance/v1/claims/core-http-claim-seed.md` remains honest
- `conformance/v1/reports/core-http-report-seed.md` passes
- the external runner in `starla-protocol/scripts/run-core-http-claim.py` passes

## Deferred

- `Stream Binding v1`
- approvals
- tools
- channels
- persistence
- provider integration
- distributed execution
