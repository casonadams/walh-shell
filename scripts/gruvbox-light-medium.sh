#!/usr/bin/env bash
# Theme: gruvbox-light-medium

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

set_foreground "#504945"
set_background "#FBF1C7"

# 16 color space
set_color 0 "#EBDBB2"
set_color 1 "#9D0006"
set_color 2 "#79740E"
set_color 3 "#B57614"
set_color 4 "#076678"
set_color 5 "#8F3F71"
set_color 6 "#427B58"
set_color 7 "#504945"
set_color 8 "#BDAE93"
set_color 9 "#9D0006"
set_color 10 "#79740E"
set_color 11 "#B57614"
set_color 12 "#076678"
set_color 13 "#8F3F71"
set_color 14 "#427B58"
set_color 15 "#282828"

# 256 color space
set_color 208 "#AF3A03"

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
