#!/usr/bin/env bash
# Theme: tokyo-night-storm

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

set_foreground "#A9B1D6"
set_background "#24283B"

# 16 color space
set_color 0 "#32344A"
set_color 1 "#F7768E"
set_color 2 "#9ECE6A"
set_color 3 "#E0AF68"
set_color 4 "#7AA2F7"
set_color 5 "#AD8EE6"
set_color 6 "#449DAB"
set_color 7 "#9699A8"
set_color 8 "#444B6A"
set_color 9 "#F7768E"
set_color 10 "#9ECE6A"
set_color 11 "#E0AF68"
set_color 12 "#7AA2F7"
set_color 13 "#AD8EE6"
set_color 14 "#449DAB"
set_color 15 "#ACB0D0"

# 256 color space
set_color 208 "#EC937B"

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
