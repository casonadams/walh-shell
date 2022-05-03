#!/usr/bin/env bash
# Theme: gruvbox-dark-medium

# Normal
color00="28/28/28" # Black
color01="fb/49/34" # Red
color02="b8/bb/26" # Green
color03="fa/bd/2f" # Yellow
color04="83/a5/98" # Blue
color05="d3/86/9b" # Magenta
color06="8e/c0/7c" # Cyan
color07="d5/c4/a1" # Grey

# Bright
color08="7f/76/64" # Dark Grey
color09="fb/49/34" # Red
color10="b8/bb/26" # Green
color11="fa/bd/2f" # Yellow
color12="83/a5/98" # Blue
color13="d3/86/9b" # Magenta
color14="8e/c0/7c" # Cyan
color15="fb/f1/c7" # White

# 256 color
color208="fe/80/19" # Orange
color247="35/35/35" # Black +5

# Base
color_background="28/28/28" # Black
color_foreground="d5/c4/a1" # Grey

if [ -n "$TMUX" ]; then
  # Tell tmux to pass the escape sequences through
  # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
  put_template() { printf '\033Ptmux;\033\033]4;%d;rgb:%s\033\033\\\033\\' "$@"; }
  put_template_var() { printf '\033Ptmux;\033\033]%d;rgb:%s\033\033\\\033\\' "$@"; }
  put_template_custom() { printf '\033Ptmux;\033\033]%s%s\033\033\\\033\\' "$@"; }
elif [ "${TERM%%[-.]*}" = "screen" ]; then
  # GNU screen (screen, screen-256color, screen-256color-bce)
  put_template() { printf '\033P\033]4;%d;rgb:%s\007\033\\' "$@"; }
  put_template_var() { printf '\033P\033]%d;rgb:%s\007\033\\' "$@"; }
  put_template_custom() { printf '\033P\033]%s%s\007\033\\' "$@"; }
elif [ "${TERM%%-*}" = "linux" ]; then
  put_template() { [ "$1" -lt 16 ] && printf "\e]P%x%s" "$1" "$(echo "$2" | sed 's/\///g')"; }
  put_template_var() { true; }
  put_template_custom() { true; }
else
  put_template() { printf '\033]4;%d;rgb:%s\033\\' "$@"; }
  put_template_var() { printf '\033]%d;rgb:%s\033\\' "$@"; }
  put_template_custom() { printf '\033]%s%s\033\\' "$@"; }
fi

# 16 color space
put_template 0 $color00
put_template 1 $color01
put_template 2 $color02
put_template 3 $color03
put_template 4 $color04
put_template 5 $color05
put_template 6 $color06
put_template 7 $color07
put_template 8 $color08
put_template 9 $color09
put_template 10 $color10
put_template 11 $color11
put_template 12 $color12
put_template 13 $color13
put_template 14 $color14
put_template 15 $color15

# 256 color space
put_template 208 $color208
put_template 247 $color247

# foreground / background / cursor color
if [ -n "$ITERM_SESSION_ID" ]; then
  # iTerm2 proprietary escape codes
  put_template_custom Pg d5c4a1 # foreground
  put_template_custom Ph 282828 # background
  put_template_custom Pi fbf1c7 # bold color
  put_template_custom Pj fabd2f # selection color
  put_template_custom Pk 282828 # selected text color
  put_template_custom Pl d5c4a1 # cursor
  put_template_custom Pm 282828 # cursor text
else
  put_template_var 10 $color_foreground
  if [ "$WALH_SHELL_SET_BACKGROUND" != false ]; then
    put_template_var 11 $color_background
    if [ "${TERM%%-*}" = "rxvt" ]; then
      put_template_var 708 $color_background # internal border (rxvt)
    fi
  fi
  put_template_custom 12 ";7" # cursor (reverse video)
fi

# clean up
unset -f put_template
unset -f put_template_var
unset -f put_template_custom
unset color00
unset color01
unset color02
unset color03
unset color04
unset color05
unset color06
unset color07
unset color08
unset color09
unset color10
unset color11
unset color12
unset color13
unset color14
unset color15
unset color208
unset color247
unset color_foreground
unset color_background
