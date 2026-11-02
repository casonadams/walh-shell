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

# Live preview: while `walh <theme>` is on the command line (e.g. cycling
# completions with <tab>), apply that theme's colors without saving anything.
# The saved theme is restored when the line is edited away or finished; running
# the command then applies the theme for real. Disable with WALH_SHELL_PREVIEW=false.
_walh_restore_saved() {
  local saved="${XDG_STATE_HOME:-$HOME/.local/state}/walh/current_theme"
  [[ -e "$saved" ]] && WALH_RESTORE=1 . "$saved"
  _walh_previewed=
}

_walh_preview_redraw() {
  [[ "${WALH_SHELL_PREVIEW:-}" == false ]] && return
  local name="${BUFFER#walh }"
  if [[ "$BUFFER" =~ '^walh [a-zA-Z0-9_-]+$' && -f "${WALH_SHELL}/scripts/${name}.sh" ]]; then
    [[ "$name" == "$_walh_previewed" ]] && return
    WALH_RESTORE=1 . "${WALH_SHELL}/scripts/${name}.sh"
    _walh_previewed="$name"
  elif [[ -n "$_walh_previewed" ]]; then
    _walh_restore_saved
  fi
}

_walh_preview_finish() {
  [[ -z "$_walh_previewed" ]] && return
  if [[ "$BUFFER" == "walh $_walh_previewed" ]]; then
    _walh_previewed=
  else
    _walh_restore_saved
  fi
}

autoload -Uz add-zle-hook-widget
add-zle-hook-widget zle-line-pre-redraw _walh_preview_redraw
add-zle-hook-widget zle-line-finish _walh_preview_finish
