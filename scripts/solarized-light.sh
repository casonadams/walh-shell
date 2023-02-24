#!/usr/bin/env bash
# Theme: solarized-light

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

set_foreground "#586E75"
set_background "#FDF6E3"

# 16 color space
set_color 0 "#EEE8D5"
set_color 1 "#DC322F"
set_color 2 "#859900"
set_color 3 "#B58900"
set_color 4 "#268BD2"
set_color 5 "#6C71C4"
set_color 6 "#2AA198"
set_color 7 "#586E75"
set_color 8 "#839496"
set_color 9 "#DC322F"
set_color 10 "#859900"
set_color 11 "#B58900"
set_color 12 "#268BD2"
set_color 13 "#6C71C4"
set_color 14 "#2AA198"
set_color 15 "#002B36"

# 256 color space
set_color 208 "#C95E18"

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
