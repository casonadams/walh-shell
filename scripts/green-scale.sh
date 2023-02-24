#!/usr/bin/env bash
# Theme: green-scale

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

set_foreground "#4AA23C"
set_background "#081D08"

# 16 color space
set_color 0 "#0F2A0E"
set_color 1 "#2F6C1C"
set_color 2 "#50AD32"
set_color 3 "#58BD38"
set_color 4 "#46992C"
set_color 5 "#317029"
set_color 6 "#50AD32"
set_color 7 "#45972B"
set_color 8 "#3A8124"
set_color 9 "#2F6C1C"
set_color 10 "#50AD32"
set_color 11 "#58BD38"
set_color 12 "#46992C"
set_color 13 "#317029"
set_color 14 "#50AD32"
set_color 15 "#6FEB48"

# 256 color space
set_color 208 "#31701E"

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
