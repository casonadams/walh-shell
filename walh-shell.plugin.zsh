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

walh_theme_file="${XDG_STATE_HOME:-$HOME/.local/state}/walh/current_theme"

if [[ -n "$walh_theme_file" && -e "$walh_theme_file" ]]; then
  WALH_RESTORE=1 . "$walh_theme_file"
  unset WALH_RESTORE
fi

. "${WALH_SHELL}/walh.sh"


unfunction _walh 2>/dev/null || true
autoload -Uz _walh
compdef _walh walh 2>/dev/null || true

alias walh_list_themes="${WALH_SHELL}/list-themes.sh"
