#!/usr/bin/env bash
set -euo pipefail

if [ -n "${BASH_SOURCE[0]:-}" ]; then
  SCRIPT_PATH="${BASH_SOURCE[0]}"
elif [ -n "${ZSH_VERSION:-}" ]; then
  # shellcheck disable=SC2296
  eval 'SCRIPT_PATH="${(%):-%x}"'
else
  SCRIPT_PATH="$0"
fi
REPO_DIR="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"

echo "=== 1. ShellCheck Verification ==="
shellcheck \
  "$REPO_DIR/profile_helper.sh" \
  "$REPO_DIR/walh.sh" \
  "$REPO_DIR/list-themes.sh" \
  "$REPO_DIR/completions/walh.bash" \
  "$REPO_DIR/test/test_core.sh" \
  "$REPO_DIR/test/test_walh_cli.sh" \
  "$REPO_DIR/test/test_preview_and_hooks.sh" \
  "$REPO_DIR/scripts/gruvbox-dark.sh" \
  "$REPO_DIR/scripts/catppuccin-mocha.sh"
echo "ShellCheck passed with 0 warnings."

if command -v shfmt >/dev/null 2>&1; then
  echo "=== 2. shfmt Format Verification ==="
  shfmt -d -i 2 -ci \
    "$REPO_DIR/profile_helper.sh" \
    "$REPO_DIR/walh.sh" \
    "$REPO_DIR/list-themes.sh" \
    "$REPO_DIR/completions/walh.bash" \
    "$REPO_DIR/test/test_core.sh" \
    "$REPO_DIR/test/test_walh_cli.sh" \
    "$REPO_DIR/test/test_preview_and_hooks.sh" \
    "$REPO_DIR/test/run_all.sh"
  echo "shfmt passed."
fi

echo "=== 3. Python Quality Gates ==="
uv run ruff check "$REPO_DIR/generate_themes.py"
python3 -m py_compile "$REPO_DIR/generate_themes.py"
echo "Python checks passed."

echo "=== 3. Core & Dispatcher Test Suites ==="
"$REPO_DIR/test/test_core.sh"

echo "=== 4. Multi-Shell BDD Matrix (ShellSpec) ==="
if command -v shellspec >/dev/null 2>&1; then
  echo "Running shellspec with bash..."
  shellspec -s bash
  if command -v zsh >/dev/null 2>&1; then
    echo "Running shellspec with zsh..."
    shellspec -s zsh
  fi
fi

echo "=== All test suites and quality gates passed successfully! ==="
