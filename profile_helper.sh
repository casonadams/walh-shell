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
cat <<'FUNC'
_walh_theme_file() {
  if [ -e "$HOME/.walh_theme" ] || [ -L "$HOME/.walh_theme" ]; then
    printf '%s\n' "$HOME/.walh_theme"
  else
    local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/walh"
    printf '%s/current_theme\n' "$state_dir"
  fi
}

_walh()
{
  local script=$1
  local theme=$2
  if [ -f "$script" ]; then
    . "$script"
    local theme_file
    theme_file="$(_walh_theme_file)"
    mkdir -p "$(dirname "$theme_file")"
    ln -fs "$script" "$theme_file"
    export WALH_THEME=${theme}
    if [ -n "${WALH_SHELL_HOOKS:-}" ] && [ -d "${WALH_SHELL_HOOKS}" ]; then
      for hook in "$WALH_SHELL_HOOKS"/*; do
        [ -f "$hook" ] && [ -x "$hook" ] && "$hook"
      done
    fi
  else
    echo "walh: theme script not found: $script" >&2
    return 1
  fi
}

walh()
{
  if [ $# -eq 0 ]; then
    echo "walh: no theme specified" >&2
    return 1
  fi
  local theme=$1
  local script="${WALH_SHELL}/scripts/${theme}.sh"
  if [ -f "$script" ]; then
    _walh "$script" "$theme"
  else
    echo "walh: theme '${theme}' not found" >&2
    return 1
  fi
}
FUNC

echo "export WALH_SHELL=\"$script_dir\""

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
