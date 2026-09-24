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
      The output should include "WALH_RESTORE=1 ."
    End

    It 'preserves multi-hyphen theme names'
      setup_theme "catppuccin-mocha"
      When run script profile_helper.sh
      The status should be success
      The output should include "export WALH_THEME=catppuccin-mocha"
      The output should include "WALH_RESTORE=1 ."
    End

    It 'preserves non-hyphen theme names'
      setup_theme "onedark"
      When run script profile_helper.sh
      The status should be success
      The output should include "export WALH_THEME=onedark"
      The output should include "WALH_RESTORE=1 ."
    End
  End

  Describe 'XDG Base Directory and legacy fallback'
    It 'restores theme from XDG_STATE_HOME when legacy ~/.walh_theme is absent'
      export HOME="$SHELLSPEC_TMPBASE/xdg_home"
      export XDG_STATE_HOME="$SHELLSPEC_TMPBASE/custom_state"
      mkdir -p "$XDG_STATE_HOME/walh"
      ln -sf "$PWD/scripts/gruvbox-dark.sh" "$XDG_STATE_HOME/walh/current_theme"

      When run script profile_helper.sh
      The status should be success
      The output should include "export WALH_THEME=gruvbox-dark"
      The output should include "$XDG_STATE_HOME/walh/current_theme"
    End

    It 'prefers legacy ~/.walh_theme when both legacy and XDG files exist'
      export HOME="$SHELLSPEC_TMPBASE/dual_home"
      mkdir -p "$HOME/.local/state/walh"
      ln -sf "$PWD/scripts/solarized-light.sh" "$HOME/.local/state/walh/current_theme"
      ln -sf "$PWD/scripts/gruvbox-dark.sh" "$HOME/.walh_theme"

      When run script profile_helper.sh
      The status should be success
      The output should include "export WALH_THEME=gruvbox-dark"
      The output should include "$HOME/.walh_theme"
    End
  End

  Describe 'Startup alias behavior'
    It 'sources walh.sh and omits theme aliases by default'
      export HOME="$SHELLSPEC_TMPBASE/no_alias_home"
      unset WALH_LEGACY_ALIASES || true

      When run script profile_helper.sh
      The status should be success
      The output should include 'walh.sh'
      The output should not include "alias walh_gruvbox-dark"
      The output should not include "alias walh_onedark"
      The output should include "alias walh_list_themes"
    End

    It 'emits individual theme aliases when WALH_LEGACY_ALIASES=1'
      export HOME="$SHELLSPEC_TMPBASE/alias_home"
      export WALH_LEGACY_ALIASES=1

      When run script profile_helper.sh
      The status should be success
      The output should include "alias walh_gruvbox-dark"
      The output should include "alias walh_onedark"
    End
  End

  Describe 'Interactive walh dispatcher execution'
    run_dispatcher_xdg() {
      export HOME="$SHELLSPEC_TMPBASE/disp_xdg_home"
      unset WALH_LEGACY_ALIASES || true
      eval "$("$PWD/profile_helper.sh")"
      walh gruvbox-dark
      echo "ACTIVE_THEME:$WALH_THEME"
    }

    It 'switches theme and writes to XDG state file when ~/.walh_theme is absent'
      When call run_dispatcher_xdg
      The status should be success
      The output should include "ACTIVE_THEME:gruvbox-dark"
      The path "$SHELLSPEC_TMPBASE/disp_xdg_home/.local/state/walh/current_theme" should be symlink
      The path "$SHELLSPEC_TMPBASE/disp_xdg_home/.walh_theme" should not be exist
    End

    run_dispatcher_legacy() {
      export HOME="$SHELLSPEC_TMPBASE/disp_leg_home"
      mkdir -p "$HOME"
      touch "$HOME/.walh_theme"
      unset WALH_LEGACY_ALIASES || true
      eval "$("$PWD/profile_helper.sh")"
      walh onedark
      echo "ACTIVE_THEME:$WALH_THEME"
    }

    It 'switches theme and updates ~/.walh_theme when legacy file exists'
      When call run_dispatcher_legacy
      The status should be success
      The output should include "ACTIVE_THEME:onedark"
      The path "$SHELLSPEC_TMPBASE/disp_leg_home/.walh_theme" should be symlink
      The path "$SHELLSPEC_TMPBASE/disp_leg_home/.local/state/walh/current_theme" should not be exist
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
        The contents of file "$SHELLSPEC_TMPBASE/cache2/walh/state.toml" should include 'theme = "gruvbox-dark"'
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
        echo "THEME:$WALH_THEME"
        echo "MODE:$WALH_MODE"
        echo "COLORFGBG:$COLORFGBG"
      }

      It 'cleans up temporary buffer variables and functions after sourcing'
        When call source_and_audit
        The status should be success
        The output should include "THEME:gruvbox-dark"
        The output should include "MODE:dark"
        The output should include "COLORFGBG:15;0"
        The output should not include "LEAK"
      End
    End
  End
End
