#!/usr/bin/env bash
# Theme: greyscale-dark

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

set_foreground "#B9B9B9"
set_background "#101010"

# 16 color space
set_color 0 "#1C1C1C"
set_color 1 "#7C7C7C"
set_color 2 "#8E8E8E"
set_color 3 "#A0A0A0"
set_color 4 "#686868"
set_color 5 "#747474"
set_color 6 "#868686"
set_color 7 "#B9B9B9"
set_color 8 "#525252"
set_color 9 "#7C7C7C"
set_color 10 "#8E8E8E"
set_color 11 "#A0A0A0"
set_color 12 "#686868"
set_color 13 "#747474"
set_color 14 "#868686"
set_color 15 "#F7F7F7"

# 256 color space
set_color 208 "#8E8E8E"

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
