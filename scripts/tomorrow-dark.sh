#!/usr/bin/env bash
# Theme: tomorrow-dark

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

set_foreground "#D7D9DC"
set_background "#1D1F21"

# 16 color space
set_color 0 "#282A2E"
set_color 1 "#CC6666"
set_color 2 "#B5BD68"
set_color 3 "#F0C674"
set_color 4 "#81A2BE"
set_color 5 "#B294BB"
set_color 6 "#8ABEB7"
set_color 7 "#8E9092"
set_color 8 "#67686B"
set_color 9 "#CC6666"
set_color 10 "#B5BD68"
set_color 11 "#F0C674"
set_color 12 "#81A2BE"
set_color 13 "#B294BB"
set_color 14 "#8ABEB7"
set_color 15 "#FCFCFC"

# 256 color space
set_color 208 "#DE935F"

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
