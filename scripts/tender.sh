#!/usr/bin/env bash
# Theme: tender

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

set_foreground "#EEEEEE"
set_background "#282828"

# 16 color space
set_color 0 "#363636"
set_color 1 "#F43753"
set_color 2 "#C9D05C"
set_color 3 "#FFC24B"
set_color 4 "#B3DEEF"
set_color 5 "#D3B987"
set_color 6 "#73CEF4"
set_color 7 "#EEEEEE"
set_color 8 "#4C4C4C"
set_color 9 "#F43753"
set_color 10 "#C9D05C"
set_color 11 "#FFC24B"
set_color 12 "#B3DEEF"
set_color 13 "#D3B987"
set_color 14 "#73CEF4"
set_color 15 "#FEFFFF"

# 256 color space
set_color 208 "#FA7D4F"

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
