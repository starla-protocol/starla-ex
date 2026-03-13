# Implementation Plan

## Current State

Built:

- repo bootstrap
- Mix OTP application
- claimant scope docs
- initial `domain`, `store`, and `http` claimant split
- seeded in-memory state for definitions, instances, and sessions
- root route
- definition, instance, and session inspection and mutation routes
- claimant-aligned route tests for the current slice

Not built:

- execution routes
- `submit work`
- `delegate execution`
- context and execution snapshots
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
