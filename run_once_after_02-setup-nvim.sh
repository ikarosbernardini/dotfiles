#!/bin/bash
# =============================================================================
# Neovim Plugin Setup
# This script runs ONCE after configs are applied
# =============================================================================

set -e

echo "========================================"
echo " Setting up Neovim..."
echo "========================================"

# Check if Neovim is installed
if ! command -v nvim &>/dev/null; then
    echo "Neovim not installed, skipping plugin setup"
    exit 0
fi

# Install plugins via lazy.nvim (headless)
echo "Installing Neovim plugins..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

echo "Neovim setup complete!"
echo "Open nvim and run :checkhealth to verify"
