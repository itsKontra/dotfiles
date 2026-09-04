# Dotfiles & System Configurations

Personal dotfiles and system configurations for Hyprland, Ryoku Shell, Quickshell, terminal emulators, and shell environments.

Repository: **[itsKontra/dotfiles](https://github.com/itsKontra/dotfiles)** (Private)

---

## Quick Start on a New System

To deploy these configurations onto another system:

```bash
# 1. Clone the repository
git clone https://github.com/itsKontra/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Preview what will be deployed (safe dry-run)
./copy-to-system.sh --dry-run

# 3. Deploy configurations to ~/.config and ~/
./copy-to-system.sh
```

> **Note:** Existing files and folders on the destination system are automatically backed up to `~/.dotfiles_backup_<timestamp>/` before being overwritten.

### Alternative Deployment Modes

- **Symlink mode** (keeps files linked to the repository so git tracks live edits):
  ```bash
  ./copy-to-system.sh --symlink
  ```
- **Skip confirmation prompt**:
  ```bash
  ./copy-to-system.sh -y
  ```

---

## Syncing Changes Back to the Repository

When you make changes on your system and want to update this repository:

```bash
cd ~/dotfiles

# Sync all configs from ~/.config and ~/ into this repository
./copy-from-system.sh

# Or sync and automatically commit & push to GitHub in one step:
./copy-from-system.sh --push -m "Update hyprland keybindings"
```

Aliases provided:
- `./sync.sh` -> `./copy-from-system.sh`
- `./install.sh` -> `./copy-to-system.sh`

---

## Repository Structure & Mapping

All configuration directories and files are placed directly in the repository root for clean browsing and easy copying.

| Repo Item | Destination | Description |
|---|---|---|
| `hypr/` | `~/.config/hypr/` | Hyprland compositor config, Lua modules, bindings & shaders |
| `quickshell/` | `~/.config/quickshell/` | Ryoku desktop shell, modules, hub, and bar |
| `ryoku/` | `~/.config/ryoku/` | Ryoku settings (theme, shell, matugen, widgets) |
| `ryogami-wall/` | `~/.config/ryogami-wall/` | Wallpaper daemon configuration |
| `ryoku-terminal/` | `~/.config/ryoku-terminal/` | Terminal wrapper configuration |
| `qylock/` | `~/.config/qylock/` | Screen lock configuration |
| `kitty/` | `~/.config/kitty/` | Kitty terminal emulator config & themes |
| `ghostty/` | `~/.config/ghostty/` | Ghostty terminal configuration |
| `alacritty/` | `~/.config/alacritty/` | Alacritty terminal configuration |
| `wezterm/` | `~/.config/wezterm/` | WezTerm terminal configuration |
| `fish/` | `~/.config/fish/` | Fish shell functions, completions, and config |
| `zsh/` | `~/.config/zsh/` | Zsh config directory |
| `bash/` | `~/.config/bash/` | Bash config directory |
| `starship/` | `~/.config/starship/` | Starship cross-shell prompt presets |
| `fastfetch/` | `~/.config/fastfetch/` | Fastfetch system fetch configuration & distro emblems |
| `waybar/` | `~/.config/waybar/` | Waybar status bar configuration & styles |
| `waybar-weather/` | `~/.config/waybar-weather/`| Waybar weather module scripts |
| `swaync/` | `~/.config/swaync/` | SwayNotificationCenter config & css |
| `wlogout/` | `~/.config/wlogout/` | Wlogout lock/logout/reboot menu |
| `rofi/` | `~/.config/rofi/` | Rofi application launcher configs |
| `swappy/` | `~/.config/swappy/` | Swappy screenshot editor config |
| `matugen/` | `~/.config/matugen/` | Material You color scheme generator templates |
| `wallust/` | `~/.config/wallust/` | Wallust color palette generator config |
| `nvim/` | `~/.config/nvim/` | Neovim configuration |
| `micro/` | `~/.config/micro/` | Micro editor settings & keybindings |
| `zed/` | `~/.config/zed/` | Zed editor settings & keymaps |
| `yazi/` | `~/.config/yazi/` | Yazi terminal file manager configuration |
| `btop/` | `~/.config/btop/` | Btop system monitor theme & config |
| `cava/` | `~/.config/cava/` | Cava audio visualizer config |
| `tmux/` | `~/.config/tmux/` | Tmux terminal multiplexer config |
| `zathura/` | `~/.config/zathura/` | Zathura document viewer config |
| `gtk-3.0/` | `~/.config/gtk-3.0/` | GTK 3 theme, bookmarks, and CSS |
| `gtk-4.0/` | `~/.config/gtk-4.0/` | GTK 4 settings and CSS |
| `qt5ct/` | `~/.config/qt5ct/` | Qt5 theme configuration |
| `qt6ct/` | `~/.config/qt6ct/` | Qt6 theme configuration |
| `Kvantum/` | `~/.config/Kvantum/` | Kvantum SVG-based Qt theme engine |
| `nwg-dock-hyprland/` | `~/.config/nwg-dock-hyprland/` | Hyprland dock configuration |
| `nwg-look/` | `~/.config/nwg-look/` | GTK settings config |
| `hyprland-preview-share-picker/` | `~/.config/hyprland-preview-share-picker/` | Wayland screen share picker |
| `xdg-desktop-portal/` | `~/.config/xdg-desktop-portal/` | XDG desktop portal configurations |
| `xsettingsd/` | `~/.config/xsettingsd/` | XSettings daemon configuration |
| `wireplumber/` | `~/.config/wireplumber/` | PipeWire WirePlumber audio policies |
| `autostart/` | `~/.config/autostart/` | User desktop autostart entries |
| `Thunar/` | `~/.config/Thunar/` | Thunar file manager configuration |
| `vesktop/` | `~/.config/vesktop/` | Vesktop Discord client settings (caches excluded) |
| `equibop/` | `~/.config/equibop/` | Equibop Discord client configuration |
| `heroic/` | `~/.config/heroic/` | Heroic Games Launcher configuration |
| `obs-studio/` | `~/.config/obs-studio/` | OBS Studio profiles and scenes |
| `spicetify/` | `~/.config/spicetify/` | Spicetify theme configuration |
| `chromium-flags.conf` | `~/.config/` | Wayland/Electron performance flags |
| `mimeapps.list` | `~/.config/` | Default application associations |
| `user-dirs.dirs` | `~/.config/` | XDG user directory locations |
| `user-dirs.locale` | `~/.config/` | XDG user directory locale |
| `.bashrc` | `~/` | Interactive Bash shell configuration |
| `.bash_profile` | `~/` | Bash login configuration |
| `.profile` | `~/` | POSIX environment configuration |
| `.zshrc` | `~/` | Interactive Zsh shell configuration |
| `.zprofile` | `~/` | Zsh login environment |
| `.gitconfig` | `~/` | Git configuration and credential helper |
| `.gtkrc-2.0` | `~/` | GTK 2 styling |

---

## Manual Copy Instructions

If you prefer copying individual configurations manually without running `./copy-to-system.sh`:

```bash
# Ensure ~/.config exists
mkdir -p ~/.config

# Copy specific desktop configs
cp -r hypr ~/.config/
cp -r quickshell ~/.config/
cp -r ryoku ~/.config/
cp -r kitty ~/.config/
cp -r fish ~/.config/
cp -r waybar ~/.config/
cp -r swaync ~/.config/

# Copy home dotfiles
cp .zshrc .bashrc .gitconfig ~
```

---

## Excluded / Sanitized Data

To preserve privacy and prevent repository bloat, the synchronization script automatically excludes:
- Authentication tokens, passwords, and private SSH keys
- Browser session data, cookies, and local storage (`chromium`, `mozilla`, `gh/hosts.yml`)
- Caches and runtime state (`*cache*`, `*.log`, `*.sock`, `*.lock`, `*.pid`)
- Old backup folders (`*-backup-*`, `*-back-up*`)
