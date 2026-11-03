#!/usr/bin/env bash

# Resolve WALH_SHELL directory if not already exported
if [ -z "${WALH_SHELL:-}" ]; then
  if [ -n "${BASH_VERSION:-}" ] && [ -n "${BASH_SOURCE[0]:-}" ]; then
    WALH_SHELL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  elif [ -n "${ZSH_VERSION:-}" ]; then
    # shellcheck disable=SC2296
    eval 'WALH_SHELL="$(cd "$(dirname "${(%):-%x}")" && pwd)"'
  fi
fi

_walh_theme_file() {
  local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/walh"
  printf '%s/current_theme\n' "$state_dir"
}

_walh_apply() {
  local theme="${1:-}"
  theme="${theme%.sh}"

  if [ -z "$theme" ]; then
    echo "walh: no theme specified" >&2
    return 1
  fi

  case "$theme" in
    *[!a-zA-Z0-9_-]*)
      echo "walh: invalid theme name: $theme" >&2
      return 1
      ;;
  esac

  local script="${WALH_SHELL}/scripts/${theme}.sh"
  if [ ! -f "$script" ]; then
    echo "walh: theme '${theme}' not found" >&2
    return 1
  fi

  # shellcheck disable=SC1090
  . "$script"

  local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/walh"
  mkdir -p "$state_dir"
  ln -fs "$script" "$state_dir/current_theme"
  export WALH_THEME="$theme"

  # Record mode history for walh toggle
  if [ "${WALH_MODE:-}" = "dark" ]; then
    printf '%s\n' "$theme" >"$state_dir/last_dark"
  elif [ "${WALH_MODE:-}" = "light" ]; then
    printf '%s\n' "$theme" >"$state_dir/last_light"
  fi

  # Execute user hooks
  local hooks_dir="${WALH_SHELL_HOOKS:-${XDG_CONFIG_HOME:-$HOME/.config}/walh/hooks}"
  if [ -d "$hooks_dir" ]; then
    for hook in "$hooks_dir"/*; do
      [ -f "$hook" ] && [ -x "$hook" ] && "$hook"
    done
  fi
}

# _walh_state_get KEY VAR: set VAR to the unquoted value of KEY in state.toml
# (no forks); VAR is left untouched when the key or file is missing.
_walh_state_get() {
  local file="${XDG_STATE_HOME:-$HOME/.local/state}/walh/state.toml"
  local k v
  [ -f "$file" ] || return 1
  while IFS=' =' read -r k v; do
    if [ "$k" = "$1" ]; then
      v="${v#[\"\']}"
      printf -v "$2" '%s' "${v%[\"\']}"
      return 0
    fi
  done <"$file"
  return 1
}

_walh_current() {
  local theme_name="${WALH_THEME:-}"
  local mode="${WALH_MODE:-}"

  if [ -z "$theme_name" ]; then
    _walh_state_get theme theme_name
  fi
  if [ -z "$mode" ]; then
    _walh_state_get mode mode
  fi

  if [ -z "$theme_name" ]; then
    local tf
    tf="$(_walh_theme_file)"
    if [ -e "$tf" ] || [ -L "$tf" ]; then
      if [ -n "${ZSH_VERSION:-}" ]; then
        # shellcheck disable=SC2296
        eval 'theme_name="$(basename "${tf:A}" .sh)"'
      else
        local target="$tf" _walh_i=0
        while [ -L "$target" ] && [ "$_walh_i" -lt 10 ]; do
          _walh_i=$((_walh_i + 1))
          local link dir
          link="$(readlink "$target" 2>/dev/null)" || break
          dir="$(cd -P "$(dirname "$target")" 2>/dev/null && pwd)"
          case "$link" in
            /*) target="$link" ;;
            *) target="$dir/$link" ;;
          esac
        done
        theme_name="$(basename "$target" .sh)"
      fi
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

  if [ -t 1 ]; then
    printf '\n'
    _walh_palette_rows ''
  fi
}

_walh_list() {
  local filter=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --dark | -d)
        filter="dark"
        ;;
      --light | -l)
        filter="light"
        ;;
      *)
        echo "walh list: unknown option: $1" >&2
        return 1
        ;;
    esac
    shift
  done

  local scripts_dir="${WALH_SHELL}/scripts"
  if [ ! -d "$scripts_dir" ]; then
    echo "walh list: scripts directory not found: $scripts_dir" >&2
    return 1
  fi

  local manifest="${scripts_dir}/.manifest"
  if [ -f "$manifest" ]; then
    case "$filter" in
      dark)
        awk -F '\t' '$2 == "dark" {print $1}' "$manifest"
        ;;
      light)
        awk -F '\t' '$2 == "light" {print $1}' "$manifest"
        ;;
      *)
        cut -f1 "$manifest"
        ;;
    esac
    return 0
  fi

  case "$filter" in
    dark)
      grep -l '^export WALH_MODE=.*dark' "$scripts_dir"/*.sh 2>/dev/null | while read -r f; do
        basename "$f" .sh
      done | sort
      ;;
    light)
      grep -l '^export WALH_MODE=.*light' "$scripts_dir"/*.sh 2>/dev/null | while read -r f; do
        basename "$f" .sh
      done | sort
      ;;
    *)
      for f in "$scripts_dir"/*.sh; do
        [ -f "$f" ] && basename "$f" .sh
      done | sort
      ;;
  esac
}

_walh_random() {
  local mode_filter=""
  if [ $# -gt 0 ]; then
    case "$1" in
      dark | --dark | -d)
        mode_filter="--dark"
        ;;
      light | --light | -l)
        mode_filter="--light"
        ;;
      *)
        echo "walh random: unknown option: $1" >&2
        return 1
        ;;
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
    idx=$(((RANDOM % count) + 1))
  else
    idx=$(awk -v n="$count" 'BEGIN {srand(); print int(rand() * n) + 1}')
  fi

  local chosen
  chosen=$(printf '%s\n' "$themes" | sed -n "${idx}p")
  if [ -n "$chosen" ]; then
    _walh_apply "$chosen"
  fi
}

# _walh_pick_rows: aligned "theme  mode" rows, dark first, then light.
_walh_pick_rows() {
  local m t
  for m in dark light; do
    _walh_list "--$m" | while IFS= read -r t; do
      printf '%-27s %s\n' "$t" "$m"
    done
  done
}

# _walh_palette_rows INDENT: colors 0-15 as two rows of 8 swatches (32 columns).
_walh_palette_rows() {
  local i row
  for row in 0 8; do
    printf '%s' "$1"
    for i in 0 1 2 3 4 5 6 7; do
      printf '\033[48;5;%dm    \033[0m' "$((row + i))"
    done
    printf '\n'
  done
}

# _walh_pick_swatch THEME MODE: preview pane body; indexed colors follow the
# palette the focused theme has just applied.
_walh_pick_swatch() {
  printf '\n  %s (%s)\n\n' "$1" "$2"
  _walh_palette_rows '  '
}

# _walh_pick: fzf browser that previews each theme as it is focused. Enter
# applies and saves it; Esc restores the saved theme.
_walh_pick() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "walh: fzf is required for the theme picker (https://github.com/junegunn/fzf)" >&2
    return 1
  fi

  # These run in fzf's shell with WALH_SHELL exported; bash -c keeps them shell-agnostic.
  # shellcheck disable=SC2016
  local apply='WALH_RESTORE=1 bash -c ". \"\$WALH_SHELL/scripts/\$1.sh\"" _ {1} >/dev/tty 2>&1'
  # shellcheck disable=SC2016
  local swatch='bash -c ". \"\$WALH_SHELL/walh.sh\"; _walh_pick_swatch \"\$1\" \"\$2\"" _ {1} {2}'

  local choice
  choice="$(
    _walh_pick_rows | WALH_SHELL="$WALH_SHELL" fzf \
      --no-sort --layout=reverse --height=100% --prompt='theme> ' --with-nth=1 \
      --header='enter apply  esc cancel' \
      --preview="$swatch" --preview-window='right,60%,border-left' \
      --bind "focus:execute-silent($apply)"
  )"

  if [ -n "$choice" ]; then
    _walh_apply "${choice%%[[:space:]]*}"
    return
  fi

  local saved="${XDG_STATE_HOME:-$HOME/.local/state}/walh/current_theme"
  if [ -e "$saved" ]; then
    # shellcheck disable=SC1090
    WALH_RESTORE=1 . "$saved"
  else
    _walh_reset
  fi
}

_walh_pair_of() {
  local theme="${1:-}"
  local manifest="${WALH_SHELL}/scripts/.manifest"
  if [ -n "$theme" ] && [ -f "$manifest" ]; then
    awk -F '\t' -v t="$theme" '$1 == t {print $3}' "$manifest"
  fi
}

# _walh_current_mode VAR: set VAR to the active mode (dark when unknown).
_walh_current_mode() {
  local m="${WALH_MODE:-}"
  [ -z "$m" ] && _walh_state_get mode m
  printf -v "$1" '%s' "${m:-dark}"
}

# _walh_system_mode VAR: set VAR to the OS appearance (dark|light); fail when unknown.
_walh_system_mode() {
  local v
  case "${OSTYPE:-}" in
    darwin*)
      # AppleInterfaceStyle is only defined in dark mode
      v="$(defaults read -g AppleInterfaceStyle 2>/dev/null)"
      if [ "$v" = "Dark" ]; then v=dark; else v=light; fi
      ;;
    *)
      command -v gsettings >/dev/null 2>&1 || return 1
      v="$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)" || return 1
      case "$v" in
        *dark*) v=dark ;;
        *) v=light ;;
      esac
      ;;
  esac
  printf -v "$1" '%s' "$v"
}

# _walh_switch_to MODE [LABEL]: apply the last theme used in MODE, else the
# current theme's pair, else a default for MODE.
_walh_switch_to() {
  local want="$1" label="${2:-toggle}"
  local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/walh"
  local current_theme="${WALH_THEME:-}"
  local target_theme="" pair fallback_a fallback_b

  [ -z "$current_theme" ] && _walh_state_get theme current_theme

  if [ -f "$state_dir/last_$want" ]; then
    IFS= read -r target_theme <"$state_dir/last_$want" || true
  fi
  if [ -z "$target_theme" ] || [ ! -f "$WALH_SHELL/scripts/$target_theme.sh" ]; then
    pair="$(_walh_pair_of "$current_theme")"
    if [ "$want" = "light" ]; then
      fallback_a=solarized-light fallback_b=github-light
    else
      fallback_a=gruvbox-dark fallback_b=onedark
    fi
    if [ -n "$pair" ] && [ -f "$WALH_SHELL/scripts/$pair.sh" ]; then
      target_theme="$pair"
    elif [ -f "$WALH_SHELL/scripts/$fallback_a.sh" ]; then
      target_theme="$fallback_a"
    elif [ -f "$WALH_SHELL/scripts/$fallback_b.sh" ]; then
      target_theme="$fallback_b"
    else
      target_theme="$(_walh_list "--$want" | head -n1)"
    fi
  fi
  if [ -n "$target_theme" ]; then
    _walh_apply "$target_theme"
  else
    echo "walh $label: no $want theme available" >&2
    return 1
  fi
}

_walh_toggle() {
  local mode
  _walh_current_mode mode
  if [ "$mode" = "dark" ]; then
    _walh_switch_to light toggle
  else
    _walh_switch_to dark toggle
  fi
}

# Match the theme mode to the OS appearance; a no-op when it already matches.
_walh_auto() {
  local system mode
  if ! _walh_system_mode system; then
    echo "walh auto: cannot detect system appearance (needs macOS or GNOME gsettings)" >&2
    return 1
  fi
  _walh_current_mode mode
  [ "$mode" = "$system" ] && return 0
  _walh_switch_to "$system" auto
}

# Restore the terminal's own colors and forget the active theme.
_walh_reset() {
  local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/walh"
  local pre suf code
  # shellcheck disable=SC1003
  if [ -n "${TMUX:-}" ]; then
    pre='\033Ptmux;\033\033]'
    suf='\033\033\\\033\\'
  elif [ "${TERM%%[-.]*}" = "screen" ]; then
    pre='\033P\033]'
    suf='\007\033\\'
  else
    pre='\033]'
    suf='\033\\'
  fi

  if [ "${TERM%%-*}" = "linux" ]; then
    printf '\033]R'
  else
    # palette, foreground, background, cursor, selection background/foreground
    for code in 104 110 111 112 117 119; do
      # shellcheck disable=SC2059
      printf "${pre}%s${suf}" "$code"
    done
  fi

  rm -f "$state_dir/current_theme" "$state_dir/state.toml"
  unset WALH_THEME WALH_MODE WALH_BG WALH_FG COLORFGBG
}

_walh_help() {
  cat <<'EOF'
Usage: walh [command|theme] [options]

Commands:
  <theme>               Apply the specified theme
  current               Show active theme name, mode, and palette
  toggle                Toggle between active dark and light themes
  auto                  Match the theme mode to the system appearance (macOS, GNOME)
  list [--dark|--light] List available themes
  random [dark|light]   Apply a random theme
  (no arguments)        Browse themes in fzf with live preview (falls back to this help)
  palette [--check]     Show the 256-color palette; --check verifies the terminal applied it
  reset                 Restore terminal default colors and forget the active theme
  help, -h, --help      Show this help message
EOF
}

walh() {
  local cmd="${1:-}"
  case "$cmd" in
    "")
      if [ -t 0 ] && [ -t 1 ] && command -v fzf >/dev/null 2>&1; then
        _walh_pick
      else
        _walh_help
      fi
      ;;
    -h | --help | help)
      _walh_help
      ;;
    current)
      _walh_current
      ;;
    toggle)
      _walh_toggle
      ;;
    auto)
      _walh_auto
      ;;
    palette)
      shift
      # shellcheck disable=SC1091
      . "${WALH_SHELL}/palette.sh" && _walh_palette "$@"
      ;;
    reset)
      _walh_reset
      ;;
    list)
      shift
      _walh_list "$@"
      ;;
    random)
      shift
      _walh_random "$@"
      ;;
    *)
      _walh_apply "$cmd"
      ;;
  esac
}
