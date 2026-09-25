# bash completion for walh

# shellcheck disable=SC1090
if [ -n "${ZSH_VERSION:-}" ]; then
  if autoload -U +X compinit 2>/dev/null; then
    compinit -D -u 2>/dev/null || true
  fi
  if command -v compdef >/dev/null 2>&1 && autoload -U +X bashcompinit 2>/dev/null; then
    bashcompinit 2>/dev/null || return 0
  else
    return 0
  fi
fi

if ! command -v complete >/dev/null 2>&1; then
  return 0 2>/dev/null
fi

_walh_bash_completion() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"

  local subcommands="current toggle list random help"

  if [ "$COMP_CWORD" -eq 1 ]; then
    local themes=""
    local walh_dir="${WALH_SHELL:-}"
    if [ -z "$walh_dir" ] && [ -n "${BASH_SOURCE[0]:-}" ]; then
      walh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    fi
    if [ -n "$walh_dir" ] && [ -d "${walh_dir}/scripts" ]; then
      themes="$(for f in "${walh_dir}/scripts/"*.sh; do [ -f "$f" ] && basename "$f" .sh; done)"
    elif command -v walh >/dev/null 2>&1; then
      themes="$(walh list 2>/dev/null)"
    fi
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "${subcommands} ${themes}" -- "$cur"))
    return 0
  fi

  case "$prev" in
    list)
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "--dark --light -d -l" -- "$cur"))
      return 0
      ;;
    random)
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "dark light" -- "$cur"))
      return 0
      ;;
  esac
}

complete -F _walh_bash_completion walh
