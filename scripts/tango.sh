#!/usr/bin/env bash
# Theme: tango

set_foreground() {
  hex_color=$1
  printf '\e]10;%s\e\\' "$hex_color"
}

set_background() {
  hex_color=$1
  printf '\e]11;%s\e\\' "$hex_color"
}

set_color() {
  color_index=$1
  hex_color=$2
  printf '\e]4;%d;%s\e\\' "$color_index" "$hex_color"
}

set_foreground "#00FF00"
set_background "#000000"

# 16 color space
set_color 0 "#3B4245"
set_color 1 "#CC0000"
set_color 2 "#73D216"
set_color 3 "#EDD400"
set_color 4 "#3465A4"
set_color 5 "#75507B"
set_color 6 "#06989A"
set_color 7 "#D3D7CF"
set_color 8 "#2E3436"
set_color 9 "#EF2929"
set_color 10 "#8AE234"
set_color 11 "#FCE94F"
set_color 12 "#729FCF"
set_color 13 "#AD7FA8"
set_color 14 "#34E2E2"
set_color 15 "#EEEEEC"

# 256 color space
set_color 208 "#DD6A00"

# clean up
unset -f set_color
unset -f set_background
unset -f set_foreground

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

unset color_foreground
unset color_background
