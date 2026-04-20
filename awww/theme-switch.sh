#!/bin/bash
WP="$1"

awww img "$WP" --transition-type fade

if [[ "$WP" == *"knights.jpg"* ]]; then
    cp ~/.config/waybar/style-knights.css ~/.config/waybar/style.css
elif [[ "$WP" == *"mainwp.png"* ]]; then
    cp ~/.config/waybar/style-pink.css ~/.config/waybar/style.css
fi

pkill -SIGUSR2 waybar