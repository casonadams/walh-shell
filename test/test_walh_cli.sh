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
# Test 2: walh current outputs theme and mode
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
  assert_not_contains "$output" "Background:" "walh current no longer prints the background color"

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
# Test 7: walh reset restores terminal defaults and forgets the theme
# ---------------------------------------------------------------------------
test_reset() {
  local tmp_home
  tmp_home="$(mktemp -d)"

  local output
  output="$(
    env -u TMUX TERM=xterm-256color HOME="$tmp_home" XDG_STATE_HOME= bash -c "
      eval \"\$('$REPO_DIR/profile_helper.sh')\"
      walh onedark >/dev/null
      [ -L \"\$HOME/.local/state/walh/current_theme\" ] && echo LINK_BEFORE
      walh reset >\"\$HOME/reset.out\"
      od -An -c \"\$HOME/reset.out\" | tr -d ' \n'
      echo
      [ -e \"\$HOME/.local/state/walh/current_theme\" ] || echo LINK_GONE
      [ -e \"\$HOME/.local/state/walh/state.toml\" ] || echo STATE_GONE
      echo \"THEME:\${WALH_THEME:-unset}\"
    "
  )"

  assert_contains "$output" "LINK_BEFORE" "theme symlink exists before reset"
  assert_contains "$output" '033]104033' "reset emits OSC 104 palette reset"
  assert_contains "$output" '033]111033' "reset emits OSC 111 background reset"
  assert_contains "$output" "LINK_GONE" "reset removes current_theme"
  assert_contains "$output" "STATE_GONE" "reset removes state.toml"
  assert_contains "$output" "THEME:unset" "reset unsets WALH_THEME"

  rm -rf "$tmp_home"
}

# ---------------------------------------------------------------------------
# Test 8: walh auto follows the system appearance
# ---------------------------------------------------------------------------
test_auto() {
  local tmp_home
  tmp_home="$(mktemp -d)"
  mkdir -p "$tmp_home/bin"
  # Stub `defaults`: dark when STUB_APPEARANCE=Dark, otherwise fail like a light macOS
  cat >"$tmp_home/bin/defaults" <<'STUB'
#!/bin/sh
[ "$STUB_APPEARANCE" = "Dark" ] && echo Dark && exit 0
exit 1
STUB
  chmod +x "$tmp_home/bin/defaults"

  local output
  output="$(
    env -u TMUX TERM=xterm-256color HOME="$tmp_home" PATH="$tmp_home/bin:$PATH" XDG_STATE_HOME= bash -c "
      OSTYPE=darwin24
      eval \"\$('$REPO_DIR/profile_helper.sh')\"
      walh onedark >/dev/null
      walh onelight >/dev/null
      STUB_APPEARANCE=Dark walh auto >/dev/null
      echo \"DARK_SYSTEM:\$WALH_THEME:\$WALH_MODE\"
      STUB_APPEARANCE=Dark walh auto >/dev/null
      echo \"NOOP:\$WALH_THEME\"
      STUB_APPEARANCE=Light walh auto >/dev/null
      echo \"LIGHT_SYSTEM:\$WALH_THEME:\$WALH_MODE\"
    "
  )"

  assert_contains "$output" "DARK_SYSTEM:onedark:dark" "auto switches to the last dark theme when the system is dark"
  assert_contains "$output" "NOOP:onedark" "auto is a no-op when the mode already matches"
  assert_contains "$output" "LIGHT_SYSTEM:onelight:light" "auto switches to the last light theme when the system is light"

  rm -rf "$tmp_home"
}

# ---------------------------------------------------------------------------
# Test 9: walh palette shows swatches and --check verifies the terminal
# ---------------------------------------------------------------------------
test_palette() {
  local tmp_home output
  tmp_home="$(mktemp -d)"

  output="$(env -u TMUX HOME="$tmp_home" WALH_SHELL="$REPO_DIR" bash -c ". '$REPO_DIR/walh.sh'; walh palette" | od -An -c | tr -d ' \n')"
  assert_contains "$output" "Grayramp232-255" "walh palette prints the gray ramp"
  assert_contains "$output" "[48;5;255m" "walh palette paints color 255"

  if command -v python3 >/dev/null 2>&1; then
    output="$(python3 "$REPO_DIR/test/fake_terminal.py" "$REPO_DIR" nord)"
    assert_contains "$output" "256/256 colors match the theme" "--check passes when the terminal reports the theme palette"
    output="$(python3 "$REPO_DIR/test/fake_terminal.py" "$REPO_DIR" nord corrupt)"
    assert_contains "$output" "mismatch 100" "--check reports a color the terminal got wrong"
    output="$(python3 "$REPO_DIR/test/fake_terminal.py" "$REPO_DIR" nord mute)"
    assert_contains "$output" "256 unanswered" "--check reports a terminal that ignores queries"
  fi

  rm -rf "$tmp_home"
}

# ---------------------------------------------------------------------------
# Test: the picker lists dark before light, applies the choice, cancels cleanly
# ---------------------------------------------------------------------------
test_pick() {
  local tmp_home
  tmp_home="$(mktemp -d)"
  mkdir -p "$tmp_home/bin"
  cat >"$tmp_home/bin/fzf" <<'EOF'
#!/bin/sh
cat >"$FAKE_FZF_ROWS"
[ -n "$FAKE_FZF_PICK" ] && grep "^$FAKE_FZF_PICK " "$FAKE_FZF_ROWS"
exit 0
EOF
  chmod +x "$tmp_home/bin/fzf"

  local test_script
  test_script="$(
    cat <<EOF
HOME="$tmp_home"
PATH="$tmp_home/bin:\$PATH"
export FAKE_FZF_ROWS="$tmp_home/rows"
eval "\$("$REPO_DIR/profile_helper.sh")"
FAKE_FZF_PICK=gruvbox-light _walh_pick >/dev/null
echo "PICKED:\$WALH_THEME"
FAKE_FZF_PICK= _walh_pick >/dev/null
echo "CANCELLED:\$WALH_THEME"
echo "ALL_ROWS:\$(grep -n ' light\$' "$tmp_home/rows" | head -n1 | cut -d: -f1) \$(grep -n ' dark\$' "$tmp_home/rows" | tail -n1 | cut -d: -f1)"
echo "BARE:\$(walh | head -n1)"
EOF
  )"

  local output
  output="$(bash -c "$test_script")"
  assert_contains "$output" "PICKED:gruvbox-light" "the picker applies the chosen theme"
  assert_contains "$output" "CANCELLED:gruvbox-light" "the picker keeps the theme when cancelled"
  assert_contains "$output" "BARE:Usage: walh" "bare walh prints help when output is not a terminal"

  local line first_light last_dark
  line="$(printf '%s\n' "$output" | grep '^ALL_ROWS:')"
  first_light="$(printf '%s' "$line" | cut -d' ' -f1 | cut -d: -f2)"
  last_dark="$(printf '%s' "$line" | cut -d' ' -f2)"
  if [ -n "$first_light" ] && [ "$last_dark" -lt "$first_light" ]; then
    echo "PASS: the picker lists every dark theme before any light theme"
  else
    echo "FAIL: the picker lists every dark theme before any light theme ($line)"
    FAILED=1
  fi

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
test_reset
test_auto
test_palette
test_pick

if [ "$FAILED" -ne 0 ]; then
  echo "Some CLI tests failed!"
  exit 1
fi

echo "All Slice 3 CLI tests passed!"
