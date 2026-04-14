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

# mbpfan (MacBook fan control) with custom fan curve
if rpm -q mbpfan &>/dev/null; then
    echo "Configuring mbpfan..."
    sudo tee /etc/mbpfan.conf > /dev/null <<'EOF'
[general]
low_temp = 63
high_temp = 66
max_temp = 86
polling_interval = 1
EOF
    if ! systemctl is-enabled mbpfan &>/dev/null; then
        echo "Enabling mbpfan service..."
        sudo systemctl enable --now mbpfan || true
    else
        echo "mbpfan already enabled"
        sudo systemctl restart mbpfan || true
    fi
fi

# Enable TLP (power management)
if rpm -q tlp &>/dev/null; then
    if ! systemctl is-enabled tlp &>/dev/null; then
        echo "Enabling TLP service..."
        sudo systemctl enable --now tlp || true
    else
        echo "TLP already enabled"
    fi
fi

# Enable Tailscale
if rpm -q tailscale &>/dev/null; then
    if ! systemctl is-enabled tailscaled &>/dev/null; then
        echo "Enabling Tailscale service..."
        sudo systemctl enable --now tailscaled || true
        echo "NOTE: Run 'sudo tailscale up' to authenticate"
    else
        echo "Tailscale already enabled"
    fi
fi

echo "Hardware services configured!"
