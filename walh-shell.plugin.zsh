#!/usr/bin/env zsh

export _WALH_SHELL=$(dirname "${(%):-%x}")

[ -n "$PS1" ] \
    && [ -s "${_WALH_SHELL}/profile_helper.sh" ] \
    && eval "$("${_WALH_SHELL}/profile_helper.sh")"
