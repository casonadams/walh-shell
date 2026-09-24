# bash completion for walh

# shellcheck disable=SC1090
if [ -n "${ZSH_VERSION:-}" ]; then
  autoload -U +X compinit 2>/dev/null && compinit -D 2>/dev/null || true
  autoload -U +X bashcompinit 2>/dev/null && bashcompinit 2>/dev/null || return 0
fi

if ! command -v complete >/dev/null 2>&1; then
  return 0 2>/dev/null
fi

_walh_bash_completion() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"

  local subcommands="current toggle list random preview help"

  if [ "$COMP_CWORD" -eq 1 ]; then
    local themes=""
    if [ -n "${WALH_SHELL:-}" ] && [ -d "${WALH_SHELL}/scripts" ]; then
      themes="$(for f in "${WALH_SHELL}/scripts/"*.sh; do [ -f "$f" ] && basename "$f" .sh; done)"
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
