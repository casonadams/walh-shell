#!/bin/sh
# List all available walh-shell themes
for f in "$(dirname "$0")/scripts/"*.sh; do
  theme=$(basename "$f" .sh)
  echo "$theme"
done
