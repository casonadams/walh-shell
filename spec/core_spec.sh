# shellcheck shell=sh

Describe 'Core Theme Infrastructure'
  Describe 'profile_helper.sh theme restoration'
    setup_theme() {
      theme_file="$SHELLSPEC_TMPBASE/.walh_theme"
      ln -sf "$PWD/scripts/$1.sh" "$theme_file"
      HOME="$SHELLSPEC_TMPBASE"
      export HOME
    }

    It 'preserves single-hyphen theme names'
      setup_theme "gruvbox-dark"
      When run script profile_helper.sh
      The status should be success
      The output should include "export WALH_THEME=gruvbox-dark"
    End

    It 'preserves multi-hyphen theme names'
      setup_theme "catppuccin-mocha"
      When run script profile_helper.sh
      The status should be success
      The output should include "export WALH_THEME=catppuccin-mocha"
    End

    It 'preserves non-hyphen theme names'
      setup_theme "onedark"
      When run script profile_helper.sh
      The status should be success
      The output should include "export WALH_THEME=onedark"
    End
  End

  Describe 'template/default.mustache rendered scripts'
    Describe 'WALH_RESTORE behavior'
      It 'skips state.toml creation when WALH_RESTORE=1'
        export XDG_CACHE_HOME="$SHELLSPEC_TMPBASE/cache1"
        export WALH_RESTORE=1
        When run script scripts/gruvbox-dark.sh
        The status should be success
        The stdout should be present
        The path "$SHELLSPEC_TMPBASE/cache1/walh/state.toml" should not be exist
      End

      It 'creates state.toml when WALH_RESTORE is unset'
        export XDG_CACHE_HOME="$SHELLSPEC_TMPBASE/cache2"
        unset WALH_RESTORE || true
        When run script scripts/gruvbox-dark.sh
        The status should be success
        The stdout should be present
        The path "$SHELLSPEC_TMPBASE/cache2/walh/state.toml" should be exist
        The contents of file "$SHELLSPEC_TMPBASE/cache2/walh/state.toml" should include 'mode = "dark"'
        The contents of file "$SHELLSPEC_TMPBASE/cache2/walh/state.toml" should include 'background = "#282828"'
      End
    End

    Describe 'escape sequence buffering and variable cleanup'
      source_and_audit() {
        XDG_CACHE_HOME="$SHELLSPEC_TMPBASE/cache3" . "$PWD/scripts/gruvbox-dark.sh"
        [ -z "${walh_buffer+x}" ] || echo "LEAK: walh_buffer"
        [ -z "${color00+x}" ] || echo "LEAK: color00"
        [ -z "${color15+x}" ] || echo "LEAK: color15"
        command -v walh_append >/dev/null 2>&1 && echo "LEAK_FN: walh_append"
        command -v put_template >/dev/null 2>&1 && echo "LEAK_FN: put_template"
        echo "MODE:$WALH_MODE"
        echo "COLORFGBG:$COLORFGBG"
      }

      It 'cleans up temporary buffer variables and functions after sourcing'
        When call source_and_audit
        The status should be success
        The output should include "MODE:dark"
        The output should include "COLORFGBG:15;0"
        The output should not include "LEAK"
      End
    End
  End
End
