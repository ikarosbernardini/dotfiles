#!/bin/bash
# =============================================================================
# Configuration Symlink Script
# Author: Ikaros
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

# =============================================================================
# Backup and Link Functions
# =============================================================================

backup_if_exists() {
    local target="$1"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        local backup_path="$BACKUP_DIR/$(basename "$target")"
        info "Backing up $target to $backup_path"
        mv "$target" "$backup_path"
        return 0
    elif [ -L "$target" ]; then
        info "Removing existing symlink: $target"
        rm "$target"
        return 0
    fi
    return 0
}

create_symlink() {
    local source="$1"
    local target="$2"

    # Check if source exists
    if [ ! -e "$source" ]; then
        warning "Source does not exist: $source"
        return 1
    fi

    # Create parent directory if needed
    local target_dir
    target_dir=$(dirname "$target")
    mkdir -p "$target_dir"

    # Backup existing file/directory
    backup_if_exists "$target"

    # Create symlink
    ln -sf "$source" "$target"
    success "Linked: $target -> $source"
}

# =============================================================================
# Link Configurations
# =============================================================================

link_sway() {
    info "Linking Sway configuration..."
    create_symlink "$DOTFILES_DIR/configs/sway/config" "$HOME/.config/sway/config"
}

link_waybar() {
    info "Linking Waybar configuration..."
    create_symlink "$DOTFILES_DIR/configs/waybar/config" "$HOME/.config/waybar/config"
    create_symlink "$DOTFILES_DIR/configs/waybar/style.css" "$HOME/.config/waybar/style.css"
}

link_foot() {
    info "Linking Foot terminal configuration..."
    create_symlink "$DOTFILES_DIR/configs/foot/foot.ini" "$HOME/.config/foot/foot.ini"
}

link_bash() {
    info "Linking Bash configuration..."
    create_symlink "$DOTFILES_DIR/configs/bash/.bashrc" "$HOME/.bashrc"
}

link_nvim() {
    info "Linking Neovim configuration..."
    create_symlink "$DOTFILES_DIR/configs/nvim/init.lua" "$HOME/.config/nvim/init.lua"
}

link_tmux() {
    info "Linking Tmux configuration..."
    create_symlink "$DOTFILES_DIR/configs/tmux/.tmux.conf" "$HOME/.tmux.conf"
}

link_rofi() {
    info "Linking Rofi configuration..."
    create_symlink "$DOTFILES_DIR/configs/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
}

link_git() {
    info "Setting up Git configuration..."

    local git_config="$HOME/.gitconfig"

    # Check if gitconfig exists
    if [ -f "$git_config" ]; then
        info "Git config already exists at $git_config"
        read -p "Overwrite with template? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
        backup_if_exists "$git_config"
    fi

    # Create git config
    cat > "$git_config" << EOF
[user]
    name = Ikaros
    email = ikaros.bernardini@gmail.com

[init]
    defaultBranch = main

[core]
    editor = nvim
    autocrlf = input
    whitespace = fix,-indent-with-non-tab,trailing-space,cr-at-eol
    pager = less -FRX

[color]
    ui = auto

[pull]
    rebase = true

[push]
    default = current
    autoSetupRemote = true

[fetch]
    prune = true

[diff]
    tool = nvim

[difftool "nvim"]
    cmd = nvim -d \$LOCAL \$REMOTE

[merge]
    tool = nvim
    conflictstyle = diff3

[mergetool "nvim"]
    cmd = nvim -d \$LOCAL \$MERGED \$REMOTE

[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    lg = log --graph --oneline --decorate --all
    last = log -1 HEAD
    unstage = reset HEAD --
    amend = commit --amend --no-edit
    undo = reset --soft HEAD~1

[credential]
    helper = store

[rerere]
    enabled = true
EOF

    success "Created Git configuration at $git_config"
}

# =============================================================================
# Create Additional Directories
# =============================================================================

create_directories() {
    info "Creating additional directories..."

    local dirs=(
        "$HOME/.local/bin"
        "$HOME/.local/share"
        "$HOME/.config"
        "$HOME/.cache"
        "$HOME/Projects"
        "$HOME/Pictures/Screenshots"
        "$HOME/Downloads"
        "$HOME/Documents"
    )

    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            success "Created directory: $dir"
        fi
    done
}

# =============================================================================
# Main
# =============================================================================

main() {
    echo "=========================================="
    echo " Configuration Symlink Script"
    echo "=========================================="
    echo

    # Check if dotfiles directory exists
    if [ ! -d "$DOTFILES_DIR" ]; then
        error "Dotfiles directory not found: $DOTFILES_DIR"
        exit 1
    fi

    info "Dotfiles directory: $DOTFILES_DIR"
    echo

    # Create directories first
    create_directories

    echo
    echo "Select configurations to link:"
    echo "  1) All configurations"
    echo "  2) Sway only"
    echo "  3) Waybar only"
    echo "  4) Foot terminal only"
    echo "  5) Bash only"
    echo "  6) Neovim only"
    echo "  7) Tmux only"
    echo "  8) Rofi only"
    echo "  9) Git only"
    echo "  q) Quit"
    echo

    read -p "Enter your choice [1-9/q]: " choice

    case $choice in
        1)
            link_sway
            link_waybar
            link_foot
            link_bash
            link_nvim
            link_tmux
            link_rofi
            link_git
            ;;
        2) link_sway ;;
        3) link_waybar ;;
        4) link_foot ;;
        5) link_bash ;;
        6) link_nvim ;;
        7) link_tmux ;;
        8) link_rofi ;;
        9) link_git ;;
        q|Q) exit 0 ;;
        *)
            error "Invalid choice."
            exit 1
            ;;
    esac

    echo
    if [ -d "$BACKUP_DIR" ]; then
        info "Backups saved to: $BACKUP_DIR"
    fi

    success "Configuration linking complete!"

    echo
    warning "Remember to:"
    echo "  - Reload Sway: \$mod+Shift+c"
    echo "  - Source bash: source ~/.bashrc"
    echo "  - Reload tmux: tmux source-file ~/.tmux.conf"
}

main "$@"
