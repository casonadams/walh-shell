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

# ---------------------------------------------------------------------------
# Test 1: Hyphenated theme preservation in profile_helper.sh
# ---------------------------------------------------------------------------
test_hyphenated_theme_preservation() {
  local tmp_home
  tmp_home="$(mktemp -d)"

  # Test single hyphen: gruvbox-dark
  ln -s "$REPO_DIR/scripts/gruvbox-dark.sh" "$tmp_home/.walh_theme"
  local output
  output="$(HOME="$tmp_home" bash "$REPO_DIR/profile_helper.sh")"
  assert_contains "$output" "export WALH_THEME=gruvbox-dark" "profile_helper preserves single-hyphen theme name"

  # Test multi-hyphen: catppuccin-mocha
  rm -f "$tmp_home/.walh_theme"
  ln -s "$REPO_DIR/scripts/catppuccin-mocha.sh" "$tmp_home/.walh_theme"
  output="$(HOME="$tmp_home" bash "$REPO_DIR/profile_helper.sh")"
  assert_contains "$output" "export WALH_THEME=catppuccin-mocha" "profile_helper preserves multi-hyphen theme name"

  # Test non-hyphen: onedark
  rm -f "$tmp_home/.walh_theme"
  ln -s "$REPO_DIR/scripts/onedark.sh" "$tmp_home/.walh_theme"
  output="$(HOME="$tmp_home" bash "$REPO_DIR/profile_helper.sh")"
  assert_contains "$output" "export WALH_THEME=onedark" "profile_helper preserves non-hyphen theme name"

  rm -rf "$tmp_home"
}

# ---------------------------------------------------------------------------
# Test 2: Escape sequence batching & environment variable cleanup
# ---------------------------------------------------------------------------
test_escape_batching_and_cleanup() {
  local script="$REPO_DIR/scripts/gruvbox-dark.sh"
  local tmp_cache
  tmp_cache="$(mktemp -d)"

  # Source the theme in a subshell and check emitted output and unsetting of temp variables
  local check_script
  check_script="$(cat <<EOF
XDG_CACHE_HOME="$tmp_cache" . "$script"
# Check that temporary variables were unset
[ -z "\${walh_buffer+x}" ] || echo "LEAK: walh_buffer"
[ -z "\${color00+x}" ] || echo "LEAK: color00"
[ -z "\${color15+x}" ] || echo "LEAK: color15"
# Check that temporary functions were unset
type walh_append >/dev/null 2>&1 && echo "LEAK_FN: walh_append"
type put_template >/dev/null 2>&1 && echo "LEAK_FN: put_template"
# Check exported mode
echo "MODE:\$WALH_MODE"
echo "COLORFGBG:\$COLORFGBG"
EOF
)"

  local output
  output="$(bash -c "$check_script")"

  assert_contains "$output" "MODE:dark" "WALH_MODE is exported as dark"
  assert_contains "$output" "COLORFGBG:15;0" "COLORFGBG is exported for rxvt/ncurses"

  if [[ "$output" == *"LEAK"* ]]; then
    echo "FAIL: temporary variables or functions leaked into environment"
    echo "$output"
    FAILED=1
  else
    echo "PASS: temporary variables and functions cleaned up"
  fi

  rm -rf "$tmp_cache"
}

# ---------------------------------------------------------------------------
# Test 3: WALH_RESTORE=1 skips state.toml write
# ---------------------------------------------------------------------------
test_walh_restore_skips_state_write() {
  local script="$REPO_DIR/scripts/gruvbox-dark.sh"
  local tmp_cache
  tmp_cache="$(mktemp -d)"

  # With WALH_RESTORE=1, state.toml should NOT be created
  XDG_CACHE_HOME="$tmp_cache" WALH_RESTORE=1 bash -c ". \"$script\"" >/dev/null
  if [ -f "$tmp_cache/walh/state.toml" ]; then
    echo "FAIL: state.toml was created despite WALH_RESTORE=1"
    FAILED=1
  else
    echo "PASS: WALH_RESTORE=1 prevented state.toml creation"
  fi

  # Without WALH_RESTORE, state.toml SHOULD be created
  XDG_CACHE_HOME="$tmp_cache" bash -c ". \"$script\"" >/dev/null
  if [ -f "$tmp_cache/walh/state.toml" ]; then
    echo "PASS: state.toml created when WALH_RESTORE is empty"
    local state_content
    state_content="$(cat "$tmp_cache/walh/state.toml")"
    assert_contains "$state_content" 'mode = "dark"' "state.toml contains mode"
    assert_contains "$state_content" 'background = "#282828"' "state.toml contains background"
  else
    echo "FAIL: state.toml was not created when WALH_RESTORE is empty"
    FAILED=1
  fi

  # Modify mtime to an earlier timestamp, then source with WALH_RESTORE=1
  touch -t 202001010000 "$tmp_cache/walh/state.toml"
  local initial_mtime
  initial_mtime="$(stat -f "%m" "$tmp_cache/walh/state.toml")"

  XDG_CACHE_HOME="$tmp_cache" WALH_RESTORE=1 bash -c ". \"$script\"" >/dev/null
  local after_mtime
  after_mtime="$(stat -f "%m" "$tmp_cache/walh/state.toml")"

  assert_eq "$initial_mtime" "$after_mtime" "WALH_RESTORE=1 did not touch state.toml mtime"

  rm -rf "$tmp_cache"
}

# ---------------------------------------------------------------------------
# Test 4: generate_themes.py and script regeneration
# ---------------------------------------------------------------------------
test_generate_themes() {
  # Verify python compiler and ruff checks
  python3 -m py_compile "$REPO_DIR/generate_themes.py"
  echo "PASS: generate_themes.py compiles cleanly"

  uv run ruff check "$REPO_DIR/generate_themes.py"
  echo "PASS: ruff check passes on generate_themes.py"

  # Run generator and check all scripts
  uv run python "$REPO_DIR/generate_themes.py"
  echo "PASS: uv run generate_themes.py completed successfully"

  local script_count
  script_count=$(find "$REPO_DIR/scripts" -name "*.sh" | wc -l | tr -d ' ')
  if [ "$script_count" -lt 50 ]; then
    echo "FAIL: expected at least 50 theme scripts, found $script_count"
    FAILED=1
  else
    echo "PASS: found $script_count generated theme scripts"
  fi
}

# ---------------------------------------------------------------------------
# Test 5: ShellCheck gates
# ---------------------------------------------------------------------------
test_shellcheck() {
  shellcheck "$REPO_DIR/profile_helper.sh"
  echo "PASS: shellcheck passed for profile_helper.sh"

  shellcheck "$REPO_DIR/scripts/gruvbox-dark.sh"
  echo "PASS: shellcheck passed for scripts/gruvbox-dark.sh"

  shellcheck "$REPO_DIR/scripts/catppuccin-mocha.sh"
  echo "PASS: shellcheck passed for scripts/catppuccin-mocha.sh"
}

# ---------------------------------------------------------------------------
# Test 6: ShellSpec tests (Bash and Zsh)
# ---------------------------------------------------------------------------
test_shellspec() {
  if command -v shellspec >/dev/null 2>&1; then
    echo "Running shellspec (bash)..."
    shellspec -s bash
    if command -v zsh >/dev/null 2>&1; then
      echo "Running shellspec (zsh)..."
      shellspec -s zsh
    fi
  else
    echo "SKIP: shellspec not installed"
  fi
}

# ---------------------------------------------------------------------------
# Runner
# ---------------------------------------------------------------------------
echo "Running Slice 1 tests..."
test_hyphenated_theme_preservation
test_escape_batching_and_cleanup
test_walh_restore_skips_state_write
test_generate_themes
test_shellcheck
test_shellspec

if [ "$FAILED" -ne 0 ]; then
  echo "Some tests failed!"
  exit 1
fi

echo "All Slice 1 tests passed!"
