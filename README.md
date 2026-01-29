# Dotfiles for Fedora Sway Atomic

Personal dotfiles for a DevOps-focused development environment on Fedora Sway Atomic.

## Overview

This repository contains configuration files for:

- **Sway** - Tiling Wayland compositor with vim-style navigation
- **Waybar** - Highly customizable status bar
- **Foot** - Fast, lightweight Wayland terminal
- **Bash** - Shell with Starship prompt
- **Neovim** - LazyVim-based configuration with LSP support
- **Tmux** - Terminal multiplexer with vim bindings
- **Rofi** - Application launcher

### Theme

All configurations use the **Tokyo Night** color scheme for a consistent look.

## Quick Start

### Fresh Installation

```bash
# Clone the repository
git clone https://github.com/ikarosbernardini/dotfiles.git ~/dotfiles

# Run the bootstrap script
cd ~/dotfiles
./bootstrap.sh
```

### Manual Installation

```bash
# 1. Install system packages (requires reboot)
./scripts/install_packages.sh

# 2. Link configuration files
./scripts/link_configs.sh

# 3. Setup Bash
./scripts/setup_bash.sh

# 4. Setup Neovim
./scripts/setup_nvim.sh

# 5. (Optional) Battery optimization for laptops
./scripts/optimize_battery.sh
```

## Repository Structure

```
dotfiles/
├── bootstrap.sh              # Main setup script
├── README.md                 # This file
├── KEYBINDINGS.md           # Keyboard shortcuts reference
├── .gitignore
├── configs/
│   ├── sway/
│   │   └── config           # Sway WM configuration
│   ├── waybar/
│   │   ├── config           # Waybar modules
│   │   └── style.css        # Waybar styling
│   ├── foot/
│   │   └── foot.ini         # Terminal configuration
│   ├── bash/
│   │   └── .bashrc          # Bash configuration
│   ├── nvim/
│   │   └── init.lua         # Neovim/LazyVim configuration
│   ├── tmux/
│   │   └── .tmux.conf       # Tmux configuration
│   └── rofi/
│       └── config.rasi      # Rofi theme
└── scripts/
    ├── install_packages.sh   # Package installation
    ├── setup_bash.sh         # Bash setup
    ├── setup_nvim.sh         # Neovim setup
    ├── link_configs.sh       # Symlink management
    └── optimize_battery.sh   # Battery optimization
```

## System Requirements

- **OS**: Fedora Sway Atomic (or any Fedora with Sway)
- **Shell**: Bash
- **Fonts**: JetBrains Mono Nerd Font (installed automatically)

### Pre-installed on Fedora Sway Atomic

- Sway
- Foot terminal
- Waybar
- Firefox
- Rofi
- Dunst
- Swaylock
- Thunar

## Key Features

### Sway

- Super (Windows) key as mod key
- Vim-style navigation (hjkl)
- 9 workspaces
- Screenshot support with grim/slurp
- Auto-start applications

### Neovim

- LazyVim-based configuration
- LSP support for: Python, TypeScript/JavaScript, Bash, YAML, Docker, Go, Rust
- File explorer (Neo-tree)
- Fuzzy finder (Telescope)
- Git integration (Gitsigns, LazyGit)
- Auto-completion with nvim-cmp

### Tmux

- Prefix: `Ctrl+a`
- Vim-style navigation
- Plugin manager (TPM)
- Session persistence with tmux-resurrect

### Bash

- Starship prompt with git status
- FZF integration for fuzzy finding
- Extensive aliases for git, docker, kubectl
- Auto-completion for common tools

## Package Management

### System Packages (rpm-ostree)

```bash
sudo rpm-ostree install <package>
# Requires reboot to apply
```

### Flatpak Applications

```bash
flatpak install flathub <app-id>
```

### User Applications

Prefer installing to `~/.local/bin` for user-specific tools.

## Customization

### Local Bash Configuration

Create `~/.bashrc.local` for machine-specific settings:

```bash
# Example: Work-specific settings
export KUBECONFIG=~/.kube/work-config
alias work-vpn='sudo openconnect vpn.work.com'
```

### Local Sway Configuration

Add custom configurations to `~/.config/sway/config.d/`:

```bash
# ~/.config/sway/config.d/local
output HDMI-A-1 pos 0 0 res 2560x1440
```

## Troubleshooting

### Sway won't start

1. Check for errors: `sway -d 2>&1 | head -100`
2. Verify config syntax: `sway -C`

### Waybar not showing

1. Kill existing instance: `pkill waybar`
2. Start manually: `waybar &`
3. Check errors: `waybar 2>&1 | head`

### Neovim plugins not loading

1. Open Neovim and run: `:Lazy sync`
2. Check health: `:checkhealth`

### Font issues (boxes/missing glyphs)

1. Install Nerd Fonts: Run `./bootstrap.sh` and select font installation
2. Or manually download from [Nerd Fonts](https://www.nerdfonts.com/)
3. Update font cache: `fc-cache -fv`

### Tmux plugins not working

1. Ensure TPM is installed: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
2. In tmux, press `prefix + I` to install plugins

## Updates

### Update dotfiles

```bash
cd ~/dotfiles
git pull
./scripts/link_configs.sh
```

### Update system

```bash
# System packages + flatpaks
system-update
# Reboot if rpm-ostree packages were updated
```

### Update Neovim plugins

Open Neovim and run `:Lazy update`

## Keybindings

See [KEYBINDINGS.md](KEYBINDINGS.md) for a complete list of keyboard shortcuts.

## Contributing

Feel free to fork and customize for your own use. If you find bugs or have improvements, issues and PRs are welcome.

## License

MIT License - Feel free to use and modify as needed.

## Author

**Ikaros**
- GitHub: [@ikarosbernardini](https://github.com/ikarosbernardini)
- Email: ikaros.bernardini@gmail.com
