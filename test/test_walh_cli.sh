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
# Test 1: walh <theme> applies theme and exports variables
# ---------------------------------------------------------------------------
test_apply_theme() {
  local tmp_home
  tmp_home="$(mktemp -d)"

  local test_script
  test_script="$(
    cat <<EOF
HOME="$tmp_home"
eval "\$("$REPO_DIR/profile_helper.sh")"
walh onedark
echo "THEME:\$WALH_THEME"
echo "MODE:\$WALH_MODE"
EOF
  )"

  local output
  output="$(bash -c "$test_script")"
  assert_contains "$output" "THEME:onedark" "walh onedark exports WALH_THEME=onedark"
  assert_contains "$output" "MODE:dark" "walh onedark exports WALH_MODE=dark"

  rm -rf "$tmp_home"
}

# ---------------------------------------------------------------------------
# Test 2: walh current outputs theme, mode, and background
# ---------------------------------------------------------------------------
test_current() {
  local tmp_home
  tmp_home="$(mktemp -d)"

  local test_script
  test_script="$(
    cat <<EOF
HOME="$tmp_home"
eval "\$("$REPO_DIR/profile_helper.sh")"
walh gruvbox-dark
walh current
EOF
  )"

  local output
  output="$(bash -c "$test_script")"
  assert_contains "$output" "Active theme: gruvbox-dark (dark)" "walh current prints theme name and mode"
  assert_contains "$output" "Background: #282828" "walh current prints background color"

  rm -rf "$tmp_home"
}

# ---------------------------------------------------------------------------
# Test 3: walh toggle switches between dark and light themes
# ---------------------------------------------------------------------------
test_toggle() {
  local tmp_home
  tmp_home="$(mktemp -d)"

  local test_script
  test_script="$(
    cat <<EOF
HOME="$tmp_home"
eval "\$("$REPO_DIR/profile_helper.sh")"
# Start on onedark
walh onedark
echo "START:\$WALH_THEME:\$WALH_MODE"

# Toggle to light (should pick paired onelight)
walh toggle
echo "TOGGLE1:\$WALH_THEME:\$WALH_MODE"

# Switch to a specific light theme
walh github-light
echo "CUSTOM_LIGHT:\$WALH_THEME:\$WALH_MODE"

# Toggle to dark (should return to onedark)
walh toggle
echo "TOGGLE2:\$WALH_THEME:\$WALH_MODE"

# Toggle again (should return to github-light)
walh toggle
echo "TOGGLE3:\$WALH_THEME:\$WALH_MODE"
EOF
  )"

  local output
  output="$(bash -c "$test_script")"
  assert_contains "$output" "START:onedark:dark" "initial theme is onedark:dark"
  assert_contains "$output" "TOGGLE1:onelight:light" "first toggle switches to paired light theme"
  assert_contains "$output" "CUSTOM_LIGHT:github-light:light" "custom light theme applied"
  assert_contains "$output" "TOGGLE2:onedark:dark" "toggle back returns to onedark"
  assert_contains "$output" "TOGGLE3:github-light:light" "toggle returns to github-light"

  rm -rf "$tmp_home"
}

# ---------------------------------------------------------------------------
# Test 4: walh list with --dark, --light, and unfiltered
# ---------------------------------------------------------------------------
test_list() {
  local tmp_home
  tmp_home="$(mktemp -d)"

  local test_script
  test_script="$(
    cat <<EOF
HOME="$tmp_home"
eval "\$("$REPO_DIR/profile_helper.sh")"
echo "===ALL==="
walh list
echo "===DARK==="
walh list --dark
echo "===LIGHT==="
walh list --light
EOF
  )"

  local output
  output="$(bash -c "$test_script")"

  # All themes should have both onedark and solarized-light
  assert_contains "$output" "onedark" "all themes contains onedark"
  assert_contains "$output" "solarized-light" "all themes contains solarized-light"

  # Dark filter
  local dark_part
  dark_part="$(echo "$output" | sed -n '/===DARK===/,/===LIGHT===/p')"
  assert_contains "$dark_part" "onedark" "dark themes contains onedark"
  assert_not_contains "$dark_part" "solarized-light" "dark themes excludes solarized-light"

  # Light filter
  local light_part
  light_part="$(echo "$output" | sed -n '/===LIGHT===/,$p')"
  assert_contains "$light_part" "solarized-light" "light themes contains solarized-light"
  assert_not_contains "$light_part" "onedark" "light themes excludes onedark"

  rm -rf "$tmp_home"
}

# ---------------------------------------------------------------------------
# Test 5: walh random [dark|light]
# ---------------------------------------------------------------------------
test_random() {
  local tmp_home
  tmp_home="$(mktemp -d)"

  local test_script
  test_script="$(
    cat <<EOF
HOME="$tmp_home"
eval "\$("$REPO_DIR/profile_helper.sh")"
walh random dark
echo "RANDOM_DARK_MODE:\$WALH_MODE"
walh random light
echo "RANDOM_LIGHT_MODE:\$WALH_MODE"
EOF
  )"

  local output
  output="$(bash -c "$test_script")"
  assert_contains "$output" "RANDOM_DARK_MODE:dark" "walh random dark sets mode to dark"
  assert_contains "$output" "RANDOM_LIGHT_MODE:light" "walh random light sets mode to light"

  rm -rf "$tmp_home"
}

# ---------------------------------------------------------------------------
# Test 6: Error handling
# ---------------------------------------------------------------------------
test_errors() {
  local tmp_home
  tmp_home="$(mktemp -d)"

  local test_script
  test_script="$(
    cat <<EOF
HOME="$tmp_home"
eval "\$("$REPO_DIR/profile_helper.sh")"

# Non-existent theme
walh non-existent-theme-xyz 2>&1 || echo "CAUGHT_NOT_FOUND"

# Invalid characters injection
walh "foo;rm -rf /" 2>&1 || echo "CAUGHT_INVALID_NAME"

# Invalid list option
walh list --bogus 2>&1 || echo "CAUGHT_INVALID_LIST_OPT"

# Invalid random option
walh random --bogus 2>&1 || echo "CAUGHT_INVALID_RANDOM_OPT"
EOF
  )"

  local output
  output="$(bash -c "$test_script")"
  assert_contains "$output" "CAUGHT_NOT_FOUND" "non-existent theme returns error"
  assert_contains "$output" "CAUGHT_INVALID_NAME" "theme name with special characters is rejected"
  assert_contains "$output" "CAUGHT_INVALID_LIST_OPT" "invalid list option returns error"
  assert_contains "$output" "CAUGHT_INVALID_RANDOM_OPT" "invalid random option returns error"

  rm -rf "$tmp_home"
}

# ---------------------------------------------------------------------------
# Runner
# ---------------------------------------------------------------------------
echo "Running Slice 3 CLI tests..."
test_apply_theme
test_current
test_toggle
test_list
test_random
test_errors

if [ "$FAILED" -ne 0 ]; then
  echo "Some CLI tests failed!"
  exit 1
fi

echo "All Slice 3 CLI tests passed!"
