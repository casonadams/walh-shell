#!/usr/bin/env bash
# Theme: utah-dark

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

set_foreground "#696B69"
set_background "#0A0B0C"

# 16 color space
set_color 0 "#101214"
set_color 1 "#6D3333"
set_color 2 "#606434"
set_color 3 "#81693B"
set_color 4 "#435565"
set_color 5 "#5E4D63"
set_color 6 "#486561"
set_color 7 "#696B69"
set_color 8 "#4E4F4E"
set_color 9 "#6D3333"
set_color 10 "#606434"
set_color 11 "#81693B"
set_color 12 "#435565"
set_color 13 "#5E4D63"
set_color 14 "#486561"
set_color 15 "#898989"

# 256 color space
set_color 208 "#774D2F"

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
