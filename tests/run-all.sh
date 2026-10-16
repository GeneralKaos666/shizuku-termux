#!/usr/bin/env bash
# Run every host test (tests/test-*.sh) and exit non-zero if any fails.
# Each test runs in its own bash process; they are independent.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

pass=0
fail=0
for t in "$SCRIPT_DIR"/test-*.sh; do
    name="$(basename "$t")"
    if bash "$t"; then
        printf 'PASS  %s\n' "$name"
        pass=$((pass + 1))
    else
        printf 'FAIL  %s\n' "$name"
        fail=$((fail + 1))
    fi
done

echo "----------------------------------------"
echo "TOTAL: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
