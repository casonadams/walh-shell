#!/usr/bin/env bash
# Theme: gruvbox-dark-medium

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

set_foreground "#D5C4A1"
set_background "#282828"

# 16 color space
set_color 0 "#353535"
set_color 1 "#FB4934"
set_color 2 "#B8BB26"
set_color 3 "#FABD2F"
set_color 4 "#83A598"
set_color 5 "#D3869B"
set_color 6 "#8EC07C"
set_color 7 "#D5C4A1"
set_color 8 "#7F7664"
set_color 9 "#FB4934"
set_color 10 "#B8BB26"
set_color 11 "#FABD2F"
set_color 12 "#83A598"
set_color 13 "#D3869B"
set_color 14 "#8EC07C"
set_color 15 "#FBF1C7"

# 256 color space
set_color 208 "#FE8019"

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
