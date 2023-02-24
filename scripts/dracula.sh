#!/usr/bin/env bash
# Theme: dracula

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

set_foreground "#e9e9f4"
set_background "#282936"

# 16 color space
set_color 0 "#3a3c4e"
set_color 1 "#ea51b2"
set_color 2 "#ebff87"
set_color 3 "#00f769"
set_color 4 "#62d6e8"
set_color 5 "#b45bcf"
set_color 6 "#a1efe4"
set_color 7 "#e9e9f4"
set_color 8 "#626483"
set_color 9 "#ea51b2"
set_color 10 "#ebff87"
set_color 11 "#00f769"
set_color 12 "#62d6e8"
set_color 13 "#b45bcf"
set_color 14 "#a1efe4"
set_color 15 "#f7f7fb"

# 256 color space
set_color 208 "#b45bcf"

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
