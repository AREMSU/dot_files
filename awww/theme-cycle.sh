#!/bin/bash

THEMES_CONF="$HOME/.config/awww/themes.conf"
COLORS_DIR="$HOME/.config/waybar/colors"
WALLPAPERS_DIR="$HOME/Wallpapers"
CURRENT_THEME_FILE="$HOME/.config/awww/current-theme"

THEMES=()
WALLPAPERS=()

while IFS='=' read -r wp theme; do
    [[ "$wp" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$wp" || -z "$theme" ]] && continue
    wp=$(echo "$wp" | xargs)
    theme=$(echo "$theme" | xargs)
    WALLPAPERS+=("$wp")
    THEMES+=("$theme")
done < "$THEMES_CONF"

THEME_COUNT=${#THEMES[@]}

if [[ $THEME_COUNT -eq 0 ]]; then
    echo "No themes found in $THEMES_CONF"
    exit 1
fi

CURRENT=0
[[ -f "$CURRENT_THEME_FILE" ]] && CURRENT=$(cat "$CURRENT_THEME_FILE")

if [[ "$1" == "--back" ]]; then
    NEXT=$(( (CURRENT - 1 + THEME_COUNT) % THEME_COUNT ))
else
    NEXT=$(( (CURRENT + 1) % THEME_COUNT ))
fi

NEXT_THEME="${THEMES[$NEXT]}"
NEXT_WALLPAPER="${WALLPAPERS[$NEXT]}"

THEME_CSS="$COLORS_DIR/${NEXT_THEME}.css"
if [[ ! -f "$THEME_CSS" ]]; then
    echo "Theme CSS not found: $THEME_CSS"
    exit 1
fi

# Apply theme first and let waybar settle
cp "$THEME_CSS" "$COLORS_DIR/active.css"
pkill -SIGUSR2 waybar

# Then switch wallpaper after waybar has reloaded
sleep 0.3
awww img "$WALLPAPERS_DIR/$NEXT_WALLPAPER" --transition-type fade

echo "$NEXT" > "$CURRENT_THEME_FILE"
echo "Done! Active theme: $NEXT_THEME"
