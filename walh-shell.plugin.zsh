#!/usr/bin/env zsh

# Do not run if inside Vim or Neovim
if [[ -n "$VIMRUNTIME" || -n "$VIM" || -n "$NVIM" ]]; then
  return
fi

WALH_SHELL=$(dirname "${(%):-%x}")

[ -n "$PS1" ] \
    && [ -s "${WALH_SHELL}/profile_helper.sh" ] \
    && eval "$(${WALH_SHELL}/profile_helper.sh)"
