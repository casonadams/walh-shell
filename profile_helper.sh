#!/usr/bin/env bash

if [ -s "$BASH" ]; then
    file_name=${BASH_SOURCE[0]}
elif [ -s "$ZSH_NAME" ]; then
    # shellcheck disable=SC2296
    file_name=${(%):-%x}
fi
script_dir=$(cd "$(dirname "$file_name")" && pwd)

# shellcheck disable=SC1091
. "$script_dir/realpath/realpath.sh"

walh_theme_file=""
if [ -e "$HOME/.walh_theme" ] || [ -L "$HOME/.walh_theme" ]; then
  walh_theme_file="$HOME/.walh_theme"
elif [ -e "${XDG_STATE_HOME:-$HOME/.local/state}/walh/current_theme" ] || [ -L "${XDG_STATE_HOME:-$HOME/.local/state}/walh/current_theme" ]; then
  walh_theme_file="${XDG_STATE_HOME:-$HOME/.local/state}/walh/current_theme"
fi

if [ -n "$walh_theme_file" ] && [ -e "$walh_theme_file" ]; then
  script_name=$(basename "$(realpath "$walh_theme_file")" .sh)
  echo "export WALH_THEME=${script_name}"
  echo "WALH_RESTORE=1 . \"$walh_theme_file\"; unset WALH_RESTORE"
fi
echo "export WALH_SHELL=\"$script_dir\""
echo ". \"\$WALH_SHELL/walh.sh\""

if [ -n "$WALH_LEGACY_ALIASES" ]; then
  for script in "$script_dir"/scripts/*.sh; do
    script_name=${script##*/}
    script_name=${script_name%.sh}
    theme=${script_name}
    func_name="walh_${theme}"
    echo "alias $func_name=\"_walh \\\"$script\\\" $theme\""
  done
fi

echo "alias walh_list_themes=\"$script_dir/list-themes.sh\""
