#!/usr/bin/env bash
# Theme: vscode

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

set_foreground "#CCCCCC"
set_background "#1E1E1E"

# 16 color space
set_color 0 "#2B2B2B"
set_color 1 "#CD3131"
set_color 2 "#0DBC79"
set_color 3 "#E5E510"
set_color 4 "#2472C8"
set_color 5 "#BC3FBC"
set_color 6 "#11A8CD"
set_color 7 "#E5E5E5"
set_color 8 "#666666"
set_color 9 "#F14C4C"
set_color 10 "#23D18B"
set_color 11 "#F5F543"
set_color 12 "#3B8EEA"
set_color 13 "#D670D6"
set_color 14 "#29B8DB"
set_color 15 "#E5E5E5"

# 256 color space
set_color 208 "#D98B21"

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
