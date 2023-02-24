#!/usr/bin/env bash
# Theme: onedark

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

set_foreground "#ABB2BF"
set_background "#282C34"

# 16 color space
set_color 0 "#353B45"
set_color 1 "#E06C75"
set_color 2 "#98C379"
set_color 3 "#E5C07B"
set_color 4 "#61AFEF"
set_color 5 "#C678DD"
set_color 6 "#56B6C2"
set_color 7 "#ABB2BF"
set_color 8 "#545862"
set_color 9 "#E06C75"
set_color 10 "#98C379"
set_color 11 "#E5C07B"
set_color 12 "#61AFEF"
set_color 13 "#C678DD"
set_color 14 "#56B6C2"
set_color 15 "#C8CCD4"

# 256 color space
set_color 208 "#D19A66"

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
