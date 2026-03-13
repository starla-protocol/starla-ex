# starla-ex Rules

## Purpose

`starla-ex` is the first Elixir claimant for `starla-protocol`.

The code should be a clear, practical reference implementation.

## Architecture Style

- keep the code meticulous and clean
- prefer clear boundaries over cleverness
- keep modules small and responsibility-aligned
- keep the code concrete by default
- use explicit structs, explicit transitions, and explicit errors
- design OTP boundaries for real runtime needs, not for architecture diagrams
- favor boring, testable code over framework ceremony

## Avoid

- umbrella-app decomposition without a real scale or ownership reason
- generic `Manager`, `Engine`, `Platform`, or `Kernel` abstractions
- behavior-heavy indirection before multiple credible implementations exist
- state represented as loose maps or boolean bags
- premature database, queue, pubsub, or plugin abstractions
- Phoenix, LiveView, or product UI concerns leaking into the claimant runtime

## Default Boundary Shape

- `StarlaEx.Domain` owns nouns, states, and protocol-facing records
- `StarlaEx.Store` owns concrete in-memory state and mutations
- `StarlaEx.Runtime` owns synthetic progression and background behavior
- `StarlaEx.HTTP` owns route mapping, request parsing, and response mapping

## Working Rule

If a new abstraction does not make the claimant clearer, smaller, or more realistic, do not add it.
