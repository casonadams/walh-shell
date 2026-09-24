#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILED=0

assert_eq() {
  local expected="$1"
  local actual="$2"
  local desc="$3"
  if [ "$expected" != "$actual" ]; then
    echo "FAIL: $desc"
    echo "  expected: $expected"
    echo "  actual:   $actual"
    FAILED=1
  else
    echo "PASS: $desc"
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local desc="$3"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "FAIL: $desc"
    echo "  needle not found: $needle"
    FAILED=1
  else
    echo "PASS: $desc"
  fi
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  local desc="$3"
  if [[ "$haystack" == *"$needle"* ]]; then
    echo "FAIL: $desc"
    echo "  unexpected needle found: $needle"
    FAILED=1
  else
    echo "PASS: $desc"
  fi
}

# ---------------------------------------------------------------------------
# Test 1: Preview headless / non-interactive fallback
# ---------------------------------------------------------------------------
test_preview_headless_fallback() {
  local tmp_home
  tmp_home="$(mktemp -d)"

  local test_script
  test_script="$(
    cat <<EOF
HOME="$tmp_home"
eval "\$("$REPO_DIR/profile_helper.sh")"
walh preview 2>&1 || echo "PREVIEW_EXIT:\$?"
EOF
  )"

  # Running in non-interactive subshell (no TTY on stdin/stdout)
  local output
  output="$(bash -c "$test_script")"
  assert_contains "$output" "walh: interactive terminal required for preview" "walh preview detects non-interactive terminal"
  assert_contains "$output" "onedark" "walh preview fallback lists available themes"

  rm -rf "$tmp_home"
}

# ---------------------------------------------------------------------------
# Test 2: Preview fzf missing fallback
# ---------------------------------------------------------------------------
test_preview_fzf_missing() {
  local tmp_home
  tmp_home="$(mktemp -d)"

  local test_script
  test_script="$(
    cat <<EOF
HOME="$tmp_home"
eval "\$("$REPO_DIR/profile_helper.sh")"
# Shadow fzf
PATH="/usr/bin:/bin"
type fzf >/dev/null 2>&1 || true
# Ensure fzf is treated as not found
_walh_preview_test() {
  local PATH=""
  walh preview 2>&1 || echo "PREVIEW_FZF_FAIL:\$?"
}
_walh_preview_test
EOF
  )"

  local output
  output="$(bash -c "$test_script")"
  assert_contains "$output" "walh: fzf is required for interactive preview" "walh preview warns when fzf is missing"

  rm -rf "$tmp_home"
}

# ---------------------------------------------------------------------------
# Test 3: Bash completions function
# ---------------------------------------------------------------------------
test_bash_completions() {
  local test_script
  test_script="$(
    cat <<EOF
WALH_SHELL="$REPO_DIR"
. "$REPO_DIR/completions/walh.bash"

# Test 1: Complete command / themes at index 1
COMP_WORDS=(walh tog)
COMP_CWORD=1
_walh_bash_completion
echo "COMP_TOG:\${COMPREPLY[*]}"

COMP_WORDS=(walh gruv)
COMP_CWORD=1
_walh_bash_completion
echo "COMP_GRUV:\${COMPREPLY[*]}"

# Test 2: Complete subcommands at index 1
COMP_WORDS=(walh "")
COMP_CWORD=1
_walh_bash_completion
echo "COMP_ALL:\${COMPREPLY[*]}"

# Test 3: Complete options for 'list'
COMP_WORDS=(walh list --d)
COMP_CWORD=2
_walh_bash_completion
echo "COMP_LIST:\${COMPREPLY[*]}"

# Test 4: Complete options for 'random'
COMP_WORDS=(walh random li)
COMP_CWORD=2
_walh_bash_completion
echo "COMP_RANDOM:\${COMPREPLY[*]}"
EOF
  )"

  local output
  output="$(bash -c "$test_script")"
  assert_contains "$output" "COMP_TOG:toggle" "completions suggests toggle for 'tog'"
  assert_contains "$output" "COMP_GRUV:gruvbox-dark gruvbox-light" "completions suggests gruvbox themes for 'gruv'"
  assert_contains "$output" "current toggle list random preview help" "completions suggests subcommands"
  assert_contains "$output" "COMP_LIST:--dark" "completions suggests --dark for 'list'"
  assert_contains "$output" "COMP_RANDOM:light" "completions suggests light for 'random'"
}

# ---------------------------------------------------------------------------
# Test 4: Rich hook variables execution
# ---------------------------------------------------------------------------
test_rich_hook_variables() {
  local tmp_home
  tmp_home="$(mktemp -d)"
  local hooks_dir="$tmp_home/hooks"
  mkdir -p "$hooks_dir"

  # Create mock hook
  local hook_log="$tmp_home/hook.log"
  cat >"$hooks_dir/99-test-hook.sh" <<EOF
#!/bin/sh
echo "HOOK_THEME=\$WALH_THEME" >> "$hook_log"
echo "HOOK_MODE=\$WALH_MODE" >> "$hook_log"
echo "HOOK_BG=\$WALH_BG" >> "$hook_log"
echo "HOOK_FG=\$WALH_FG" >> "$hook_log"
EOF
  chmod +x "$hooks_dir/99-test-hook.sh"

  local test_script
  test_script="$(
    cat <<EOF
HOME="$tmp_home"
export WALH_SHELL_HOOKS="$hooks_dir"
eval "\$("$REPO_DIR/profile_helper.sh")"
walh gruvbox-dark >/dev/null 2>&1
EOF
  )"

  bash -c "$test_script"

  if [ -f "$hook_log" ]; then
    local hook_out
    hook_out="$(cat "$hook_log")"
    assert_contains "$hook_out" "HOOK_THEME=gruvbox-dark" "hook received WALH_THEME"
    assert_contains "$hook_out" "HOOK_MODE=dark" "hook received WALH_MODE"
    assert_contains "$hook_out" "HOOK_BG=#282828" "hook received WALH_BG"
    assert_contains "$hook_out" "HOOK_FG=#D5C4A1" "hook received WALH_FG"
  else
    echo "FAIL: hook log was not created"
    FAILED=1
  fi

  rm -rf "$tmp_home"
}

# ---------------------------------------------------------------------------
# Test 5: FZF_DEFAULT_OPTS sync with WALH_SYNC_FZF=1
# ---------------------------------------------------------------------------
test_fzf_sync() {
  local tmp_home
  tmp_home="$(mktemp -d)"

  # Without WALH_SYNC_FZF: FZF_DEFAULT_OPTS is untouched
  local test_script_nosync
  test_script_nosync="$(
    cat <<EOF
HOME="$tmp_home"
FZF_DEFAULT_OPTS="--height 40%"
eval "\$("$REPO_DIR/profile_helper.sh")"
walh gruvbox-dark >/dev/null 2>&1
echo "FZF_OPTS:\$FZF_DEFAULT_OPTS"
EOF
  )"
  local out_nosync
  out_nosync="$(bash -c "$test_script_nosync")"
  assert_eq "FZF_OPTS:--height 40%" "$out_nosync" "FZF_DEFAULT_OPTS is not changed when WALH_SYNC_FZF is unset"

  # With WALH_SYNC_FZF=1: FZF_DEFAULT_OPTS has theme colors
  local test_script_sync
  test_script_sync="$(
    cat <<EOF
HOME="$tmp_home"
FZF_DEFAULT_OPTS="--height 40%"
export WALH_SYNC_FZF=1
eval "\$("$REPO_DIR/profile_helper.sh")"
walh gruvbox-dark >/dev/null 2>&1
echo "FZF_OPTS:\$FZF_DEFAULT_OPTS"
EOF
  )"
  local out_sync
  out_sync="$(bash -c "$test_script_sync")"
  assert_contains "$out_sync" "--color=bg:#282828" "FZF_DEFAULT_OPTS synced background color"
  assert_contains "$out_sync" "fg:#D5C4A1" "FZF_DEFAULT_OPTS synced foreground color"

  rm -rf "$tmp_home"
}

# ---------------------------------------------------------------------------
# Runner
# ---------------------------------------------------------------------------
echo "Running Slice 4 Preview, Completions, and Hooks tests..."
test_preview_headless_fallback
test_preview_fzf_missing
test_bash_completions
test_rich_hook_variables
test_fzf_sync

if [ "$FAILED" -ne 0 ]; then
  echo "Some tests failed!"
  exit 1
fi

echo "All Slice 4 tests passed!"
