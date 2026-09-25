#!/usr/bin/env bash
# ==============================================================================
# copy-from-system.sh (sync.sh)
# Copies configurations from the running system into this repository root.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
HOME_DIR="$HOME"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

DRY_RUN=false
AUTO_PUSH=false
COMMIT_MSG=""

usage() {
    cat << HELP
Usage: $(basename "$0") [OPTIONS]

Copies configuration files and directories from the system into this repository root.

Options:
  -n, --dry-run      Show what would be copied without making changes
  -p, --push         Automatically commit and push changes to GitHub after copying
  -m, --message MSG  Custom commit message when using --push
  -h, --help         Show this help message

HELP
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -p|--push)
            AUTO_PUSH=true
            shift
            ;;
        -m|--message)
            COMMIT_MSG="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown argument: $1${NC}"
            usage
            ;;
    esac
done

echo -e "${BLUE}==>${NC} Starting dotfiles backup from system to repository..."
echo -e "    Source ~/.config: ${CONFIG_DIR}"
echo -e "    Target repo root: ${SCRIPT_DIR}"
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}    [DRY RUN MODE: No files will be modified]${NC}"
fi
echo ""

# Configuration directories to copy from ~/.config into repo root
CONFIG_DIRS=(
    "hypr"
    "ryoku"
    "ryogami-wall"
    "ryoku-terminal"
    "qylock"
    "kitty"
    "ghostty"
    "alacritty"
    "wezterm"
    "fish"
    "zsh"
    "bash"
    "tmux"
    "starship"
    "fastfetch"
    "waybar"
    "waybar-weather"
    "swaync"
    "wlogout"
    "rofi"
    "swappy"
    "matugen"
    "wallust"
    "nvim"
    "micro"
    "zed"
    "yazi"
    "btop"
    "cava"
    "zathura"
    "gtk-3.0"
    "gtk-4.0"
    "qt5ct"
    "qt6ct"
    "Kvantum"
    "nwg-dock-hyprland"
    "nwg-look"
    "hyprland-preview-share-picker"
    "xdg-desktop-portal"
    "xsettingsd"
    "wireplumber"
    "Thunar"
    "vesktop"
    "equibop"
    "heroic"
    "obs-studio"
    "spicetify"
)

# Individual config files to copy from ~/.config into repo root
CONFIG_FILES=(
    "chromium-flags.conf"
    "mimeapps.list"
    "user-dirs.dirs"
    "user-dirs.locale"
)

# Home dotfiles to copy from ~ into repo root
HOME_FILES=(
    ".bashrc"
    ".bash_profile"
    ".profile"
    ".zshrc"
    ".zprofile"
    ".gitconfig"
    ".gtkrc-2.0"
)

RSYNC_EXCLUDES=(
    "--exclude=*cache*"
    "--exclude=*Cache*"
    "--exclude=*.log"
    "--exclude=*.sock"
    "--exclude=*.lock"
    "--exclude=*.pid"
    "--exclude=*.tmp"
    "--exclude=*.bak"
    "--exclude=*.swp"
    "--exclude=*backup*"
    "--exclude=*back-up*"
    "--exclude=Session Storage"
    "--exclude=IndexedDB"
    "--exclude=blob_storage"
    "--exclude=Local Storage"
    "--exclude=Partitions"
    "--exclude=DawnCache"
    "--exclude=GPUCache"
    "--exclude=.git"
)

COPIED_COUNT=0
SKIPPED_COUNT=0

# 1. Copy config directories
echo -e "${BLUE}--- Copying ~/.config directories ---${NC}"
for dir in "${CONFIG_DIRS[@]}"; do
    src="${CONFIG_DIR}/${dir}"
    dst="${SCRIPT_DIR}/${dir}"

    if [[ -d "$src" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "  [SIMULATE] Copying dir: ${dir}"
        else
            mkdir -p "$dst"
            rsync -a --delete "${RSYNC_EXCLUDES[@]}" "${src}/" "${dst}/"
            echo -e "  ${GREEN}✓${NC} Copied dir: ${dir}"
        fi
        COPIED_COUNT=$((COPIED_COUNT + 1))
    else
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    fi
done

# 2. Copy config files
echo -e "\n${BLUE}--- Copying ~/.config individual files ---${NC}"
for file in "${CONFIG_FILES[@]}"; do
    src="${CONFIG_DIR}/${file}"
    dst="${SCRIPT_DIR}/${file}"

    if [[ -f "$src" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "  [SIMULATE] Copying file: ${file}"
        else
            cp -p "$src" "$dst"
            echo -e "  ${GREEN}✓${NC} Copied file: ${file}"
        fi
        COPIED_COUNT=$((COPIED_COUNT + 1))
    else
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    fi
done

# 3. Copy home dotfiles
echo -e "\n${BLUE}--- Copying home dotfiles from ~/ ---${NC}"
for file in "${HOME_FILES[@]}"; do
    src="${HOME_DIR}/${file}"
    dst="${SCRIPT_DIR}/${file}"

    if [[ -f "$src" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "  [SIMULATE] Copying dotfile: ${file}"
        else
            cp -p "$src" "$dst"
            echo -e "  ${GREEN}✓${NC} Copied dotfile: ${file}"
        fi
        COPIED_COUNT=$((COPIED_COUNT + 1))
    else
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    fi
done

echo ""
echo -e "${GREEN}==>${NC} Finished syncing configurations!"
echo -e "    Items processed: ${COPIED_COUNT} (Not found / skipped: ${SKIPPED_COUNT})"

if [[ "$DRY_RUN" == true ]]; then
    exit 0
fi

# 4. Optional auto commit & push
if [[ "$AUTO_PUSH" == true ]]; then
    echo ""
    echo -e "${BLUE}==>${NC} Staging and pushing changes to GitHub..."
    cd "$SCRIPT_DIR"
    git add -A

    # Refuse to push anything that looks like a credential
    if command -v gitleaks &> /dev/null; then
        if ! gitleaks protect --staged --no-banner; then
            echo -e "${RED}gitleaks found possible secrets. Nothing was committed.${NC}"
            git reset -q
            exit 1
        fi
    elif git diff --cached -U0 | grep -nE '^\+.*((api[_-]?key|secret|password|passwd|token)["'\'']?\s*[:=]\s*["'\'']?[A-Za-z0-9_./+-]{16,}|ghp_[A-Za-z0-9]{36}|github_pat_|sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY)'; then
        echo -e "${RED}Possible secrets found in the lines above. Nothing was committed.${NC}"
        git reset -q
        exit 1
    fi

    if git diff-index --quiet HEAD --; then
        echo -e "${YELLOW}No changes to commit.${NC}"
    else
        if [[ -z "$COMMIT_MSG" ]]; then
            COMMIT_MSG="Sync configs from $(hostname) on $(date '+%Y-%m-%d %H:%M:%S')"
        fi
        git commit -m "$COMMIT_MSG"
        git push origin main
        echo -e "${GREEN}✓ Successfully pushed to GitHub!${NC}"
    fi
else
    echo ""
    echo -e "Tip: Run ${YELLOW}git status${NC} in ${SCRIPT_DIR} to view changes,"
    echo -e "or pass ${YELLOW}--push${NC} to this script to auto-commit and push."
fi
