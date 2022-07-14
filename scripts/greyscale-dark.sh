#!/usr/bin/env bash
# Theme: greyscale-dark

# Normal
color00="1C/1C/1C" # Black
color01="7C/7C/7C" # Red
color02="8E/8E/8E" # Green
color03="A0/A0/A0" # Yellow
color04="68/68/68" # Blue
color05="74/74/74" # Magenta
color06="86/86/86" # Cyan
color07="B9/B9/B9" # Grey

# Bright
color08="52/52/52" # Dark Grey
color09="7C/7C/7C" # Red
color10="8E/8E/8E" # Green
color11="A0/A0/A0" # Yellow
color12="68/68/68" # Blue
color13="74/74/74" # Magenta
color14="86/86/86" # Cyan
color15="F7/F7/F7" # White

# 256 color
color208="8E/8E/8E" # Orange
color247="//" # Black +5

# Base
color_background="10/10/10" # Black
color_foreground="B9/B9/B9" # Grey

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
  put_template_custom Pg B9B9B9 # foreground
  put_template_custom Ph 101010 # background
  put_template_custom Pi F7F7F7 # bold color
  put_template_custom Pj A0A0A0 # selection color
  put_template_custom Pk 101010 # selected text color
  put_template_custom Pl B9B9B9 # cursor
  put_template_custom Pm 101010 # cursor text
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
