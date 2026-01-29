# Keybindings Reference

Complete keyboard shortcuts reference for the Fedora Sway Atomic dotfiles setup.

## Table of Contents

- [Sway Window Manager](#sway-window-manager)
- [Tmux](#tmux)
- [Neovim](#neovim)
- [Rofi](#rofi)
- [Foot Terminal](#foot-terminal)

---

## Sway Window Manager

**Mod Key**: `Super` (Windows key)

### Basic Operations

| Keybinding | Action |
|------------|--------|
| `Mod + Return` | Open terminal (foot) |
| `Mod + d` | Open application launcher (rofi) |
| `Mod + Space` | Open application launcher (rofi) |
| `Mod + Shift + q` | Close focused window |
| `Mod + Shift + c` | Reload Sway configuration |
| `Mod + Shift + e` | Exit Sway (logout) |
| `Mod + Escape` | Lock screen |
| `Mod + e` | Open file manager (Thunar) |

### Window Navigation (Vim-style)

| Keybinding | Action |
|------------|--------|
| `Mod + h` | Focus left |
| `Mod + j` | Focus down |
| `Mod + k` | Focus up |
| `Mod + l` | Focus right |
| `Mod + Arrow keys` | Focus in direction |

### Window Movement

| Keybinding | Action |
|------------|--------|
| `Mod + Shift + h` | Move window left |
| `Mod + Shift + j` | Move window down |
| `Mod + Shift + k` | Move window up |
| `Mod + Shift + l` | Move window right |
| `Mod + Shift + Arrow` | Move window in direction |

### Workspaces

| Keybinding | Action |
|------------|--------|
| `Mod + 1-9` | Switch to workspace 1-9 |
| `Mod + 0` | Switch to workspace 10 |
| `Mod + Shift + 1-9` | Move window to workspace 1-9 |
| `Mod + Shift + 0` | Move window to workspace 10 |
| `Mod + Ctrl + h` | Move workspace to left output |
| `Mod + Ctrl + l` | Move workspace to right output |

### Layout

| Keybinding | Action |
|------------|--------|
| `Mod + b` | Split horizontally |
| `Mod + v` | Split vertically |
| `Mod + s` | Stacking layout |
| `Mod + w` | Tabbed layout |
| `Mod + t` | Toggle split |
| `Mod + f` | Toggle fullscreen |
| `Mod + Shift + Space` | Toggle floating |
| `Mod + Tab` | Toggle focus tiling/floating |
| `Mod + a` | Focus parent container |
| `Mod + c` | Focus child container |

### Resize Mode

| Keybinding | Action |
|------------|--------|
| `Mod + r` | Enter resize mode |
| `h / Left` | Shrink width |
| `l / Right` | Grow width |
| `k / Up` | Shrink height |
| `j / Down` | Grow height |
| `Escape / Return` | Exit resize mode |

### Scratchpad

| Keybinding | Action |
|------------|--------|
| `Mod + Shift + -` | Move to scratchpad |
| `Mod + -` | Show scratchpad |

### Screenshots

| Keybinding | Action |
|------------|--------|
| `Print` | Screenshot (full screen, save to file) |
| `Mod + Print` | Screenshot (full screen, clipboard) |
| `Shift + Print` | Screenshot (select area, save to file) |
| `Mod + Shift + Print` | Screenshot (select area, clipboard) |

### Media & Hardware

| Keybinding | Action |
|------------|--------|
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle mic mute |
| `XF86MonBrightnessUp` | Brightness up |
| `XF86MonBrightnessDown` | Brightness down |
| `XF86AudioPlay` | Play/Pause media |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |

---

## Tmux

**Prefix**: `Ctrl + a`

### Session Management

| Keybinding | Action |
|------------|--------|
| `prefix + d` | Detach from session |
| `prefix + (` | Switch to previous session |
| `prefix + )` | Switch to next session |
| `prefix + Q` | Kill session (with confirmation) |
| `prefix + r` | Reload tmux configuration |

### Window Management

| Keybinding | Action |
|------------|--------|
| `prefix + c` | Create new window |
| `prefix + &` | Kill window |
| `prefix + ,` | Rename window |
| `prefix + n` | Next window |
| `prefix + p` | Previous window |
| `prefix + 0-9` | Switch to window 0-9 |
| `Shift + Left` | Previous window |
| `Shift + Right` | Next window |
| `prefix + <` | Move window left |
| `prefix + >` | Move window right |

### Pane Management

| Keybinding | Action |
|------------|--------|
| `prefix + \|` | Split horizontally |
| `prefix + -` | Split vertically |
| `prefix + x` | Kill pane |
| `prefix + z` | Toggle pane zoom |
| `prefix + {` | Move pane left |
| `prefix + }` | Move pane right |
| `prefix + S` | Synchronize panes |

### Pane Navigation (Vim-style)

| Keybinding | Action |
|------------|--------|
| `prefix + h` | Move to left pane |
| `prefix + j` | Move to down pane |
| `prefix + k` | Move to up pane |
| `prefix + l` | Move to right pane |
| `Alt + h/j/k/l` | Move pane (no prefix) |
| `Alt + Arrow` | Move pane (no prefix) |

### Pane Resizing

| Keybinding | Action |
|------------|--------|
| `prefix + H` | Resize pane left |
| `prefix + J` | Resize pane down |
| `prefix + K` | Resize pane up |
| `prefix + L` | Resize pane right |

### Copy Mode (Vi-style)

| Keybinding | Action |
|------------|--------|
| `prefix + [` | Enter copy mode |
| `v` | Begin selection |
| `V` | Select line |
| `Ctrl + v` | Rectangle selection |
| `y` | Copy selection |
| `prefix + p` | Paste |
| `prefix + P` | Choose paste buffer |
| `/` | Search forward |
| `?` | Search backward |
| `n` | Next search result |
| `N` | Previous search result |

---

## Neovim

**Leader Key**: `Space`

### General

| Keybinding | Action |
|------------|--------|
| `Space` | Show which-key menu |
| `Ctrl + s` | Save file |
| `Space + q` | Quit |
| `Space + Q` | Quit all (force) |
| `Space + h` | Clear search highlight |
| `jk` or `jj` | Exit insert mode |

### File Navigation

| Keybinding | Action |
|------------|--------|
| `Space + e` | Toggle file explorer (Neo-tree) |
| `Space + o` | Focus file explorer |
| `Space + ff` | Find files (Telescope) |
| `Space + fg` | Live grep (Telescope) |
| `Space + fb` | Find buffers |
| `Space + fr` | Recent files |
| `Space + fp` | Find projects |

### Buffer Navigation

| Keybinding | Action |
|------------|--------|
| `Shift + h` | Previous buffer |
| `Shift + l` | Next buffer |
| `Space + bd` | Delete buffer |

### Window Navigation

| Keybinding | Action |
|------------|--------|
| `Ctrl + h` | Move to left window |
| `Ctrl + j` | Move to down window |
| `Ctrl + k` | Move to up window |
| `Ctrl + l` | Move to right window |
| `Ctrl + Up/Down` | Resize window height |
| `Ctrl + Left/Right` | Resize window width |

### LSP (Language Server)

| Keybinding | Action |
|------------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Go to references |
| `K` | Hover documentation |
| `Space + la` | Code action |
| `Space + lr` | Rename symbol |
| `Space + lf` | Format code |
| `Space + ld` | Show diagnostics |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |

### Git

| Keybinding | Action |
|------------|--------|
| `Space + gg` | Open LazyGit |
| `Space + gs` | Git status (Telescope) |
| `Space + gc` | Git commits |
| `Space + gb` | Git branches |

### Diagnostics (Trouble)

| Keybinding | Action |
|------------|--------|
| `Space + xx` | Toggle diagnostics |
| `Space + xX` | Buffer diagnostics |
| `Space + xl` | Location list |
| `Space + xq` | Quickfix list |

### Terminal

| Keybinding | Action |
|------------|--------|
| `Ctrl + \` | Toggle terminal |
| `Space + tf` | Float terminal |
| `Space + th` | Horizontal terminal |
| `Space + tv` | Vertical terminal |

### Editing

| Keybinding | Action |
|------------|--------|
| `gcc` | Toggle line comment |
| `gc` (visual) | Toggle comment selection |
| `Alt + j` | Move line down |
| `Alt + k` | Move line up |
| `<` (visual) | Indent left |
| `>` (visual) | Indent right |
| `Tab` | Next completion item |
| `Shift + Tab` | Previous completion item |
| `Ctrl + Space` | Trigger completion |
| `Enter` | Confirm completion |

### Surround

| Keybinding | Action |
|------------|--------|
| `ys{motion}{char}` | Add surround |
| `ds{char}` | Delete surround |
| `cs{old}{new}` | Change surround |

---

## Rofi

### Launching

| Keybinding | Action |
|------------|--------|
| `Mod + d` | Open Rofi (drun mode) |
| `Mod + Space` | Open Rofi (drun mode) |

### Within Rofi

| Keybinding | Action |
|------------|--------|
| `Type` | Filter results |
| `Up/Down` | Navigate items |
| `Enter` | Select item |
| `Escape` | Close Rofi |
| `Ctrl + Tab` | Switch mode |
| `Alt + 1-5` | Switch to mode 1-5 |

### Available Modes

- **drun**: Application launcher
- **run**: Command runner
- **window**: Window switcher
- **ssh**: SSH connections
- **filebrowser**: File browser

---

## Foot Terminal

### Clipboard

| Keybinding | Action |
|------------|--------|
| `Ctrl + Shift + c` | Copy |
| `Ctrl + Shift + v` | Paste |
| `Shift + Insert` | Paste from primary |

### Font Size

| Keybinding | Action |
|------------|--------|
| `Ctrl + +` | Increase font size |
| `Ctrl + -` | Decrease font size |
| `Ctrl + 0` | Reset font size |

### Scrollback

| Keybinding | Action |
|------------|--------|
| `Shift + PageUp` | Scroll up |
| `Shift + PageDown` | Scroll down |
| `Ctrl + Shift + u` | Scroll up half page |
| `Ctrl + Shift + d` | Scroll down half page |
| `Ctrl + Shift + k` | Scroll up line |
| `Ctrl + Shift + j` | Scroll down line |

### Other

| Keybinding | Action |
|------------|--------|
| `Ctrl + Shift + f` | Search |
| `Ctrl + Shift + n` | New terminal window |
| `Ctrl + Shift + o` | Open URL |

---

## Quick Reference Card

### Most Used (Daily)

| App | Keybinding | Action |
|-----|------------|--------|
| Sway | `Mod + Return` | Terminal |
| Sway | `Mod + d` | App launcher |
| Sway | `Mod + 1-9` | Switch workspace |
| Sway | `Mod + Shift + q` | Close window |
| Sway | `Mod + hjkl` | Navigate windows |
| Tmux | `Ctrl+a \|` | Split horizontal |
| Tmux | `Ctrl+a -` | Split vertical |
| Tmux | `Ctrl+a hjkl` | Navigate panes |
| Nvim | `Space + ff` | Find file |
| Nvim | `Space + fg` | Search text |
| Nvim | `Space + e` | File explorer |
| Nvim | `Space + gg` | Git (LazyGit) |

---

*Last updated: 2024*
