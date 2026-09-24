# shellcheck shell=sh

Describe 'Native Completions and Hooks'
  setup() {
    export HOME="$SHELLSPEC_TMPBASE/comp_home"
    mkdir -p "$HOME"
    export WALH_SHELL="$PWD"
    . "$PWD/walh.sh"
  }
  BeforeEach 'setup'

  Describe 'walh no-argument invocation'
    It 'prints usage instructions'
      When call walh
      The status should be success
      The output should include "Usage: walh"
      The output should include "toggle"
    End
  End

  Describe 'Bash tab completions'
    test_comp() {
      . "$PWD/completions/walh.bash"
      COMP_WORDS=(walh "$1")
      COMP_CWORD=1
      _walh_bash_completion
      printf '%s\n' "${COMPREPLY[*]}"
    }

    It 'suggests matching themes'
      When call test_comp "gruv"
      The status should be success
      The output should include "gruvbox-dark"
      The output should include "gruvbox-light"
    End

    It 'suggests subcommands'
      When call test_comp "to"
      The status should be success
      The output should include "toggle"
    End
  End

  Describe 'Rich hook execution'
    run_hook_test() {
      local hooks_dir="$HOME/hooks"
      mkdir -p "$hooks_dir"
      cat > "$hooks_dir/01-test.sh" <<EOF
#!/bin/sh
echo "HOOK_T:\$WALH_THEME"
echo "HOOK_M:\$WALH_MODE"
echo "HOOK_B:\$WALH_BG"
echo "HOOK_F:\$WALH_FG"
EOF
      chmod +x "$hooks_dir/01-test.sh"
      export WALH_SHELL_HOOKS="$hooks_dir"
      walh gruvbox-dark
    }

    It 'exports WALH_THEME, WALH_MODE, WALH_BG, and WALH_FG to hooks'
      When call run_hook_test
      The status should be success
      The output should include "HOOK_T:gruvbox-dark"
      The output should include "HOOK_M:dark"
      The output should include "HOOK_B:#282828"
      The output should include "HOOK_F:#D5C4A1"
    End
  End
End
