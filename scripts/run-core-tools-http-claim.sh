#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

protocol_dir="${STARLA_PROTOCOL_DIR:-/home/alan/projects/starla-protocol}"
runner_path="$protocol_dir/scripts/run-core-tools-http-claim.py"
port="${STARLA_EX_HTTP_PORT:-4747}"
base_url="http://127.0.0.1:${port}"
implementation_version="$(git rev-parse --short HEAD)"
output_path="${STARLA_EX_CLAIM_OUTPUT:-/tmp/starla-ex-core-tools-http-report.md}"

if [[ ! -f "$runner_path" ]]; then
  printf 'missing protocol runner: %s\n' "$runner_path" >&2
  exit 1
fi

mix format --check-formatted
mix test

cleanup() {
  if [[ -n "${server_pid:-}" ]] && kill -0 "$server_pid" 2>/dev/null; then
    kill "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
  fi
}

trap cleanup EXIT

STARLA_EX_HTTP_PORT="$port" mix run --no-halt >/tmp/starla-ex-core-tools-http-claim.log 2>&1 &
server_pid="$!"

for _ in $(seq 1 100); do
  if curl -fsS "$base_url/" >/dev/null 2>&1; then
    python3 "$runner_path" \
      --base-url "$base_url" \
      --implementation-name starla-ex \
      --implementation-version "$implementation_version" \
      --runner-identity scripts/run-core-tools-http-claim.py \
      --output "$output_path"
    printf 'claim: ok\n'
    exit 0
  fi

  sleep 0.1
done

printf 'server did not become ready at %s\n' "$base_url" >&2
exit 1
