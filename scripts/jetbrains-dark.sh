#!/usr/bin/env bash
# Theme: jetbrains-dark

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
set_background "#2B2B2B"

# 16 color space
set_color 0 "#383838"
set_color 1 "#DB5451"
set_color 2 "#548C26"
set_color 3 "#A89022"
set_color 4 "#3A91CF"
set_color 5 "#A575BA"
set_color 6 "#009191"
set_color 7 "#BBBBBB"
set_color 8 "#595959"
set_color 9 "#DB5451"
set_color 10 "#548C26"
set_color 11 "#A89022"
set_color 12 "#3A91CF"
set_color 13 "#A575BA"
set_color 14 "#009191"
set_color 15 "#FFFFFF"

# 256 color space
set_color 208 "#D5855E"

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
