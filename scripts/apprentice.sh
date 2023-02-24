#!/usr/bin/env bash
# Theme: apprentice

set_foreground() {
  hex_color=$1
  printf "\e]10;%s\e\\" "$hex_color"
}

set_background() {
  hex_color=$1
  printf "\e]11;%s\e\\" "$hex_color"
}

set_color() {
  color_index=$1
  hex_color=$2
  printf "\e]4;%d;%s\e\\" "$color_index" "$hex_color"
}

set_foreground "#BCBCBC"
set_background "#262626"

# 16 color space
set_color 0 "#333333"
set_color 1 "#AF5F5F"
set_color 2 "#5F875F"
set_color 3 "#87875F"
set_color 4 "#5F87AF"
set_color 5 "#5F5F87"
set_color 6 "#5F8787"
set_color 7 "#BCBCBC"
set_color 8 "#515151"
set_color 9 "#AF5F5F"
set_color 10 "#5F875F"
set_color 11 "#87875F"
set_color 12 "#5F87AF"
set_color 13 "#5F5F87"
set_color 14 "#5F8787"
set_color 15 "#FFFFFF"

# 256 color space
set_color 208 "#9B735F"

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
