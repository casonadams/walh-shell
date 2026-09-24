#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILED=0

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
# Test 1: Native Bash completions
# ---------------------------------------------------------------------------
test_bash_completions() {
  local test_script
  test_script="$(
    cat <<EOF
WALH_SHELL="$REPO_DIR"
. "$REPO_DIR/completions/walh.bash"

# Test 1: Complete themes matching prefix
COMP_WORDS=(walh gruv)
COMP_CWORD=1
_walh_bash_completion
echo "COMP_GRUV:\${COMPREPLY[*]}"

# Test 2: Complete subcommands
COMP_WORDS=(walh tog)
COMP_CWORD=1
_walh_bash_completion
echo "COMP_TOG:\${COMPREPLY[*]}"

# Test 3: Complete all subcommands & themes at word 1
COMP_WORDS=(walh "")
COMP_CWORD=1
_walh_bash_completion
echo "COMP_ALL:\${COMPREPLY[*]}"

# Test 4: Complete options for 'list'
COMP_WORDS=(walh list --d)
COMP_CWORD=2
_walh_bash_completion
echo "COMP_LIST:\${COMPREPLY[*]}"

# Test 5: Complete options for 'random'
COMP_WORDS=(walh random li)
COMP_CWORD=2
_walh_bash_completion
echo "COMP_RANDOM:\${COMPREPLY[*]}"
EOF
  )"

  local output
  output="$(bash -c "$test_script")"
  assert_contains "$output" "COMP_GRUV:gruvbox-dark gruvbox-light" "bash completion suggests themes for 'gruv'"
  assert_contains "$output" "COMP_TOG:toggle" "bash completion suggests toggle for 'tog'"
  assert_contains "$output" "current toggle list random help" "bash completion suggests subcommands"
  assert_contains "$output" "COMP_LIST:--dark" "bash completion suggests --dark for list"
  assert_contains "$output" "COMP_RANDOM:light" "bash completion suggests light for random"
}

# ---------------------------------------------------------------------------
# Test 2: Native Zsh completions registration
# ---------------------------------------------------------------------------
test_zsh_completions() {
  if ! command -v zsh >/dev/null 2>&1; then
    echo "SKIP: zsh not installed"
    return 0
  fi

  local test_script
  test_script="$(
    cat <<EOF
autoload -Uz compinit && compinit -D
eval "\$("$REPO_DIR/profile_helper.sh")"
echo "REGISTERED:\$_comps[walh]"
EOF
  )"

  local output
  output="$(zsh -c "$test_script")"
  assert_contains "$output" "REGISTERED:_walh" "zsh registers _walh completion function for walh"

  local no_shadow_test
  no_shadow_test="$(
    cat <<EOF
. "$REPO_DIR/walh.sh"
type _walh >/dev/null 2>&1 && echo "SHADOWED" || echo "UNSHADOWED"
EOF
  )"
  local shadow_out
  shadow_out="$(zsh -c "$no_shadow_test")"
  assert_contains "$shadow_out" "UNSHADOWED" "walh.sh does not define function _walh shadowing completion"

  if command -v python3 >/dev/null 2>&1; then
    local pty_output
    # shellcheck disable=SC2016
    pty_output="$(
      python3 -c '
import os, pty, select, time, sys

repo_dir = sys.argv[1]
master, slave = pty.openpty()
pid = os.fork()
if pid == 0:
    os.close(master)
    os.setsid()
    for fd in (0, 1, 2):
        os.dup2(slave, fd)
    if slave > 2:
        os.close(slave)
    os.execv("/bin/zsh", ["zsh", "-f"])
else:
    os.close(slave)
    def drain():
        data = b""
        while select.select([master], [], [], 0.05)[0]:
            chunk = os.read(master, 2048)
            if not chunk:
                break
            data += chunk
        return data

    def send_line(line):
        os.write(master, line.encode() + b"\n")
        time.sleep(0.08)
        drain()

    send_line("autoload -Uz compinit && compinit -D")
    eval_cmd = "eval \"$(" + repo_dir + "/profile_helper.sh)\""
    send_line(eval_cmd)
    os.write(master, b"walh \t")
    time.sleep(0.2)
    res = drain().decode(errors="replace")
    os.close(master)
    os.waitpid(pid, 0)
    print("PTY_RESULT:" + res)
' "$REPO_DIR"
    )"
    assert_contains "$pty_output" "toggle" "zsh tab complete on 'walh <tab>' suggests subcommands"
    assert_contains "$pty_output" "gruvbox-dark" "zsh tab complete on 'walh <tab>' suggests themes"
  fi
}

# ---------------------------------------------------------------------------
# Test 3: Rich hook variables execution
# ---------------------------------------------------------------------------
test_rich_hook_variables() {
  local tmp_home
  tmp_home="$(mktemp -d)"
  local hooks_dir="$tmp_home/hooks"
  mkdir -p "$hooks_dir"

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
# Runner
# ---------------------------------------------------------------------------
echo "Running Native Completions and Hooks tests..."
test_bash_completions
test_zsh_completions
test_rich_hook_variables

if [ "$FAILED" -ne 0 ]; then
  echo "Some tests failed!"
  exit 1
fi

echo "All completions and hooks tests passed!"
