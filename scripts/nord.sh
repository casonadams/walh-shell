#!/usr/bin/env bash
# Theme: nord

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

set_foreground "#D8DEE9"
set_background "#2E3440"

# 16 color space
set_color 0 "#3B4252"
set_color 1 "#BF616A"
set_color 2 "#A3BE8C"
set_color 3 "#EBCB8B"
set_color 4 "#81A1C1"
set_color 5 "#B48EAD"
set_color 6 "#88C0D0"
set_color 7 "#757A85"
set_color 8 "#757A85"
set_color 9 "#BF616A"
set_color 10 "#A3BE8C"
set_color 11 "#EBCB8B"
set_color 12 "#81A1C1"
set_color 13 "#B48EAD"
set_color 14 "#88C0D0"
set_color 15 "#ECEFF4"

# 256 color space
set_color 208 "#D08770"

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
