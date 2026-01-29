#!/bin/bash
# =============================================================================
# Bash Setup Script
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

# =============================================================================
# Main Setup
# =============================================================================

setup_bash() {
    info "Setting up Bash configuration..."

    # Create backup of existing .bashrc if it exists and is not a symlink
    if [ -f "$HOME/.bashrc" ] && [ ! -L "$HOME/.bashrc" ]; then
        local backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        info "Backing up existing .bashrc to $backup_file"
        mv "$HOME/.bashrc" "$backup_file"
    fi

    # Remove existing symlink if present
    if [ -L "$HOME/.bashrc" ]; then
        rm "$HOME/.bashrc"
    fi

    # Create symlink
    ln -sf "$DOTFILES_DIR/configs/bash/.bashrc" "$HOME/.bashrc"
    success "Created symlink: ~/.bashrc -> $DOTFILES_DIR/configs/bash/.bashrc"
}

setup_starship() {
    info "Setting up Starship prompt..."

    # Check if starship is installed
    if ! command -v starship &>/dev/null; then
        warning "Starship is not installed."
        read -p "Install Starship now? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            info "Installing Starship..."
            curl -sS https://starship.rs/install.sh | sh -s -- -y
        else
            warning "Skipping Starship installation. Using fallback prompt."
            return 0
        fi
    fi

    # Create config directory if it doesn't exist
    mkdir -p "$HOME/.config"

    # The starship config is created by .bashrc on first run
    # But we can create it now if needed
    if [ ! -f "$HOME/.config/starship.toml" ]; then
        info "Starship config will be created on first shell startup."
    else
        info "Starship config already exists at ~/.config/starship.toml"
    fi

    success "Starship setup complete!"
}

setup_fzf() {
    info "Setting up FZF..."

    # Check if fzf is installed
    if ! command -v fzf &>/dev/null; then
        warning "FZF is not installed."
        read -p "Install FZF now? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            info "Installing FZF..."
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install --all --no-update-rc
        else
            warning "Skipping FZF installation."
            return 0
        fi
    else
        success "FZF is already installed."
    fi
}

setup_fd() {
    info "Setting up fd (find alternative)..."

    # fd might be installed as 'fd' or 'fd-find' or 'fdfind'
    if command -v fd &>/dev/null; then
        success "fd is already installed."
    elif command -v fdfind &>/dev/null; then
        # Create alias symlink
        mkdir -p ~/.local/bin
        ln -sf "$(which fdfind)" ~/.local/bin/fd
        success "Created fd symlink from fdfind."
    else
        warning "fd is not installed. Install it via rpm-ostree or the package manager."
    fi
}

setup_bat() {
    info "Setting up bat (cat alternative)..."

    if command -v bat &>/dev/null; then
        success "bat is already installed."
        # Create bat config directory
        mkdir -p "$HOME/.config/bat"
        # Set up bat config
        cat > "$HOME/.config/bat/config" << 'EOF'
--theme="TwoDark"
--style="numbers,changes,header"
--italic-text=always
--map-syntax "*.conf:INI"
--map-syntax ".bashrc:Bash"
--map-syntax ".bash_profile:Bash"
--map-syntax ".bash_aliases:Bash"
EOF
        success "bat configuration created."
    elif command -v batcat &>/dev/null; then
        # On some systems bat is installed as batcat
        mkdir -p ~/.local/bin
        ln -sf "$(which batcat)" ~/.local/bin/bat
        success "Created bat symlink from batcat."
    else
        warning "bat is not installed. Install it for better syntax highlighting."
    fi
}

create_local_bashrc() {
    info "Creating local bashrc template..."

    if [ ! -f "$HOME/.bashrc.local" ]; then
        cat > "$HOME/.bashrc.local" << 'EOF'
# =============================================================================
# Local Bash Configuration
# Add your machine-specific configurations here
# =============================================================================

# Example: Add custom PATH
# export PATH="$HOME/custom/path:$PATH"

# Example: Set custom environment variables
# export MY_VAR="value"

# Example: Custom aliases
# alias myalias='my command'

# Example: Source work-specific configs
# [ -f "$HOME/.bashrc.work" ] && source "$HOME/.bashrc.work"
EOF
        success "Created ~/.bashrc.local template"
    else
        info "~/.bashrc.local already exists, skipping."
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    echo "=========================================="
    echo " Bash Setup Script"
    echo "=========================================="
    echo

    setup_bash
    setup_starship
    setup_fzf
    setup_fd
    setup_bat
    create_local_bashrc

    echo
    success "Bash setup complete!"
    info "Run 'source ~/.bashrc' or restart your terminal to apply changes."
}

main "$@"
