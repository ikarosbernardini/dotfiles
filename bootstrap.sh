#!/bin/bash
# =============================================================================
# Bootstrap Script for Fedora Sway Atomic Dotfiles
# Author: Ikaros
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export DOTFILES_DIR

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# =============================================================================
# Helper Functions
# =============================================================================

print_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
    ____        __  _____ __
   / __ \____  / /_/ __(_) /__  _____
  / / / / __ \/ __/ /_/ / / _ \/ ___/
 / /_/ / /_/ / /_/ __/ / /  __(__  )
/_____/\____/\__/_/ /_/_/\___/____/

   Fedora Sway Atomic Setup
EOF
    echo -e "${NC}"
}

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step() { echo -e "\n${PURPLE}${BOLD}==> $1${NC}\n"; }

confirm() {
    local prompt="${1:-Continue?}"
    read -p "$prompt (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# =============================================================================
# System Checks
# =============================================================================

check_system() {
    step "Checking System Requirements"

    # Check if running on Fedora
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [[ "$ID" == "fedora" ]]; then
            info "Detected: $PRETTY_NAME"
        else
            warning "This script is designed for Fedora. Detected: $ID"
            if ! confirm "Continue anyway?"; then
                exit 1
            fi
        fi
    else
        error "Cannot determine OS. /etc/os-release not found."
        exit 1
    fi

    # Check for rpm-ostree (atomic variant)
    if command -v rpm-ostree &>/dev/null; then
        info "Fedora Atomic variant detected (rpm-ostree available)"
    else
        warning "rpm-ostree not found. This may not be a Fedora Atomic system."
        warning "Package installation script may not work as expected."
    fi

    # Check for Sway
    if command -v sway &>/dev/null; then
        info "Sway window manager found"
    else
        warning "Sway is not installed or not in PATH"
    fi

    # Check for required tools
    local required_tools=("git" "curl" "wget")
    local missing_tools=()

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -ne 0 ]; then
        error "Missing required tools: ${missing_tools[*]}"
        error "Please install them first."
        exit 1
    fi

    success "System checks passed!"
}

# =============================================================================
# Backup Function
# =============================================================================

create_backup() {
    step "Creating Backup of Existing Configurations"

    local backup_dir="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
    local files_to_backup=(
        "$HOME/.bashrc"
        "$HOME/.tmux.conf"
        "$HOME/.config/sway"
        "$HOME/.config/waybar"
        "$HOME/.config/foot"
        "$HOME/.config/nvim"
        "$HOME/.config/rofi"
    )

    local backed_up=false

    for file in "${files_to_backup[@]}"; do
        if [ -e "$file" ] && [ ! -L "$file" ]; then
            if [ "$backed_up" = false ]; then
                mkdir -p "$backup_dir"
                backed_up=true
            fi
            info "Backing up: $file"
            cp -r "$file" "$backup_dir/" 2>/dev/null || true
        fi
    done

    if [ "$backed_up" = true ]; then
        success "Backups saved to: $backup_dir"
    else
        info "No existing configs to backup."
    fi
}

# =============================================================================
# Installation Steps
# =============================================================================

install_packages() {
    step "Package Installation"

    info "This step will install system packages via rpm-ostree and flatpak."
    warning "System packages require a reboot after installation."

    if confirm "Run package installation script?"; then
        bash "$DOTFILES_DIR/scripts/install_packages.sh"
    else
        info "Skipping package installation."
    fi
}

setup_bash() {
    step "Bash Shell Configuration"

    if confirm "Setup Bash configuration?"; then
        bash "$DOTFILES_DIR/scripts/setup_bash.sh"
    else
        info "Skipping Bash setup."
    fi
}

setup_nvim() {
    step "Neovim Configuration"

    if confirm "Setup Neovim with LazyVim configuration?"; then
        bash "$DOTFILES_DIR/scripts/setup_nvim.sh"
    else
        info "Skipping Neovim setup."
    fi
}

link_configs() {
    step "Linking Configuration Files"

    if confirm "Create symlinks for all configurations?"; then
        # Run link script with 'all' option
        echo "1" | bash "$DOTFILES_DIR/scripts/link_configs.sh"
    else
        info "Running interactive config linker..."
        bash "$DOTFILES_DIR/scripts/link_configs.sh"
    fi
}

setup_tmux() {
    step "Tmux Configuration"

    if [ -f "$HOME/.tmux.conf" ] || [ -L "$HOME/.tmux.conf" ]; then
        info "Tmux config already linked."
    fi

    # Install TPM (Tmux Plugin Manager)
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        info "Installing Tmux Plugin Manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        success "TPM installed. Press prefix + I in tmux to install plugins."
    else
        info "TPM already installed."
    fi
}

optimize_battery() {
    step "Battery Optimization (Optional)"

    info "This step configures power management for laptops (especially MacBooks)."

    if confirm "Run battery optimization script?"; then
        bash "$DOTFILES_DIR/scripts/optimize_battery.sh"
    else
        info "Skipping battery optimization."
    fi
}

setup_fonts() {
    step "Font Configuration"

    info "Checking for required fonts..."

    # Check if JetBrains Mono is installed
    if fc-list | grep -qi "JetBrains"; then
        success "JetBrains Mono font found."
    else
        warning "JetBrains Mono font not found."
        info "It should be installed via rpm-ostree (jetbrains-mono-fonts-all)"
    fi

    # Check for Nerd Fonts symbols
    if fc-list | grep -qi "Nerd"; then
        success "Nerd Font symbols found."
    else
        warning "Nerd Font symbols not found."
        info "Installing JetBrains Mono Nerd Font..."

        mkdir -p ~/.local/share/fonts

        # Download JetBrains Mono Nerd Font
        local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

        if curl -fLo /tmp/JetBrainsMono.zip "$font_url"; then
            unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono/
            rm /tmp/JetBrainsMono.zip
            fc-cache -fv
            success "JetBrains Mono Nerd Font installed!"
        else
            warning "Failed to download font. Please install manually."
        fi
    fi
}

create_directories() {
    step "Creating Directory Structure"

    local dirs=(
        "$HOME/.local/bin"
        "$HOME/.local/share"
        "$HOME/.config"
        "$HOME/.cache"
        "$HOME/Projects"
        "$HOME/Pictures/Screenshots"
        "$HOME/Pictures/Wallpapers"
        "$HOME/Downloads"
        "$HOME/Documents"
    )

    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            info "Created: $dir"
        fi
    done

    success "Directory structure ready."
}

# =============================================================================
# Post-Installation
# =============================================================================

print_summary() {
    step "Installation Summary"

    echo -e "${GREEN}${BOLD}Dotfiles installation complete!${NC}"
    echo
    echo "What was installed/configured:"
    echo "  - Sway window manager configuration"
    echo "  - Waybar status bar"
    echo "  - Foot terminal"
    echo "  - Bash with Starship prompt"
    echo "  - Neovim with LazyVim"
    echo "  - Tmux with TPM"
    echo "  - Rofi application launcher"
    echo

    echo -e "${YELLOW}${BOLD}Next Steps:${NC}"
    echo
    echo "1. If you installed system packages via rpm-ostree:"
    echo "   ${CYAN}systemctl reboot${NC}"
    echo
    echo "2. After reboot, reload Sway config:"
    echo "   ${CYAN}\$mod+Shift+c${NC} (Super+Shift+c)"
    echo
    echo "3. Install tmux plugins (in tmux):"
    echo "   ${CYAN}prefix + I${NC} (Ctrl+a, then I)"
    echo
    echo "4. Open Neovim and let plugins install:"
    echo "   ${CYAN}nvim${NC}"
    echo
    echo "5. Read the keybindings documentation:"
    echo "   ${CYAN}$DOTFILES_DIR/KEYBINDINGS.md${NC}"
    echo

    echo -e "${BLUE}${BOLD}Useful Commands:${NC}"
    echo "  - Reload bash: ${CYAN}source ~/.bashrc${NC}"
    echo "  - Update packages: ${CYAN}system-update${NC}"
    echo "  - Power mode: ${CYAN}power-mode {performance|powersave|balanced}${NC}"
    echo "  - Brightness: ${CYAN}light -A 5${NC} / ${CYAN}light -U 5${NC}"
    echo

    echo -e "${GREEN}Enjoy your new setup!${NC}"
}

# =============================================================================
# Main
# =============================================================================

main() {
    print_banner

    echo "This script will set up your Fedora Sway Atomic environment."
    echo "Dotfiles location: $DOTFILES_DIR"
    echo

    if ! confirm "Start installation?"; then
        echo "Installation cancelled."
        exit 0
    fi

    # Run installation steps
    check_system
    create_backup
    create_directories
    setup_fonts

    echo
    echo "Installation options:"
    echo "  1) Full installation (recommended for fresh systems)"
    echo "  2) Minimal installation (configs only, no packages)"
    echo "  3) Custom installation (choose each step)"
    echo

    read -p "Select option [1-3]: " install_option

    case $install_option in
        1)
            # Full installation
            install_packages
            link_configs
            setup_bash
            setup_nvim
            setup_tmux
            optimize_battery
            ;;
        2)
            # Minimal installation
            link_configs
            setup_bash
            setup_tmux
            ;;
        3)
            # Custom installation
            install_packages
            link_configs
            setup_bash
            setup_nvim
            setup_tmux
            optimize_battery
            ;;
        *)
            error "Invalid option."
            exit 1
            ;;
    esac

    print_summary
}

# Run main function
main "$@"
