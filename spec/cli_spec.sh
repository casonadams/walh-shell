# shellcheck shell=sh

Describe 'Unified walh CLI Dispatcher'
  setup() {
    export HOME="$SHELLSPEC_TMPBASE/cli_home"
    mkdir -p "$HOME"
    export WALH_SHELL="$PWD"
    . "$PWD/walh.sh"
  }
  BeforeEach 'setup'

  Describe 'walh <theme>'
    It 'applies a valid dark theme'
      When call walh onedark
      The status should be success
      The stdout should be present
      The variable WALH_THEME should equal "onedark"
      The variable WALH_MODE should equal "dark"
    End

    It 'applies a valid light theme'
      When call walh solarized-light
      The status should be success
      The stdout should be present
      The variable WALH_THEME should equal "solarized-light"
      The variable WALH_MODE should equal "light"
    End

    It 'fails when theme does not exist'
      When call walh non-existent-theme-xyz
      The status should be failure
      The stderr should include "walh: theme 'non-existent-theme-xyz' not found"
    End

    It 'rejects unsafe theme names'
      When call walh "foo;bar"
      The status should be failure
      The stderr should include "walh: invalid theme name"
    End
  End

  Describe 'walh current'
    It 'prints current theme, mode, and background'
      walh gruvbox-dark >/dev/null 2>&1
      When call walh current
      The status should be success
      The output should include "Active theme: gruvbox-dark (dark)"
      The output should include "Background: #282828"
    End

    It 'fails cleanly if no theme is active'
      unset WALH_THEME || true
      unset WALH_MODE || true
      rm -f "$HOME/.walh_theme"
      rm -rf "$HOME/.local/state/walh" "$HOME/.cache/walh"
      When call walh current
      The status should be failure
      The stderr should include "walh: no active theme"
    End
  End

  Describe 'walh list'
    It 'lists all available themes'
      When call walh list
      The status should be success
      The output should include "onedark"
      The output should include "solarized-light"
      The output should include "gruvbox-dark"
    End

    It 'filters by dark mode with --dark'
      When call walh list --dark
      The status should be success
      The output should include "onedark"
      The output should include "gruvbox-dark"
      The output should not include "solarized-light"
    End

    It 'filters by light mode with --light'
      When call walh list --light
      The status should be success
      The output should include "solarized-light"
      The output should not include "onedark"
      The output should not include "gruvbox-dark"
    End

    It 'errors on unknown options'
      When call walh list --invalid-flag
      The status should be failure
      The stderr should include "walh list: unknown option"
    End
  End

  Describe 'walh toggle'
    It 'toggles from dark to light'
      walh onedark >/dev/null 2>&1
      When call walh toggle
      The status should be success
      The stdout should be present
      The variable WALH_MODE should equal "light"
    End

    It 'toggles from light back to dark'
      walh onedark >/dev/null 2>&1
      walh toggle >/dev/null 2>&1
      When call walh toggle
      The status should be success
      The stdout should be present
      The variable WALH_THEME should equal "onedark"
      The variable WALH_MODE should equal "dark"
    End
  End

  Describe 'walh random'
    It 'picks a random theme'
      When call walh random
      The status should be success
      The stdout should be present
      The variable WALH_THEME should be present
    End

    It 'picks a random dark theme with dark argument'
      When call walh random dark
      The status should be success
      The stdout should be present
      The variable WALH_MODE should equal "dark"
    End

    It 'picks a random light theme with light argument'
      When call walh random light
      The status should be success
      The stdout should be present
      The variable WALH_MODE should equal "light"
    End

    It 'errors on unknown random argument'
      When call walh random --invalid
      The status should be failure
      The stderr should include "walh random: unknown option"
    End
  End

  Describe 'walh help'
    It 'prints help text'
      When call walh help
      The status should be success
      The output should include "Usage: walh"
      The output should include "toggle"
      The output should include "current"
    End
  End
End
