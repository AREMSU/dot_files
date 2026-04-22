# AREMSU's Dotfiles

A personal Arch Linux + Hyprland setup with a multi-theme wallpaper switching system.

## System

| Component | Package |
|-----------|---------|
| OS | Arch Linux |
| WM | Hyprland |
| Bar | Waybar |
| Terminal | Kitty |
| Shell | Zsh + Oh My Zsh + Powerlevel10k |
| Launcher | Rofi |
| Notifications | Swaync |
| Wallpaper | awww |
| File Manager | Thunar |
| Lock Screen | Hyprlock |
| Logout | Wlogout |
| Audio | Pipewire + Wireplumber |

## Theme System

Wallpapers and waybar themes are linked — switching wallpaper automatically switches the bar colors to match.

Themes live in `~/.config/waybar/colors/` and wallpaper→theme mappings are in `~/.config/awww/themes.conf`.

### Switching themes

```bash
# Cycle forward through all themes
Super + T

# Cycle backward
Super + Shift + T

# Switch to a specific wallpaper and theme
~/.config/awww/theme-switch.sh ~/Wallpapers/knights.jpg
```

### Adding a new theme

1. Add a new color file to `waybar/colors/newtheme.css` using the existing ones as a template
2. Add one line to `awww/themes.conf`:
   ```
   newwallpaper.jpg=newtheme
   ```
3. That's it — the cycle script picks it up automatically

### Current themes

| Theme | Wallpaper | Vibe |
|-------|-----------|------|
| apprentice | mainwp.png | Soft pink/beige — warm and cozy |
| knights | knights.jpg | Dark iron and gold — pulled from artwork |
| emerald | biggubs.jpg | Jade and celadon — light and fresh |

## Keybinds

| Keybind | Action |
|---------|--------|
| Super + Q | Terminal (Kitty) |
| Super + E | File Manager (Thunar) |
| Super + B | Browser (Firefox) |
| Super + N | Notes (Obsidian) |
| Super + D | App Launcher (Rofi) |
| Super + T | Cycle theme forward |
| Super + Shift + T | Cycle theme backward |
| Super + L | Lock screen (Hyprlock) |
| Super + C | Kill active window |
| Super + F | Fullscreen |
| Super + V | Toggle floating |
| Super + Tab | Cycle windows |
| Super + arrows | Move focus |
| Super + Shift + arrows | Move window |
| Super + Ctrl + arrows | Resize window |
| Super + Shift + S | Screenshot selection → clipboard |
| Print | Screenshot → ~/Pictures |
| Super + 1-0 | Switch workspace |
| Super + Shift + 1-0 | Move window to workspace |
| Super + R | Reload Hyprland |
| Super + M | Exit Hyprland |

## Fresh Install

### Prerequisites
- Fresh Arch Linux install
- Internet connection
- Git installed (`sudo pacman -S git`)

### Steps

```bash
# Clone the repo
git clone git@github.com:AREMSU/dot_files.git ~/dotfiles-repo

# Run the install script
cd ~/dotfiles-repo
chmod +x install.sh
./install.sh
```

The script will:
- Update the system
- Install yay (AUR helper)
- Install all packages from `packages.txt` and `packages-aur.txt`
- Set up zsh with oh-my-zsh and powerlevel10k
- Symlink all config files into `~/.config`
- Copy wallpapers to `~/Wallpapers`
- Set up SSH agent
- Enable pipewire services
- Set initial wallpaper and theme

### After install

1. Reboot and log into Hyprland
2. Run `p10k configure` if the prompt looks wrong
3. Set up SSH keys for GitHub
4. Log into Brave, Spotify, Discord, Viber, Zoom

## Structure

```
dotfiles-repo/
├── install.sh              # Fresh install script
├── packages.txt            # Official pacman packages
├── packages-aur.txt        # AUR packages
├── README.md
├── Wallpapers/             # All wallpapers (stored via git lfs)
├── awww/
│   ├── theme-switch.sh     # Switch to specific theme
│   ├── theme-cycle.sh      # Cycle through all themes
│   └── themes.conf         # Wallpaper → theme mappings
├── waybar/
│   ├── config.jsonc
│   ├── style.css           # Permanent — imports colors/active.css
│   ├── colors/
│   │   ├── active.css      # Currently active theme (overwritten on switch)
│   │   ├── apprentice.css
│   │   ├── knights.css
│   │   └── emerald.css
│   └── scripts/
├── hypr/
│   ├── hyprland.conf
│   ├── hyprlock.conf
│   └── keybinds/
│       └── keybinds.conf
├── kitty/
├── rofi/
├── swaync/
├── wlogout/
├── pipewire/
├── gtk-3.0/
├── gtk-4.0/
└── home/
    ├── .zshrc
    ├── .p10k.zsh
    ├── .gitconfig
    └── .gtkrc-2.0
```

## Notes

- Waybar v0.15.0 ignores the `style` key in config — `style.css` is used directly and overwritten on theme switch
- awww replaced swww as of October 2025
- hyprlock v0.9.3 removed `disable_loading_bar`, `grace`, `no_fade_in`, `no_fade_out` from the general block
