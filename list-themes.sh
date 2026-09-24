#!/bin/sh
dir="$(dirname "$0")"

case "${1:-}" in
  --dark|-d)
    grep -l '^export WALH_MODE=dark' "$dir/scripts/"*.sh 2>/dev/null | while read -r f; do
      basename "$f" .sh
    done | sort ;;
  --light|-l)
    grep -l '^export WALH_MODE=light' "$dir/scripts/"*.sh 2>/dev/null | while read -r f; do
      basename "$f" .sh
    done | sort ;;
  *)
    for f in "$dir/scripts/"*.sh; do
      [ -f "$f" ] && basename "$f" .sh
    done | sort ;;
esac
