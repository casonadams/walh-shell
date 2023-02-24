#!/usr/bin/env bash
# Theme: darcula

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

set_foreground "#A9B7C6"
set_background "#282828"

# 16 color space
set_color 0 "#3C3F41"
set_color 1 "#BC3F3C"
set_color 2 "#A5C261"
set_color 3 "#FFC66D"
set_color 4 "#6897BB"
set_color 5 "#9876AA"
set_color 6 "#89C0BE"
set_color 7 "#BABABA"
set_color 8 "#808080"
set_color 9 "#BC3F3C"
set_color 10 "#A5C261"
set_color 11 "#FFC66D"
set_color 12 "#6897BB"
set_color 13 "#9876AA"
set_color 14 "#89C0BE"
set_color 15 "#F4F4FA"

# 256 color space
set_color 208 "#CC7832"

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
