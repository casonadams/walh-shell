#!/usr/bin/env zsh

# Do not run if inside Vim or Neovim
if [[ -n "$VIMRUNTIME" || -n "$VIM" || -n "$NVIM" ]]; then
  return
fi

WALH_SHELL="$(cd "$(dirname "${(%):-%x}")" && pwd)"
export WALH_SHELL

if [[ -d "${WALH_SHELL}/completions" ]]; then
  fpath=("${WALH_SHELL}/completions" $fpath)
fi

if [[ -o interactive ]] || [ -n "$PS1" ]; then
  if [ -s "${WALH_SHELL}/profile_helper.sh" ]; then
    eval "$("${WALH_SHELL}/profile_helper.sh")"
  fi
fi

alias walh_list_themes="${WALH_SHELL}/list-themes.sh"
