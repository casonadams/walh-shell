#!/usr/bin/env bash

# Resolve WALH_SHELL directory if not already exported
if [ -z "${WALH_SHELL:-}" ]; then
  if [ -n "${BASH_VERSION:-}" ] && [ -n "${BASH_SOURCE[0]:-}" ]; then
    WALH_SHELL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  elif [ -n "${ZSH_VERSION:-}" ]; then
    # shellcheck disable=SC2296
    WALH_SHELL="$(cd "$(dirname "${(%):-%x}")" && pwd)"
  fi
fi

_walh_theme_file() {
  if [ -e "$HOME/.walh_theme" ] || [ -L "$HOME/.walh_theme" ]; then
    printf '%s\n' "$HOME/.walh_theme"
  else
    local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/walh"
    printf '%s/current_theme\n' "$state_dir"
  fi
}

_walh_apply() {
  local theme="${1:-}"
  theme="${theme%.sh}"

  if [ -z "$theme" ]; then
    echo "walh: no theme specified" >&2
    return 1
  fi

  if ! printf '%s\n' "$theme" | grep -Eq '^[a-zA-Z0-9_-]+$'; then
    echo "walh: invalid theme name: $theme" >&2
    return 1
  fi

  local script="${WALH_SHELL}/scripts/${theme}.sh"
  if [ ! -f "$script" ]; then
    echo "walh: theme '${theme}' not found" >&2
    return 1
  fi

  # shellcheck disable=SC1090
  . "$script"

  local theme_file
  theme_file="$(_walh_theme_file)"
  mkdir -p "$(dirname "$theme_file")"
  ln -fs "$script" "$theme_file"
  export WALH_THEME="$theme"

  # Record mode history for walh toggle
  local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/walh"
  mkdir -p "$state_dir"
  if [ "${WALH_MODE:-}" = "dark" ]; then
    printf '%s\n' "$theme" > "$state_dir/last_dark"
  elif [ "${WALH_MODE:-}" = "light" ]; then
    printf '%s\n' "$theme" > "$state_dir/last_light"
  fi

  # Execute user hooks
  if [ -n "${WALH_SHELL_HOOKS:-}" ] && [ -d "${WALH_SHELL_HOOKS}" ]; then
    for hook in "$WALH_SHELL_HOOKS"/*; do
      [ -f "$hook" ] && [ -x "$hook" ] && "$hook"
    done
  fi
}

_walh() {
  # Backward-compatible wrapper for legacy aliases
  local script="${1:-}"
  local theme="${2:-}"
  if [ -n "$theme" ]; then
    _walh_apply "$theme"
  elif [ -n "$script" ]; then
    local name
    name="$(basename "$script" .sh)"
    _walh_apply "$name"
  fi
}

_walh_current() {
  local theme_name="${WALH_THEME:-}"
  local mode="${WALH_MODE:-}"
  local bg=""
  local state_file="${XDG_CACHE_HOME:-$HOME/.cache}/walh/state.toml"

  if [ -f "$state_file" ]; then
    local val
    if [ -z "$theme_name" ]; then
      val="$(grep -m1 '^theme[[:space:]]*=' "$state_file" | sed 's/theme[[:space:]]*=[[:space:]]*["'\'']\(.*\)["'\'']/\1/')"
      [ -n "$val" ] && theme_name="$val"
    fi
    if [ -z "$mode" ]; then
      val="$(grep -m1 '^mode[[:space:]]*=' "$state_file" | sed 's/mode[[:space:]]*=[[:space:]]*["'\'']\(.*\)["'\'']/\1/')"
      [ -n "$val" ] && mode="$val"
    fi
    val="$(grep -m1 '^background[[:space:]]*=' "$state_file" | sed 's/background[[:space:]]*=[[:space:]]*["'\'']\(.*\)["'\'']/\1/')"
    [ -n "$val" ] && bg="$val"
  fi

  if [ -z "$theme_name" ]; then
    local tf
    tf="$(_walh_theme_file)"
    if [ -e "$tf" ] || [ -L "$tf" ]; then
      # shellcheck disable=SC1091
      . "$WALH_SHELL/realpath/realpath.sh"
      theme_name="$(basename "$(realpath "$tf")" .sh)"
    fi
  fi

  if [ -z "$theme_name" ]; then
    echo "walh: no active theme" >&2
    return 1
  fi

  if [ -n "$mode" ]; then
    printf 'Active theme: %s (%s)\n' "$theme_name" "$mode"
  else
    printf 'Active theme: %s\n' "$theme_name"
  fi

  if [ -n "$bg" ]; then
    printf 'Background: %s\n' "$bg"
  fi
}

_walh_list() {
  local filter=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --dark|-d)
        filter="dark" ;;
      --light|-l)
        filter="light" ;;
      *)
        echo "walh list: unknown option: $1" >&2
        return 1 ;;
    esac
    shift
  done

  local scripts_dir="${WALH_SHELL}/scripts"
  if [ ! -d "$scripts_dir" ]; then
    echo "walh list: scripts directory not found: $scripts_dir" >&2
    return 1
  fi

  case "$filter" in
    dark)
      grep -l '^export WALH_MODE=.*dark' "$scripts_dir"/*.sh 2>/dev/null | while read -r f; do
        basename "$f" .sh
      done | sort ;;
    light)
      grep -l '^export WALH_MODE=.*light' "$scripts_dir"/*.sh 2>/dev/null | while read -r f; do
        basename "$f" .sh
      done | sort ;;
    *)
      for f in "$scripts_dir"/*.sh; do
        [ -f "$f" ] && basename "$f" .sh
      done | sort ;;
  esac
}

_walh_random() {
  local mode_filter=""
  if [ $# -gt 0 ]; then
    case "$1" in
      dark|--dark|-d)
        mode_filter="--dark" ;;
      light|--light|-l)
        mode_filter="--light" ;;
      *)
        echo "walh random: unknown option: $1" >&2
        return 1 ;;
    esac
  fi

  local themes
  themes=$(_walh_list $mode_filter)
  if [ -z "$themes" ]; then
    echo "walh random: no themes found" >&2
    return 1
  fi

  local count
  count=$(printf '%s\n' "$themes" | wc -l | tr -d ' ')
  if [ "$count" -le 0 ]; then
    echo "walh random: no themes found" >&2
    return 1
  fi

  local idx
  if [ -n "${RANDOM:-}" ]; then
    idx=$(( (RANDOM % count) + 1 ))
  else
    idx=$(awk -v n="$count" 'BEGIN {srand(); print int(rand() * n) + 1}')
  fi

  local chosen
  chosen=$(printf '%s\n' "$themes" | sed -n "${idx}p")
  if [ -n "$chosen" ]; then
    _walh_apply "$chosen"
  fi
}

_walh_toggle() {
  local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/walh"
  local current_mode="${WALH_MODE:-}"

  if [ -z "$current_mode" ]; then
    local state_file="${XDG_CACHE_HOME:-$HOME/.cache}/walh/state.toml"
    if [ -f "$state_file" ]; then
      current_mode="$(grep -m1 '^mode[[:space:]]*=' "$state_file" | sed 's/mode[[:space:]]*=[[:space:]]*["'\'']\(.*\)["'\'']/\1/')"
    fi
  fi

  [ -z "$current_mode" ] && current_mode="dark"

  local target_theme=""
  if [ "$current_mode" = "dark" ]; then
    if [ -f "$state_dir/last_light" ]; then
      target_theme="$(cat "$state_dir/last_light" 2>/dev/null)"
    fi
    if [ -z "$target_theme" ] || [ ! -f "$WALH_SHELL/scripts/$target_theme.sh" ]; then
      if [ -f "$WALH_SHELL/scripts/solarized-light.sh" ]; then
        target_theme="solarized-light"
      elif [ -f "$WALH_SHELL/scripts/github-light.sh" ]; then
        target_theme="github-light"
      else
        target_theme="$(_walh_list --light | head -n1)"
      fi
    fi
  else
    if [ -f "$state_dir/last_dark" ]; then
      target_theme="$(cat "$state_dir/last_dark" 2>/dev/null)"
    fi
    if [ -z "$target_theme" ] || [ ! -f "$WALH_SHELL/scripts/$target_theme.sh" ]; then
      if [ -f "$WALH_SHELL/scripts/gruvbox-dark.sh" ]; then
        target_theme="gruvbox-dark"
      elif [ -f "$WALH_SHELL/scripts/onedark.sh" ]; then
        target_theme="onedark"
      else
        target_theme="$(_walh_list --dark | head -n1)"
      fi
    fi
  fi

  if [ -n "$target_theme" ]; then
    _walh_apply "$target_theme"
  else
    echo "walh toggle: no opposite-mode theme available" >&2
    return 1
  fi
}

_walh_preview() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "walh: fzf is required for interactive preview. Available themes:" >&2
    _walh_list
    return 1
  fi

  if [ ! -t 0 ] || [ ! -t 1 ]; then
    echo "walh: interactive terminal required for preview. Available themes:" >&2
    _walh_list
    return 1
  fi

  local initial_theme="${WALH_THEME:-}"
  local initial_script=""
  if [ -n "$initial_theme" ] && [ -f "$WALH_SHELL/scripts/$initial_theme.sh" ]; then
    initial_script="$WALH_SHELL/scripts/$initial_theme.sh"
  fi

  local preview_cmd
  preview_cmd="[ -f '$WALH_SHELL/scripts/{}.sh' ] && { eval \"\$('$WALH_SHELL/scripts/{}.sh' > /dev/tty 2>/dev/null || true)\"; printf 'Theme:  %s\nMode:   %s\n' '{}' \"\$(grep -m1 '^export WALH_MODE=' '$WALH_SHELL/scripts/{}.sh' 2>/dev/null | cut -d= -f2 | tr -d '\"')\"; }"

  local chosen
  chosen=$(_walh_list | fzf \
    --preview="$preview_cmd" \
    --preview-window="right:40%:wrap" \
    --prompt="walh> " \
    --header="ENTER: apply | ESC: cancel" \
    --height="60%" \
    --reverse)

  if [ -n "$chosen" ]; then
    _walh_apply "$chosen"
  else
    if [ -n "$initial_script" ]; then
      # shellcheck disable=SC1090
      WALH_RESTORE=1 . "$initial_script"
      unset WALH_RESTORE
      export WALH_THEME="$initial_theme"
    fi
  fi
}

_walh_help() {
  cat <<'EOF'
Usage: walh [command|theme] [options]

Commands:
  <theme>               Apply the specified theme
  current               Show active theme name, mode, and colors
  toggle                Toggle between active dark and light themes
  list [--dark|--light] List available themes
  random [dark|light]   Apply a random theme
  preview               Interactive theme selector (requires fzf)
  help, -h, --help      Show this help message
EOF
}

walh() {
  local cmd="${1:-}"
  case "$cmd" in
    "")
      _walh_preview ;;
    current)
      _walh_current ;;
    toggle)
      _walh_toggle ;;
    list)
      shift
      _walh_list "$@" ;;
    random)
      shift
      _walh_random "$@" ;;
    preview)
      shift
      _walh_preview "$@" ;;
    -h|--help|help)
      _walh_help ;;
    *)
      _walh_apply "$cmd" ;;
  esac
}
