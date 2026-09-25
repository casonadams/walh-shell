#!/bin/sh
dir="$(dirname "$0")"

# shellcheck disable=SC1091
WALH_SHELL="$dir" . "$dir/walh.sh"
_walh_list "$@"
