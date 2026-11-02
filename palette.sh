#!/usr/bin/env bash
# walh palette [--check]: show the 256-color palette, and with --check ask the
# terminal for every color (OSC 4 query) and compare it with the active theme.
# Loaded on demand by `walh palette`.

_walh_swatch() {
  local i="$1"
  printf '\033[48;5;%dm  \033[0m' "$i"
}

_walh_palette_show() {
  local i row
  printf 'ANSI 0-15\n'
  for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do _walh_swatch "$i"; done
  printf '\n\nCube 16-231\n'
  for row in 0 1 2 3 4 5; do
    for ((i = 16 + row * 36; i < 52 + row * 36; i++)); do _walh_swatch "$i"; done
    printf '\n'
  done
  printf '\nGray ramp 232-255\n'
  for ((i = 232; i < 256; i++)); do _walh_swatch "$i"; done
  printf '\n'
}

# Print " N=rrggbb" for every color the active theme script defines (last wins).
_walh_palette_expected() {
  local file="$1" line key val entry idx rest out=""
  while IFS= read -r line; do
    case "$line" in
      color[0-9]*=*)
        key="${line%%=*}"
        val="${line#*=\"}"
        val="${val%\"}"
        key="${key#color}"
        case "$key" in 0?) key="${key#0}" ;; esac
        out="$out $key=${val//\//}"
        ;;
      walh_palette256=*)
        val="${line#*=\"}"
        val="${val%\"}"
        rest="$val,"
        while [ -n "$rest" ]; do
          entry="${rest%%,*}"
          rest="${rest#*,}"
          idx="${entry%%;*}"
          val="${entry#*rgb:}"
          # 208 is the theme's own orange (color208), applied after the cube
          [ "$idx" = "208" ] || out="$out $idx=${val//\//}"
        done
        ;;
    esac
  done <"$file"
  printf '%s ' "$out"
}

# Query colors 0-255 and compare the top byte of each channel.
# shellcheck disable=SC1003
_walh_palette_check() {
  local theme_file expected n end replies resp rest r g b got want all="" seen=" "
  local ok=0 bad=0 silent=0 tty_state
  theme_file="$(_walh_theme_file)"
  [ -e "$theme_file" ] || {
    echo "walh palette: no active theme" >&2
    return 1
  }
  [ -n "${TMUX:-}" ] && {
    echo "walh palette: tmux answers color queries itself; run --check outside tmux" >&2
    return 1
  }
  [ -t 0 ] && [ -t 1 ] || {
    echo "walh palette: --check needs an interactive terminal" >&2
    return 1
  }
  expected="$(_walh_palette_expected "$theme_file" | tr 'A-F' 'a-f')"

  exec 3<>/dev/tty
  tty_state="$(stty -g <&3)"
  stty -icanon -echo <&3
  # Ask 16 colors at a time so the replies never overflow the tty input buffer;
  # a batch with no reply means the terminal does not answer color queries.
  n=0
  while [ "$n" -lt 256 ]; do
    end=$((n + 16))
    while [ "$n" -lt "$end" ]; do
      printf '\033]4;%d;?\033\\' "$n" >&3
      n=$((n + 1))
    done
    replies=0
    while [ "$replies" -lt 16 ] && IFS= read -r -s -t 1 -d '\' -u 3 resp; do
      all="$all$resp|"
      replies=$((replies + 1))
    done
    [ "$replies" -eq 0 ] && break
  done
  stty "$tty_state" <&3
  exec 3<&-

  all="$(printf '%s' "$all" | tr 'A-F' 'a-f')"
  rest="$all"
  while [ -n "$rest" ]; do
    resp="${rest%%|*}"
    rest="${rest#*|}"
    resp="${resp##*]4;}"
    n="${resp%%;*}"
    [ "$n" = "$resp" ] && continue
    r="${resp#*rgb:}"
    g="${r#*/}"
    b="${g#*/}"
    r="${r%%/*}"
    g="${g%%/*}"
    got="${r:0:2}${g:0:2}${b:0:2}"
    want="${expected##* "$n"=}"
    want="${want:0:6}"
    seen="$seen$n "
    if [ "$got" = "$want" ]; then
      ok=$((ok + 1))
    else
      bad=$((bad + 1))
      printf 'mismatch %3d: terminal=%s theme=%s\n' "$n" "$got" "$want"
    fi
  done

  n=0
  while [ "$n" -lt 256 ]; do
    case "$seen" in *" $n "*) ;; *) silent=$((silent + 1)) ;; esac
    n=$((n + 1))
  done
  printf '%d/256 colors match the theme, %d differ, %d unanswered\n' "$ok" "$bad" "$silent"
  if [ "$ok" -eq 0 ] && [ "$bad" -eq 0 ]; then
    echo "walh palette: this terminal does not answer color queries (OSC 4); compare the swatches by eye" >&2
  fi
  [ "$bad" -eq 0 ] && [ "$silent" -eq 0 ]
}

_walh_palette() {
  case "${1:-}" in
    "") _walh_palette_show ;;
    --check) _walh_palette_check ;;
    *)
      echo "walh palette: unknown option: $1" >&2
      return 1
      ;;
  esac
}
