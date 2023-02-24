#!/usr/bin/env bash
# Theme: iterm-default

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

set_foreground "#FFFBF6"
set_background "#101421"

# 16 color space
set_color 0 "#191F34"
set_color 1 "#EB4129"
set_color 2 "#ABE047"
set_color 3 "#F6C744"
set_color 4 "#47A0F3"
set_color 5 "#7B5CB0"
set_color 6 "#64DBED"
set_color 7 "#E5E9F0"
set_color 8 "#565656"
set_color 9 "#EC5357"
set_color 10 "#C0E17D"
set_color 11 "#F9DA6A"
set_color 12 "#49A4F8"
set_color 13 "#A47DE9"
set_color 14 "#99FAF2"
set_color 15 "#FFFFFF"

# 256 color space
set_color 208 "#F18437"

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
