#!/usr/bin/env bash
# ==============================================================================
# copy-to-system.sh (install.sh)
# Deploys configurations from this repository onto the target system (~/.config and ~).
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
DO_SYMLINK=false
DO_BACKUP=true
AUTO_YES=false

usage() {
    cat << HELP
Usage: $(basename "$0") [OPTIONS]

Deploys configuration files and folders from this repository to ~/.config/ and ~/

Options:
  -s, --symlink    Create symlinks instead of copying files
  -n, --dry-run    Show what would be copied without making changes
  --no-backup      Do not create backup of existing files before overwriting
  -y, --yes        Skip interactive confirmation prompt
  -h, --help       Show this help message

HELP
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--symlink)
            DO_SYMLINK=true
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        --no-backup)
            DO_BACKUP=false
            shift
            ;;
        -y|--yes)
            AUTO_YES=true
            shift
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

# shellcheck source=lib/ryoku.sh
source "${SCRIPT_DIR}/lib/ryoku.sh"

# Non-config repository files/folders to NEVER deploy into ~/.config or ~/
IGNORED_REPO_ITEMS=(
    ".git"
    ".gitignore"
    ".github"
    "README.md"
    "copy-from-system.sh"
    "copy-to-system.sh"
    "sync.sh"
    "install.sh"
    "backup.sh"
    "restore.sh"
    "LICENSE"
    "LICENSE.md"
    "lib"
)

# Known home dotfiles that go to ~/ instead of ~/.config/
HOME_DOTFILES=(
    ".bashrc"
    ".bash_profile"
    ".profile"
    ".zshrc"
    ".zprofile"
    ".gitconfig"
    ".gtkrc-2.0"
)

is_ignored() {
    local name="$1"
    for ign in "${IGNORED_REPO_ITEMS[@]}"; do
        if [[ "$name" == "$ign" ]]; then
            return 0
        fi
    done
    return 1
}

is_home_dotfile() {
    local name="$1"
    for hf in "${HOME_DOTFILES[@]}"; do
        if [[ "$name" == "$hf" ]]; then
            return 0
        fi
    done
    return 1
}

echo -e "${BLUE}======================================================${NC}"
echo -e "${BLUE}          Dotfiles Deployment Script                  ${NC}"
echo -e "${BLUE}======================================================${NC}"
echo -e "  Source repo directory : ${SCRIPT_DIR}"
echo -e "  Target ~/.config dir  : ${CONFIG_DIR}"
echo -e "  Target Home dir       : ${HOME_DIR}"
echo -e "  Mode                  : $([[ "$DO_SYMLINK" == true ]] && echo 'Symlink' || echo 'Copy')"
echo -e "  Backup existing files : $([[ "$DO_BACKUP" == true ]] && echo 'Yes' || echo 'No')"
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}  [DRY RUN MODE: No files will be modified]${NC}"
fi
echo ""

if [[ "$AUTO_YES" == false && "$DRY_RUN" == false ]]; then
    read -r -p "Do you want to proceed with deploying configs to your system? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            ;;
        *)
            echo "Aborted."
            exit 0
            ;;
    esac
fi

TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"
BACKUP_DIR="${HOME_DIR}/.dotfiles_backup_${TIMESTAMP}"

backup_if_exists() {
    local target="$1"
    local rel_path="$2"

    if [[ -e "$target" || -L "$target" ]]; then
        if [[ "$DO_BACKUP" == true ]]; then
            local bkp_dest="${BACKUP_DIR}/${rel_path}"
            if [[ "$DRY_RUN" == true ]]; then
                echo -e "  ${YELLOW}[SIMULATE] Backup existing:${NC} ${target} -> ${bkp_dest}"
            else
                mkdir -p "$(dirname "$bkp_dest")"
                cp -a "$target" "$bkp_dest"
            fi
        fi
    fi
}

# deploy_file <repo file> <target>: copy or link one file into place.
deploy_file() {
    local src="$1" dst="$2"
    if [[ "$DRY_RUN" == true ]]; then
        return 0
    fi
    mkdir -p "$(dirname "$dst")"
    rm -f "$dst"
    if [[ "$DO_SYMLINK" == true ]]; then
        ln -s "$src" "$dst"
    else
        cp -a "$src" "$dst"
    fi
}

# deploy_config_dir <repo dir> <name>: merge the repo's files into
# ~/.config/<name> one by one. Files already there that the repo does not
# carry stay, and on Ryoku nothing Ryoku owns is overwritten with the repo's
# copy, so its shipped and rendered files keep coming from Ryoku.
deploy_config_dir() {
    local dir="$1" name="$2" target="${CONFIG_DIR}/$2" file rel
    local deployed=0 skipped=0

    # An earlier --symlink run linked the whole directory to the repo; writing
    # through that link would write into the repo itself.
    if [[ -L "$target" ]]; then
        backup_if_exists "$target" ".config/${name}"
        [[ "$DRY_RUN" == true ]] || rm -f "$target"
    fi

    while IFS= read -r -d '' file; do
        rel="${name}/${file#"${dir}/"}"
        if is_ryoku_system && is_ryoku_managed "$rel" "$file"; then
            skipped=$((skipped + 1))
            continue
        fi
        backup_if_exists "${CONFIG_DIR}/${rel}" ".config/${rel}"
        deploy_file "$file" "${CONFIG_DIR}/${rel}"
        deployed=$((deployed + 1))
    done < <(find "$dir" -type f -print0)

    local note="${deployed} files"
    if [[ $skipped -gt 0 ]]; then
        note+=", skipped ${skipped} Ryoku-managed"
    fi
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  [SIMULATE] Install to ~/.config/: ${name} (${note})"
    else
        echo -e "  ${GREEN}✓ ($([[ "$DO_SYMLINK" == true ]] && echo link || echo copy))${NC} ~/.config/${name} (${note})"
    fi
}

mkdir -p "$CONFIG_DIR"

DEPLOYED_CONFIGS=0
DEPLOYED_HOME=0

# Scan all items in the repository root directory
shopt -s dotglob nullglob
for item_path in "${SCRIPT_DIR}"/*; do
    item_name="$(basename "$item_path")"

    if is_ignored "$item_name"; then
        continue
    fi

    # Skip anything listed in .gitignore (e.g. quickshell, autostart)
    if git -C "$SCRIPT_DIR" check-ignore -q "$item_name"; then
        continue
    fi

    if is_home_dotfile "$item_name"; then
        # Target is ~/
        target_path="${HOME_DIR}/${item_name}"
        backup_if_exists "$target_path" "$item_name"

        if [[ "$DRY_RUN" == true ]]; then
            echo -e "  [SIMULATE] Install to ~/: ${item_name}"
        else
            if [[ "$DO_SYMLINK" == true ]]; then
                rm -rf "$target_path"
                ln -sf "$item_path" "$target_path"
                echo -e "  ${GREEN}✓ (link)${NC} ~/${item_name}"
            else
                rm -rf "$target_path"
                cp -a "$item_path" "$target_path"
                echo -e "  ${GREEN}✓ (copy)${NC} ~/${item_name}"
            fi
        fi
        DEPLOYED_HOME=$((DEPLOYED_HOME + 1))
    elif [[ -d "$item_path" ]]; then
        deploy_config_dir "$item_path" "$item_name"
        DEPLOYED_CONFIGS=$((DEPLOYED_CONFIGS + 1))
    elif is_ryoku_system && is_ryoku_managed "$item_name" "$item_path"; then
        echo -e "  - Skipped Ryoku-managed file: ${item_name}"
    else
        backup_if_exists "${CONFIG_DIR}/${item_name}" ".config/${item_name}"
        deploy_file "$item_path" "${CONFIG_DIR}/${item_name}"
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "  [SIMULATE] Install to ~/.config/: ${item_name}"
        else
            echo -e "  ${GREEN}✓${NC} ~/.config/${item_name}"
        fi
        DEPLOYED_CONFIGS=$((DEPLOYED_CONFIGS + 1))
    fi
done
shopt -u dotglob nullglob

if [[ ${#RYOKU_WARNINGS[@]} -gt 0 ]]; then
    echo -e "\n${YELLOW}The repo carries edited copies of these Ryoku-shipped files; they were not deployed.${NC}"
    echo -e "${YELLOW}Move the changes into the override beside them:${NC}"
    for rel in "${RYOKU_WARNINGS[@]}"; do
        echo -e "  ! ${rel} -> ${RYOKU_OVERRIDE_FOR[$rel]}"
    done
fi

# .gitconfig signs every commit through an external program (1Password's
# op-ssh-sign); without it every commit on this machine fails.
sign_program="$(git config --file "${HOME_DIR}/.gitconfig" gpg.ssh.program 2>/dev/null || true)"
if [[ "$DRY_RUN" == false && -n "$sign_program" && ! -x "$sign_program" ]]; then
    echo -e "\n${YELLOW}~/.gitconfig signs commits with ${sign_program}, which is not installed here.${NC}"
    echo -e "${YELLOW}Install it, or run: git config --global commit.gpgsign false${NC}"
fi

echo ""
echo -e "${GREEN}==>${NC} Deployment finished successfully!"
echo -e "    ~/.config items deployed : ${DEPLOYED_CONFIGS}"
echo -e "    Home items (~) deployed  : ${DEPLOYED_HOME}"
if [[ "$DO_BACKUP" == true && -d "$BACKUP_DIR" ]]; then
    echo -e "    Backup saved at          : ${BACKUP_DIR}"
fi
