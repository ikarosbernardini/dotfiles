#!/bin/bash
# =============================================================================
# Enable system services for MacBook hardware
# This script runs ONCE after configs are applied
# =============================================================================

set -e

echo "========================================"
echo " Enabling hardware services..."
echo "========================================"

# Check if we're on Fedora with systemd
if [ ! -f /etc/fedora-release ] || ! command -v systemctl &>/dev/null; then
    echo "Not on Fedora or no systemd, skipping"
    exit 0
fi

# mbpfan (MacBook fan control) - disabled for testing
# To enable manually: sudo systemctl enable --now mbpfan

# Enable TLP (power management)
if rpm -q tlp &>/dev/null; then
    if ! systemctl is-enabled tlp &>/dev/null; then
        echo "Enabling TLP service..."
        sudo systemctl enable --now tlp || true
    else
        echo "TLP already enabled"
    fi
fi

echo "Hardware services configured!"
