# Implementation Decisions

## Purpose

These decisions apply to the first Elixir claimant only.

They exist to reduce avoidable implementation drift while keeping the claimant narrow.

## Style

- concrete by default
- explicit structs and explicit lifecycle atoms
- small literal modules
- OTP processes only at real seams
- behaviors only at real seams
- JSON and HTTP at the edges
- explicit domain and HTTP errors

## Chosen Libraries

- HTTP server: `Bandit`
- routing: `Plug.Router`
- JSON: `Jason`
- testing: `ExUnit`

## Not Chosen

- `Phoenix`
- `Ecto`
- `Postgres`
- `Oban`
- umbrella apps
- generic behavior-heavy service frameworks

## Runtime Shape

- single OTP application
- in-memory state only
- deterministic synthetic execution engine
- no background job system
- no distributed node behavior
- no plugin runtime

## State Shape

- explicit structs for `agent definition`, `agent instance`, `session`, and `execution`
- explicit lifecycle atoms
- one concrete in-memory store process first
- opaque externally visible IDs

## Persistence

No database is part of the first claimant.

Do not add persistence before the seeded `Core` claim is proven.

## UI

No UI is part of this repo.

Do not add LiveView, Phoenix UI, or operator tooling without an explicit scope change.

## Testing

- implement against the seeded `Core` claim and report
- prefer route and state-machine tests over mock-heavy unit tests
- add black-box checks as the public surface appears
- use the external runner in `starla-protocol` as the authoritative claim path

## Deferral Rule

If a decision does not change the first claimant scope, defer it.
