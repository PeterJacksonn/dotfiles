#!/usr/bin/env bash

colors_json="$HOME/.cache/wal/colors.json"

# Make sure colors.json exists
if [[ ! -f "$colors_json" ]]; then
  echo "Pywal colors file not found!"
  exit 1
fi

color_bg=$(jq -r '.colors.color0' "$colors_json")
color_fg=$(jq -r '.colors.color1' "$colors_json")
color_primary=$(jq -r '.colors.color2' "$colors_json")
color_secondary=$(jq -r '.colors.color3' "$colors_json")
color_alert=$(jq -r '.colors.color4' "$colors_json")
color_disabled=$(jq -r '.colors.color7' "$colors_json")

cat > ~/.config/polybar/colors.ini <<EOF
[colors]
background = $color_bg
foreground = $color_fg
primary = $color_primary
secondary = $color_secondary
alert = $color_alert
disabled = $color_disabled
EOF
