#!/usr/bin/env bash

filename="${1}"
source "${filename}"

echo -ne "${filename}" > "${HOME}/.walh_theme"

set_foreground() {
  hex_color="${1}"
  printf "\e]10;%s\e\\" "${hex_color}"
}

set_background() {
  hex_color="${1}"
  printf "\e]11;%s\e\\" "${hex_color}"
}

set_color() {
  color_index="${1}"
  hex_color="${2}"
  printf "\e]4;%d;%s\e\\" "${color_index}" "${hex_color}"
}

set_foreground "${foreground}"
set_background "${background}"

# color space
set_color 0   "${color00}"
set_color 1   "${color01}"
set_color 2   "${color02}"
set_color 3   "${color03}"
set_color 4   "${color04}"
set_color 5   "${color05}"
set_color 6   "${color06}"
set_color 7   "${color07}"
set_color 8   "${color08}"
set_color 9   "${color09}"
set_color 10  "${color10}"
set_color 11  "${color11}"
set_color 12  "${color12}"
set_color 13  "${color13}"
set_color 14  "${color14}"
set_color 15  "${color15}"
set_color 208 "${color208}"

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
