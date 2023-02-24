#!/usr/bin/env bash
# Theme: github-dark

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

set_foreground "#8B949E"
set_background "#101216"

# 16 color space
set_color 0 "#1A1D23"
set_color 1 "#F78166"
set_color 2 "#56D364"
set_color 3 "#E3B341"
set_color 4 "#6CA4F8"
set_color 5 "#DB61A2"
set_color 6 "#2B7489"
set_color 7 "#8B949E"
set_color 8 "#4D4D4D"
set_color 9 "#F78166"
set_color 10 "#56D364"
set_color 11 "#E3B341"
set_color 12 "#6CA4F8"
set_color 13 "#DB61A2"
set_color 14 "#2B7489"
set_color 15 "#C5C9CF"

# 256 color space
set_color 208 "#ED9A54"

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
