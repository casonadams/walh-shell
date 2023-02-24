#!/usr/bin/env bash
# Theme: axual

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

set_foreground "#D8D7CD"
set_background "#113851"

# 16 color space
set_color 0 "#13415E"
set_color 1 "#D7595F"
set_color 2 "#B5BD68"
set_color 3 "#F2BF40"
set_color 4 "#81A2BE"
set_color 5 "#B294BB"
set_color 6 "#47B0AB"
set_color 7 "#D8D7CD"
set_color 8 "#A99688"
set_color 9 "#D7595F"
set_color 10 "#B5BD68"
set_color 11 "#F2BF40"
set_color 12 "#81A2BE"
set_color 13 "#B294BB"
set_color 14 "#47B0AB"
set_color 15 "#ECEBE6"

# 256 color space
set_color 208 "#E58C4F"

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
