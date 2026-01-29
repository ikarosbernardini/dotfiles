#!/bin/bash
# =============================================================================
# Neovim Setup Script
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
# Check Prerequisites
# =============================================================================

check_prerequisites() {
    info "Checking prerequisites..."

    # Check if Neovim is installed
    if ! command -v nvim &>/dev/null; then
        error "Neovim is not installed. Please install it first."
        error "On Fedora Atomic: sudo rpm-ostree install neovim"
        exit 1
    fi

    local nvim_version
    nvim_version=$(nvim --version | head -n1 | grep -oP '\d+\.\d+\.\d+')
    info "Neovim version: $nvim_version"

    # Check for minimum version (0.9.0+)
    local major minor
    major=$(echo "$nvim_version" | cut -d. -f1)
    minor=$(echo "$nvim_version" | cut -d. -f2)

    if [ "$major" -lt 0 ] || { [ "$major" -eq 0 ] && [ "$minor" -lt 9 ]; }; then
        error "Neovim 0.9.0 or higher is required. Found: $nvim_version"
        exit 1
    fi

    # Check for git
    if ! command -v git &>/dev/null; then
        error "Git is not installed. Please install it first."
        exit 1
    fi

    # Check for Node.js (required for some LSP servers)
    if ! command -v node &>/dev/null; then
        warning "Node.js is not installed. Some LSP features may not work."
        warning "Consider installing Node.js via nvm."
    fi

    # Check for ripgrep (for Telescope live_grep)
    if ! command -v rg &>/dev/null; then
        warning "ripgrep (rg) is not installed. Telescope live_grep may not work."
    fi

    # Check for fd (for Telescope find_files)
    if ! command -v fd &>/dev/null && ! command -v fdfind &>/dev/null; then
        warning "fd is not installed. Telescope find_files may be slower."
    fi

    success "Prerequisites check complete."
}

# =============================================================================
# Backup Existing Config
# =============================================================================

backup_existing_config() {
    info "Checking for existing Neovim configuration..."

    local nvim_config_dir="$HOME/.config/nvim"
    local nvim_data_dir="$HOME/.local/share/nvim"
    local nvim_cache_dir="$HOME/.cache/nvim"

    # Backup existing config
    if [ -d "$nvim_config_dir" ] && [ ! -L "$nvim_config_dir" ]; then
        local backup_dir="$nvim_config_dir.backup.$(date +%Y%m%d_%H%M%S)"
        info "Backing up existing config to $backup_dir"
        mv "$nvim_config_dir" "$backup_dir"
    fi

    # Clean up data directory for fresh start (optional)
    read -p "Clean up Neovim data directory for fresh plugin installation? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -d "$nvim_data_dir" ]; then
            info "Removing $nvim_data_dir"
            rm -rf "$nvim_data_dir"
        fi
        if [ -d "$nvim_cache_dir" ]; then
            info "Removing $nvim_cache_dir"
            rm -rf "$nvim_cache_dir"
        fi
    fi

    success "Backup complete."
}

# =============================================================================
# Setup Config
# =============================================================================

setup_config() {
    info "Setting up Neovim configuration..."

    local nvim_config_dir="$HOME/.config/nvim"

    # Remove existing symlink if present
    if [ -L "$nvim_config_dir" ]; then
        rm "$nvim_config_dir"
    fi

    # Create config directory
    mkdir -p "$HOME/.config"

    # Create symlink to nvim config directory
    # Note: We link the entire nvim directory, not just init.lua
    mkdir -p "$nvim_config_dir"
    ln -sf "$DOTFILES_DIR/configs/nvim/init.lua" "$nvim_config_dir/init.lua"

    success "Created symlink: ~/.config/nvim/init.lua -> $DOTFILES_DIR/configs/nvim/init.lua"
}

# =============================================================================
# Install Plugins
# =============================================================================

install_plugins() {
    info "Installing Neovim plugins..."

    # Run Neovim headlessly to trigger lazy.nvim plugin installation
    info "This may take a few minutes on first run..."

    nvim --headless "+Lazy! sync" +qa 2>&1 || true

    success "Plugin installation complete!"
}

# =============================================================================
# Install LSP Servers
# =============================================================================

install_lsp_servers() {
    info "Installing LSP servers via Mason..."

    # Run Mason install for specified servers
    local servers=(
        "lua-language-server"
        "pyright"
        "typescript-language-server"
        "bash-language-server"
        "yaml-language-server"
        "dockerfile-language-server"
        "docker-compose-language-service"
        "json-lsp"
        "html-lsp"
        "css-lsp"
    )

    info "The following LSP servers will be installed:"
    for server in "${servers[@]}"; do
        echo "  - $server"
    done

    read -p "Continue with LSP server installation? (Y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        warning "Skipping LSP server installation. You can install them later with :MasonInstall"
        return 0
    fi

    # Install servers via Mason
    for server in "${servers[@]}"; do
        info "Installing $server..."
        nvim --headless "+MasonInstall $server" +qa 2>&1 || warning "Failed to install $server"
    done

    success "LSP server installation complete!"
}

# =============================================================================
# Install Lazygit
# =============================================================================

install_lazygit() {
    info "Checking for lazygit..."

    if command -v lazygit &>/dev/null; then
        success "lazygit is already installed."
        return 0
    fi

    read -p "Install lazygit for git integration? (Y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        warning "Skipping lazygit installation."
        return 0
    fi

    info "Installing lazygit..."

    # Try to install via package manager first
    if command -v dnf &>/dev/null; then
        # Add COPR repo for lazygit
        sudo dnf copr enable atim/lazygit -y 2>/dev/null || true
        sudo dnf install lazygit -y 2>/dev/null || {
            # Fallback to binary installation
            install_lazygit_binary
        }
    else
        install_lazygit_binary
    fi
}

install_lazygit_binary() {
    info "Installing lazygit from GitHub releases..."

    local version
    version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

    if [ -z "$version" ]; then
        error "Could not determine latest lazygit version."
        return 1
    fi

    local url="https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_x86_64.tar.gz"

    curl -Lo /tmp/lazygit.tar.gz "$url"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    mkdir -p ~/.local/bin
    mv /tmp/lazygit ~/.local/bin/
    rm /tmp/lazygit.tar.gz

    success "lazygit installed to ~/.local/bin/lazygit"
}

# =============================================================================
# Verify Installation
# =============================================================================

verify_installation() {
    info "Verifying installation..."

    echo
    echo "Testing Neovim configuration..."

    # Check if Neovim starts without errors
    if nvim --headless -c "echo 'OK'" -c "qa" 2>&1 | grep -q "Error"; then
        error "Neovim configuration has errors."
        return 1
    fi

    success "Neovim configuration loaded successfully!"

    echo
    echo "Installed components:"
    echo "  - Neovim: $(nvim --version | head -n1)"
    [ -f ~/.config/nvim/init.lua ] && echo "  - Config: ~/.config/nvim/init.lua"
    [ -d ~/.local/share/nvim/lazy ] && echo "  - Plugins: $(ls ~/.local/share/nvim/lazy 2>/dev/null | wc -l) plugins installed"
    command -v lazygit &>/dev/null && echo "  - lazygit: $(lazygit --version)"
}

# =============================================================================
# Main
# =============================================================================

main() {
    echo "=========================================="
    echo " Neovim Setup Script"
    echo "=========================================="
    echo

    check_prerequisites
    backup_existing_config
    setup_config
    install_plugins
    install_lsp_servers
    install_lazygit
    verify_installation

    echo
    success "Neovim setup complete!"
    echo
    info "Quick start guide:"
    echo "  - Open Neovim: nvim"
    echo "  - Open file explorer: <Space>e"
    echo "  - Find files: <Space>ff"
    echo "  - Live grep: <Space>fg"
    echo "  - Open lazygit: <Space>gg"
    echo "  - View keybindings: <Space> (wait for which-key)"
    echo
    info "Run ':checkhealth' in Neovim to verify your setup."
}

main "$@"
