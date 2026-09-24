#!/usr/bin/env zsh

# Do not run if inside Vim or Neovim
if [[ -n "$VIMRUNTIME" || -n "$VIM" || -n "$NVIM" ]]; then
  return
fi

WALH_SHELL="${${(%):-%x}:A:h}"
export WALH_SHELL

if [[ -d "${WALH_SHELL}/completions" ]]; then
  fpath=("${WALH_SHELL}/completions" $fpath)
fi

walh_theme_file=""
if [[ -e "$HOME/.walh_theme" || -L "$HOME/.walh_theme" ]]; then
  walh_theme_file="$HOME/.walh_theme"
elif [[ -e "${XDG_STATE_HOME:-$HOME/.local/state}/walh/current_theme" || -L "${XDG_STATE_HOME:-$HOME/.local/state}/walh/current_theme" ]]; then
  walh_theme_file="${XDG_STATE_HOME:-$HOME/.local/state}/walh/current_theme"
fi

if [[ -n "$walh_theme_file" && -e "$walh_theme_file" ]]; then
  WALH_RESTORE=1 . "$walh_theme_file"
  unset WALH_RESTORE
fi

. "${WALH_SHELL}/walh.sh"

if [[ -n "${WALH_LEGACY_ALIASES:-}" ]]; then
  for script in "${WALH_SHELL}"/scripts/*.sh(N); do
    theme="${script:t:r}"
    alias "walh_${theme}=walh ${theme}"
  done
fi

unfunction _walh 2>/dev/null || true
autoload -Uz _walh
compdef _walh walh 2>/dev/null || true

alias walh_list_themes="${WALH_SHELL}/list-themes.sh"
