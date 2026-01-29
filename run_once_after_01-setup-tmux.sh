#!/bin/bash
# =============================================================================
# Tmux Plugin Manager Setup
# This script runs ONCE after configs are applied
# =============================================================================

set -e

echo "========================================"
echo " Setting up Tmux..."
echo "========================================"

# Install TPM if not present
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "TPM installed!"
    echo "Run 'prefix + I' in tmux to install plugins"
else
    echo "TPM already installed"
fi

echo "Tmux setup complete!"
