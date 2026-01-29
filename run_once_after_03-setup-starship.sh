#!/bin/bash
# =============================================================================
# Starship Prompt Setup
# =============================================================================

set -e

echo "========================================"
echo " Setting up Starship..."
echo "========================================"

# Link starship config to correct location
STARSHIP_CONFIG="$HOME/.config/starship.toml"
STARSHIP_SOURCE="$HOME/.config/starship/starship.toml"

if [ -f "$STARSHIP_SOURCE" ] && [ ! -f "$STARSHIP_CONFIG" ]; then
    ln -sf "$STARSHIP_SOURCE" "$STARSHIP_CONFIG"
    echo "Starship config linked!"
elif [ -f "$STARSHIP_CONFIG" ]; then
    echo "Starship config already exists"
fi

# Install starship if not present (and not on rpm-ostree)
if ! command -v starship &>/dev/null; then
    if ! command -v rpm-ostree &>/dev/null; then
        echo "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        echo "Starship should be installed via rpm-ostree"
    fi
fi

echo "Starship setup complete!"
