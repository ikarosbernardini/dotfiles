#!/bin/bash
# =============================================================================
# Package Installation Script for Fedora Sway Atomic
# Author: Ikaros
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running on Fedora Atomic
check_fedora_atomic() {
    if ! command -v rpm-ostree &>/dev/null; then
        error "This script is designed for Fedora Atomic (rpm-ostree based) systems."
        error "rpm-ostree command not found."
        exit 1
    fi

    if [ ! -f /etc/os-release ]; then
        error "Cannot determine OS version."
        exit 1
    fi

    source /etc/os-release
    if [[ "$ID" != "fedora" ]]; then
        error "This script is designed for Fedora. Detected: $ID"
        exit 1
    fi

    info "Running on $PRETTY_NAME"
}

# =============================================================================
# RPM-OSTREE Package Installation
# =============================================================================

install_system_packages() {
    info "Installing system packages via rpm-ostree..."

    # Core packages to layer
    local packages=(
        # Shell and terminal
        "tmux"
        "neovim"

        # Development tools
        "git"
        "curl"
        "wget"
        "ripgrep"
        "fd-find"
        "fzf"
        "jq"
        "yq"
        "htop"
        "btop"

        # Sway/Wayland utilities
        "light"
        "grim"
        "slurp"
        "wl-clipboard"
        "cliphist"
        "playerctl"
        "pamixer"

        # Power management
        "tlp"
        "tlp-rdw"
        "powertop"

        # Networking
        "NetworkManager-tui"

        # Fonts
        "jetbrains-mono-fonts-all"
        "fontawesome-fonts-all"
        "google-noto-emoji-fonts"

        # System utilities
        "fastfetch"
        "lm_sensors"
        "acpi"

        # Starship prompt
        "starship"
    )

    # Check which packages are already installed
    local to_install=()
    for pkg in "${packages[@]}"; do
        if ! rpm -q "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        else
            info "Package already installed: $pkg"
        fi
    done

    if [ ${#to_install[@]} -eq 0 ]; then
        success "All system packages are already installed!"
        return 0
    fi

    info "Packages to install: ${to_install[*]}"
    warning "This will layer packages onto your system and require a reboot."

    read -p "Continue with installation? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        warning "Skipping system package installation."
        return 0
    fi

    # Install packages
    if sudo rpm-ostree install --idempotent "${to_install[@]}"; then
        success "System packages queued for installation."
        warning "A reboot is required to apply changes: systemctl reboot"
    else
        error "Failed to install some packages."
        return 1
    fi
}

# =============================================================================
# Flatpak Installation
# =============================================================================

install_flatpaks() {
    info "Setting up Flatpak..."

    # Ensure Flathub is added
    if ! flatpak remote-list | grep -q "flathub"; then
        info "Adding Flathub repository..."
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    fi

    # Core flatpaks
    local flatpaks=(
        # Productivity
        "org.libreoffice.LibreOffice"

        # Communication
        "com.discordapp.Discord"

        # Media
        "com.spotify.Client"

        # Development
        "com.vscodium.codium"

        # Utilities
        "org.gnome.Calculator"
        "org.gnome.FileRoller"
        "com.github.tchx84.Flatseal"

        # Graphics
        "org.gimp.GIMP"
    )

    info "The following Flatpak applications are available for installation:"
    for i in "${!flatpaks[@]}"; do
        echo "  $((i+1)). ${flatpaks[$i]}"
    done

    read -p "Install all Flatpak applications? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        read -p "Install core Flatpaks only (LibreOffice, Calculator, FileRoller)? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            flatpaks=(
                "org.libreoffice.LibreOffice"
                "org.gnome.Calculator"
                "org.gnome.FileRoller"
                "com.github.tchx84.Flatseal"
            )
        else
            warning "Skipping Flatpak installation."
            return 0
        fi
    fi

    for app in "${flatpaks[@]}"; do
        if flatpak list | grep -q "$app"; then
            info "Already installed: $app"
        else
            info "Installing: $app"
            if flatpak install -y flathub "$app"; then
                success "Installed: $app"
            else
                warning "Failed to install: $app"
            fi
        fi
    done

    success "Flatpak installation complete!"
}

# =============================================================================
# Development Tools Installation
# =============================================================================

install_dev_tools() {
    info "Installing development tools..."

    # Docker (Podman is pre-installed on Fedora Atomic)
    info "Podman is pre-installed. Configuring aliases..."

    # Python tools (using pip with --user)
    if command -v pip3 &>/dev/null; then
        info "Installing Python development tools..."
        pip3 install --user --upgrade pip
        pip3 install --user \
            pipx \
            black \
            flake8 \
            mypy \
            pylint \
            pytest \
            poetry
    fi

    # Node.js via nvm (optional)
    read -p "Install Node.js via nvm? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ ! -d "$HOME/.nvm" ]; then
            info "Installing nvm..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            nvm install --lts
            nvm use --lts
        else
            info "nvm already installed."
        fi
    fi

    # Rust via rustup (optional)
    read -p "Install Rust via rustup? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if ! command -v rustc &>/dev/null; then
            info "Installing Rust..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
        else
            info "Rust already installed."
        fi
    fi

    # Go (optional)
    read -p "Install Go? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if ! command -v go &>/dev/null; then
            info "Installing Go..."
            local go_version="1.22.0"
            wget "https://go.dev/dl/go${go_version}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
            sudo rm -rf /usr/local/go
            sudo tar -C /usr/local -xzf /tmp/go.tar.gz
            rm /tmp/go.tar.gz
            export PATH=$PATH:/usr/local/go/bin
        else
            info "Go already installed."
        fi
    fi

    success "Development tools installation complete!"
}

# =============================================================================
# Kubernetes Tools
# =============================================================================

install_k8s_tools() {
    info "Installing Kubernetes tools..."

    # kubectl
    if ! command -v kubectl &>/dev/null; then
        info "Installing kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        mkdir -p ~/.local/bin
        mv kubectl ~/.local/bin/
    else
        info "kubectl already installed."
    fi

    # k9s
    if ! command -v k9s &>/dev/null; then
        info "Installing k9s..."
        curl -sS https://webi.sh/k9s | sh
    else
        info "k9s already installed."
    fi

    # helm
    if ! command -v helm &>/dev/null; then
        info "Installing Helm..."
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    else
        info "Helm already installed."
    fi

    # kubectx and kubens
    if ! command -v kubectx &>/dev/null; then
        info "Installing kubectx and kubens..."
        mkdir -p ~/.local/bin
        curl -L https://github.com/ahmetb/kubectx/releases/latest/download/kubectx -o ~/.local/bin/kubectx
        curl -L https://github.com/ahmetb/kubectx/releases/latest/download/kubens -o ~/.local/bin/kubens
        chmod +x ~/.local/bin/kubectx ~/.local/bin/kubens
    else
        info "kubectx already installed."
    fi

    success "Kubernetes tools installation complete!"
}

# =============================================================================
# Main
# =============================================================================

main() {
    echo "=========================================="
    echo " Fedora Sway Atomic Package Installer"
    echo "=========================================="
    echo

    check_fedora_atomic

    echo
    echo "Select what to install:"
    echo "  1) System packages (rpm-ostree)"
    echo "  2) Flatpak applications"
    echo "  3) Development tools"
    echo "  4) Kubernetes tools"
    echo "  5) All of the above"
    echo "  q) Quit"
    echo

    read -p "Enter your choice [1-5/q]: " choice

    case $choice in
        1) install_system_packages ;;
        2) install_flatpaks ;;
        3) install_dev_tools ;;
        4) install_k8s_tools ;;
        5)
            install_system_packages
            install_flatpaks
            install_dev_tools
            install_k8s_tools
            ;;
        q|Q) exit 0 ;;
        *)
            error "Invalid choice."
            exit 1
            ;;
    esac

    echo
    success "Installation script completed!"
    warning "Remember to reboot if you installed system packages via rpm-ostree."
}

main "$@"
