#!/bin/bash
colors_json="$HOME/.cache/wal/colors.json"

color_good=$(jq -r '.colors.color2' "$colors_json")
color_degraded=$(jq -r '.colors.color3' "$colors_json")
color_bad=$(jq -r '.colors.color1' "$colors_json")

cat > ~/.config/i3status/colors.conf <<EOF
general {
    colors = true
    color_good = "$color_good"
    color_degraded = "$color_degraded"
    color_bad = "$color_bad"
}
EOF
