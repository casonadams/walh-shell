#!/usr/bin/env bash
# Theme: github

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

set_foreground "#3e3e3e"
set_background "#ffffff"

# 16 color space
set_color 0 "#e2e2e2"
set_color 1 "#970b16"
set_color 2 "#07962a"
set_color 3 "#dfb71c"
set_color 4 "#003e8a"
set_color 5 "#e94691"
set_color 6 "#89d1ec"
set_color 7 "#3e3e3e"
set_color 8 "#666666"
set_color 9 "#970b16"
set_color 10 "#07962a"
set_color 11 "#dfb71c"
set_color 12 "#003e8a"
set_color 13 "#e94691"
set_color 14 "#89d1ec"
set_color 15 "#232323"

# 256 color space
set_color 208 "#bb6119"

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
