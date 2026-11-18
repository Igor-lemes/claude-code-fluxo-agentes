#!/usr/bin/env bash
# Hook Stop: roda tsc só se há .ts/.tsx alterado. tsc pode levar dezenas de segundos, por isso
# roda no fim do turno e não a cada edição. Erro volta ao modelo (exit 2).
in=$(cat)
case "$in" in *'"stop_hook_active":true'*|*'"stop_hook_active": true'*) exit 0;; esac
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
[ -d node_modules ] || exit 0
git status --porcelain 2>/dev/null | grep -qE '\.tsx?$' || exit 0
out=$(timeout 150 npx tsc --noEmit 2>&1) && exit 0
echo "Typecheck falhou:" >&2
echo "$out" | head -30 >&2
exit 2
