#!/usr/bin/env bash
# Roda cada tests/test-*.sh num processo próprio. Sai ≠ 0 se algum falhar.
# bash tests/test-*.sh só executa o primeiro arquivo (o resto vira argumento).
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
echo "TOTAL: $pass passou, $fail falhou"
[ "$fail" -eq 0 ]
