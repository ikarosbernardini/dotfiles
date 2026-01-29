# Dotfiles for Fedora Sway Atomic

Personal dotfiles managed by [chezmoi](https://www.chezmoi.io/) for a DevOps-focused development environment.

## Quick Install (New Machine)

```bash
# One command to install everything:
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ikarosbernardini
```

Or if chezmoi is already installed:
```bash
chezmoi init --apply ikarosbernardini
```

## What's Included

| Component | Description |
|-----------|-------------|
| **Sway** | Tiling Wayland compositor with vim-style navigation |
| **Waybar** | Status bar with Tokyo Night theme |
| **Foot** | Fast, lightweight terminal |
| **Bash** | Shell with Starship prompt |
| **Neovim** | LazyVim configuration with LSP |
| **Tmux** | Terminal multiplexer with vim bindings |
| **Rofi** | Application launcher |

## Repository Structure

```
dotfiles/
├── .chezmoi.toml.tmpl          # Chezmoi config template
├── .chezmoiignore              # Files to ignore
├── dot_bashrc                  # → ~/.bashrc
├── dot_tmux.conf               # → ~/.tmux.conf
├── dot_config/
│   ├── sway/config             # → ~/.config/sway/config
│   ├── waybar/                 # → ~/.config/waybar/
│   ├── foot/foot.ini           # → ~/.config/foot/foot.ini
│   ├── nvim/init.lua           # → ~/.config/nvim/init.lua
│   ├── rofi/config.rasi        # → ~/.config/rofi/config.rasi
│   └── starship/starship.toml  # → ~/.config/starship/starship.toml
├── run_once_before_*           # Pre-apply scripts (packages)
├── run_once_after_*            # Post-apply scripts (plugins)
├── README.md
└── KEYBINDINGS.md
```

## Usage

### First Time Setup

```bash
# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ikarosbernardini

# After reboot (if rpm-ostree packages were installed)
chezmoi apply
```

### Common Commands

```bash
# Check what would change
chezmoi diff

# Apply changes
chezmoi apply

# Edit a config file
chezmoi edit ~/.bashrc

# Add a new file to be managed
chezmoi add ~/.config/some-app/config

# Update from remote repository
chezmoi update

# Check status
chezmoi status
```

### Pull Latest Changes

```bash
chezmoi update
```

### Edit Configuration

```bash
# Edit in chezmoi source directory
chezmoi edit ~/.bashrc

# Or edit directly and re-add
vim ~/.bashrc
chezmoi add ~/.bashrc
```

## Customization

### During Installation

When you run `chezmoi init`, you'll be prompted for:
- Your name
- Your email
- Whether to install system packages
- Whether to install Flatpak apps

### Local Overrides

Create `~/.bashrc.local` for machine-specific bash configuration:

```bash
# ~/.bashrc.local
export KUBECONFIG=~/.kube/work-config
alias work='cd ~/work/projects'
```

### Reconfigure

```bash
chezmoi init
```

## Keybindings

See [KEYBINDINGS.md](KEYBINDINGS.md) for all keyboard shortcuts.

### Quick Reference

| App | Key | Action |
|-----|-----|--------|
| Sway | `Super + Return` | Terminal |
| Sway | `Super + d` | App launcher |
| Sway | `Super + hjkl` | Navigate windows |
| Sway | `Super + 1-9` | Switch workspace |
| Tmux | `Ctrl+a \|` | Split horizontal |
| Tmux | `Ctrl+a -` | Split vertical |
| Nvim | `Space + ff` | Find file |
| Nvim | `Space + e` | File explorer |

## Troubleshooting

### Packages Not Installing

The `run_once_before` script only runs once. To re-run:

```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

### Font Issues

```bash
# Re-install Nerd Font manually
mkdir -p ~/.local/share/fonts
curl -fLo /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono/
fc-cache -fv
```

### Neovim Plugins

```bash
# Open neovim and sync plugins
nvim
:Lazy sync
:checkhealth
```

### Tmux Plugins

```bash
# In tmux, press:
# prefix + I (Ctrl+a, then I)
```

## System Requirements

- **OS**: Fedora Sway Atomic (or Fedora with Sway)
- **Shell**: Bash
- **Tools**: git, curl

## Contributing

Feel free to fork and customize. Issues and PRs welcome.

## Author

**Ikaros**
- GitHub: [@ikarosbernardini](https://github.com/ikarosbernardini)
