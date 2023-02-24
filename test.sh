#!/usr/bin/env bash

if [ -f "${HOME}/.walh_theme" ]; then
  filename="$(cat "${HOME}/.walh_theme")"
  echo $filename
  # "${_WALH_SHELL}/template.sh" "${filename}"
fi

