#!/usr/bin/env bash
# Theme: tomorrow

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

set_foreground "#4D4D4C"
set_background "#FFFFFF"

# 16 color space
set_color 0 "#F2F2F2"
set_color 1 "#C82829"
set_color 2 "#718C00"
set_color 3 "#EAB700"
set_color 4 "#4271AE"
set_color 5 "#8959A8"
set_color 6 "#3E999F"
set_color 7 "#4D4D4C"
set_color 8 "#8E908C"
set_color 9 "#C82829"
set_color 10 "#718C00"
set_color 11 "#EAB700"
set_color 12 "#4271AE"
set_color 13 "#8959A8"
set_color 14 "#3E999F"
set_color 15 "#1D1F21"

# 256 color space
set_color 208 "#F5871F"

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
