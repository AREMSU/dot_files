#!/bin/bash

THEMES_CONF="$HOME/.config/awww/themes.conf"
COLORS_DIR="$HOME/.config/waybar/colors"
WALLPAPERS_DIR="$HOME/Wallpapers"

INPUT="$1"

if [[ -z "$INPUT" ]]; then
    echo "Usage: theme-switch.sh <wallpaper_path|theme_name>"
    exit 1
fi

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

if [[ "$INPUT" == *"/"* ]]; then
    WALLPAPER_FILE=$(basename "$INPUT")
    THEME=""
    for i in "${!WALLPAPERS[@]}"; do
        if [[ "${WALLPAPERS[$i]}" == "$WALLPAPER_FILE" ]]; then
            THEME="${THEMES[$i]}"
            break
        fi
    done
    if [[ -z "$THEME" ]]; then
        echo "No theme mapped for wallpaper: $WALLPAPER_FILE"
        exit 1
    fi
    WALLPAPER_PATH="$INPUT"
else
    THEME="$INPUT"
    WALLPAPER_FILE=""
    for i in "${!THEMES[@]}"; do
        if [[ "${THEMES[$i]}" == "$THEME" ]]; then
            WALLPAPER_FILE="${WALLPAPERS[$i]}"
            break
        fi
    done
    WALLPAPER_PATH="$WALLPAPERS_DIR/$WALLPAPER_FILE"
fi

THEME_CSS="$COLORS_DIR/${THEME}.css"
if [[ ! -f "$THEME_CSS" ]]; then
    echo "Theme CSS not found: $THEME_CSS"
    exit 1
fi

# Apply theme first and let waybar settle
cp "$THEME_CSS" "$COLORS_DIR/active.css"
pkill -SIGUSR2 waybar

# Then switch wallpaper after waybar has reloaded
sleep 0.3
awww img "$WALLPAPER_PATH" --transition-type fade

echo "Done! Active theme: $THEME"
