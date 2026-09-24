#!/usr/bin/env zsh

# Do not run if inside Vim or Neovim
if [[ -n "$VIMRUNTIME" || -n "$VIM" || -n "$NVIM" ]]; then
  return
fi

WALH_SHELL=$(dirname "${(%):-%x}")

if [[ -d "${WALH_SHELL}/completions" ]]; then
  fpath=("${WALH_SHELL}/completions" $fpath)
fi

[ -n "$PS1" ] \
    && [ -s "${WALH_SHELL}/profile_helper.sh" ] \
    && eval "$(${WALH_SHELL}/profile_helper.sh)"

alias walh_list_themes="${WALH_SHELL}/list-themes.sh"
