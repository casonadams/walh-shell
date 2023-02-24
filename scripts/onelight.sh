#!/usr/bin/env bash
# Theme: onelight

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

set_foreground "#383A42"
set_background "#FAFAFA"

# 16 color space
set_color 0 "#F0F0F1"
set_color 1 "#CA1243"
set_color 2 "#50A14F"
set_color 3 "#C18401"
set_color 4 "#4078F2"
set_color 5 "#A626A4"
set_color 6 "#0184BC"
set_color 7 "#383A42"
set_color 8 "#A0A1A7"
set_color 9 "#CA1243"
set_color 10 "#50A14F"
set_color 11 "#C18401"
set_color 12 "#4078F2"
set_color 13 "#A626A4"
set_color 14 "#0184BC"
set_color 15 "#090A0B"

# 256 color space
set_color 208 "#D75F00"

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
