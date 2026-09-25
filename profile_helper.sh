#!/usr/bin/env bash

if [ -s "$BASH" ]; then
  file_name=${BASH_SOURCE[0]}
elif [ -s "$ZSH_NAME" ]; then
  # shellcheck disable=SC2296
  eval 'file_name=${(%):-%x}'
fi
script_dir=$(cd "$(dirname "$file_name")" && pwd)
echo "export WALH_SHELL=\"$script_dir\""
echo ". \"\$WALH_SHELL/walh.sh\""

walh_theme_file="${XDG_STATE_HOME:-$HOME/.local/state}/walh/current_theme"
if [ -e "$walh_theme_file" ] || [ -L "$walh_theme_file" ]; then
  target="$walh_theme_file"
  _walh_i=0
  while [ -L "$target" ] && [ "$_walh_i" -lt 10 ]; do
    _walh_i=$((_walh_i + 1))
    link="$(readlink "$target" 2>/dev/null)" || break
    dir="$(cd -P "$(dirname "$target")" 2>/dev/null && pwd)"
    case "$link" in
      /*) target="$link" ;;
      *) target="$dir/$link" ;;
    esac
  done
  script_name="$(basename "$target" .sh)"
  echo "export WALH_THEME=${script_name}"
  echo "WALH_RESTORE=1 . \"$walh_theme_file\"; unset WALH_RESTORE"
fi

if [ -f "$script_dir/completions/walh.bash" ]; then
  # shellcheck disable=SC2016
  echo '[ -n "${BASH_VERSION:-}" ] && . "'"$script_dir"'/completions/walh.bash"'
fi
if [ -d "$script_dir/completions" ]; then
  # shellcheck disable=SC2016
  echo '[ -n "${ZSH_VERSION:-}" ] && fpath=("'"$script_dir"'/completions" $fpath) && { unfunction _walh 2>/dev/null || true; } && autoload -Uz _walh && compdef _walh walh 2>/dev/null || true'
fi

echo "alias walh_list_themes=\"$script_dir/list-themes.sh\""
