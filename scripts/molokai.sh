#!/usr/bin/env bash
# Theme: molokai

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

set_foreground "#BBBBBB"
set_background "#121212"

# 16 color space
set_color 0 "#1E1E1E"
set_color 1 "#FA2573"
set_color 2 "#98E123"
set_color 3 "#DFD460"
set_color 4 "#1080D0"
set_color 5 "#8700FF"
set_color 6 "#43A8D0"
set_color 7 "#BBBBBB"
set_color 8 "#555555"
set_color 9 "#FA2573"
set_color 10 "#98E123"
set_color 11 "#DFD460"
set_color 12 "#1080D0"
set_color 13 "#8700FF"
set_color 14 "#43A8D0"
set_color 15 "#FFFFFF"

# 256 color space
set_color 208 "#ED7D6A"

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
