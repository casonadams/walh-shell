#!/usr/bin/env bash

cat << 'FUNC'
_walh() {
local filename="${1}"
  ${_WALH_SHELL}/template.sh "${filename}"
}
FUNC

for filename in "${_WALH_SHELL}"/themes/*.sh; do
  if [[ ! -f "$filename" ]]; then
    break
  fi
  theme=$(basename -s .sh "${filename}")
  walh_func_name="walh_${theme}"
  echo "alias $walh_func_name=\"_walh ${filename}\""
done;


for filename in "${HOME}"/.config/walh/themes/*.sh; do
  if [[ ! -f "$filename" ]]; then
    break
  fi

  theme=$(basename -s .sh "${filename}")
  walh_func_name="walh_${theme}"
  echo "alias $walh_func_name=\"_walh ${filename}\""
done;

if [ -f "${HOME}/.walh_theme" ]; then
  filename="$(cat "${HOME}/.walh_theme")"
  bash "${_WALH_SHELL}"/template.sh "${filename}"
fi
