#!/bin/bash
# =============================================================================
# Battery Optimization Script for MacBook on Fedora Sway Atomic
# Author: Ikaros
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# =============================================================================
# Check Prerequisites
# =============================================================================

check_prerequisites() {
    info "Checking prerequisites..."

    # Check if running as root for some operations
    if [ "$EUID" -eq 0 ]; then
        error "Do not run this script as root. It will ask for sudo when needed."
        exit 1
    fi

    # Check if running on battery-capable device
    if [ ! -d /sys/class/power_supply/BAT0 ] && [ ! -d /sys/class/power_supply/BAT1 ]; then
        warning "No battery detected. Some optimizations may not apply."
    fi

    success "Prerequisites check complete."
}

# =============================================================================
# TLP Configuration
# =============================================================================

setup_tlp() {
    info "Setting up TLP power management..."

    # Check if TLP is installed
    if ! command -v tlp &>/dev/null; then
        warning "TLP is not installed."
        read -p "TLP should be installed via rpm-ostree. Continue without TLP? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error "Please install TLP first: sudo rpm-ostree install tlp tlp-rdw"
            exit 1
        fi
        return 0
    fi

    # Create TLP configuration
    info "Creating TLP configuration..."

    sudo tee /etc/tlp.d/01-battery-optimization.conf > /dev/null << 'EOF'
# =============================================================================
# TLP Configuration for MacBook Battery Optimization
# =============================================================================

# Operation mode when no power supply can be detected: AC, BAT
TLP_DEFAULT_MODE=BAT

# Operation mode select: 0=depend on power source, 1=always use TLP_DEFAULT_MODE
TLP_PERSISTENT_DEFAULT=0

# =============================================================================
# CPU Settings
# =============================================================================

# Intel CPU: EPB energy/performance policies
CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance
CPU_ENERGY_PERF_POLICY_ON_BAT=power

# CPU frequency scaling governor
CPU_SCALING_GOVERNOR_ON_AC=powersave
CPU_SCALING_GOVERNOR_ON_BAT=powersave

# Intel CPU: P-state driver options
CPU_MIN_PERF_ON_AC=0
CPU_MAX_PERF_ON_AC=100
CPU_MIN_PERF_ON_BAT=0
CPU_MAX_PERF_ON_BAT=50

# Intel CPU: turbo boost
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=0

# Intel CPU: HWP dynamic boost
CPU_HWP_DYN_BOOST_ON_AC=1
CPU_HWP_DYN_BOOST_ON_BAT=0

# =============================================================================
# Disk Settings
# =============================================================================

# Hard disk advanced power management level: 1..254, 255 (off)
DISK_APM_LEVEL_ON_AC="254 254"
DISK_APM_LEVEL_ON_BAT="128 128"

# AHCI runtime power management for SATA drives
SATA_LINKPWR_ON_AC="med_power_with_dipm max_performance"
SATA_LINKPWR_ON_BAT="med_power_with_dipm min_power"

# NVMe runtime power management
NVME_RUNTIME_PM_ON_AC=auto
NVME_RUNTIME_PM_ON_BAT=auto

# =============================================================================
# Graphics Settings
# =============================================================================

# Intel GPU frequency limits
INTEL_GPU_MIN_FREQ_ON_AC=0
INTEL_GPU_MIN_FREQ_ON_BAT=0
INTEL_GPU_MAX_FREQ_ON_AC=0
INTEL_GPU_MAX_FREQ_ON_BAT=0
INTEL_GPU_BOOST_FREQ_ON_AC=0
INTEL_GPU_BOOST_FREQ_ON_BAT=0

# AMD GPU power management
RADEON_DPM_PERF_LEVEL_ON_AC=auto
RADEON_DPM_PERF_LEVEL_ON_BAT=low
RADEON_DPM_STATE_ON_AC=performance
RADEON_DPM_STATE_ON_BAT=battery
RADEON_POWER_PROFILE_ON_AC=default
RADEON_POWER_PROFILE_ON_BAT=low

# =============================================================================
# USB Settings
# =============================================================================

# USB autosuspend
USB_AUTOSUSPEND=1

# Exclude USB devices from autosuspend
USB_DENYLIST="usbhid"

# =============================================================================
# Network Settings
# =============================================================================

# WiFi power saving mode
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on

# Disable wake on LAN
WOL_DISABLE=Y

# =============================================================================
# Audio Settings
# =============================================================================

# Intel HDA audio power saving timeout (secs)
SOUND_POWER_SAVE_ON_AC=0
SOUND_POWER_SAVE_ON_BAT=1

# Intel HDA audio controller power save
SOUND_POWER_SAVE_CONTROLLER=Y

# =============================================================================
# Platform Settings
# =============================================================================

# Runtime power management for PCIe devices
RUNTIME_PM_ON_AC=auto
RUNTIME_PM_ON_BAT=auto

# PCI Express ASPM (power saving)
PCIE_ASPM_ON_AC=default
PCIE_ASPM_ON_BAT=powersupersave

# =============================================================================
# Battery Settings
# =============================================================================

# Battery charge thresholds (if supported by hardware)
# Start charging below this threshold
START_CHARGE_THRESH_BAT0=75
# Stop charging above this threshold
STOP_CHARGE_THRESH_BAT0=80

# =============================================================================
# Misc Settings
# =============================================================================

# Restore device state on system startup
RESTORE_DEVICE_STATE_ON_STARTUP=0

# Restore ThinkPad radio device state
RESTORE_THINKPAD_RADIO_STATE=0
EOF

    # Enable and start TLP
    sudo systemctl enable tlp
    sudo systemctl start tlp || warning "TLP may need a reboot to start properly"

    # Mask conflicting services
    sudo systemctl mask systemd-rfkill.service || true
    sudo systemctl mask systemd-rfkill.socket || true

    success "TLP configuration complete!"
}

# =============================================================================
# Powertop Auto-tune
# =============================================================================

setup_powertop() {
    info "Setting up powertop auto-tune..."

    # Check if powertop is installed
    if ! command -v powertop &>/dev/null; then
        warning "powertop is not installed."
        warning "Install with: sudo rpm-ostree install powertop"
        return 0
    fi

    # Create systemd service for powertop auto-tune
    info "Creating powertop auto-tune service..."

    sudo tee /etc/systemd/system/powertop-auto-tune.service > /dev/null << 'EOF'
[Unit]
Description=Powertop auto-tune
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/powertop --auto-tune

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable powertop-auto-tune.service
    sudo systemctl start powertop-auto-tune.service || warning "Service may need a reboot"

    success "Powertop auto-tune service enabled!"
}

# =============================================================================
# Brightness Control
# =============================================================================

setup_brightness() {
    info "Setting up brightness control..."

    # Check if light is installed
    if ! command -v light &>/dev/null; then
        warning "light is not installed for brightness control."
        warning "Install with: sudo rpm-ostree install light"
        return 0
    fi

    # Add user to video group for light control
    if ! groups | grep -q video; then
        info "Adding user to video group..."
        sudo usermod -aG video "$USER"
        warning "You need to log out and back in for group changes to take effect."
    fi

    # Create udev rules for backlight control
    info "Setting up backlight permissions..."

    sudo tee /etc/udev/rules.d/90-backlight.rules > /dev/null << 'EOF'
# Allow video group to control backlight
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
EOF

    # Apply udev rules
    sudo udevadm control --reload-rules
    sudo udevadm trigger

    success "Brightness control configured!"
}

# =============================================================================
# CPU Governor Script
# =============================================================================

setup_cpu_governor() {
    info "Setting up CPU governor helper..."

    # Create a helper script for manual CPU governor control
    mkdir -p ~/.local/bin

    cat > ~/.local/bin/power-mode << 'EOF'
#!/bin/bash
# Power mode switcher

case "$1" in
    performance)
        echo "Switching to performance mode..."
        sudo cpupower frequency-set -g performance
        echo "Performance mode enabled"
        ;;
    powersave)
        echo "Switching to power save mode..."
        sudo cpupower frequency-set -g powersave
        echo "Power save mode enabled"
        ;;
    balanced)
        echo "Switching to balanced mode..."
        sudo cpupower frequency-set -g schedutil 2>/dev/null || \
        sudo cpupower frequency-set -g ondemand
        echo "Balanced mode enabled"
        ;;
    status)
        echo "Current CPU information:"
        cpupower frequency-info
        echo
        echo "Current governor:"
        cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
        ;;
    *)
        echo "Usage: power-mode {performance|powersave|balanced|status}"
        exit 1
        ;;
esac
EOF

    chmod +x ~/.local/bin/power-mode

    success "CPU governor helper script created: power-mode"
}

# =============================================================================
# Display Power Management
# =============================================================================

setup_display_pm() {
    info "Setting up display power management..."

    # Create a sway config snippet for idle management
    mkdir -p ~/.config/sway/config.d

    cat > ~/.config/sway/config.d/power-management << 'EOF'
# =============================================================================
# Power Management Configuration for Sway
# =============================================================================

# Idle configuration
# Lock screen after 5 minutes, turn off display after 10 minutes
exec swayidle -w \
    timeout 300 'swaylock -f -c 1a1b26' \
    timeout 600 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' \
    before-sleep 'swaylock -f -c 1a1b26'

# Battery mode - more aggressive power saving
# Uncomment to enable
# exec_always ~/.local/bin/battery-monitor
EOF

    success "Display power management configured!"
}

# =============================================================================
# Battery Monitor Script
# =============================================================================

setup_battery_monitor() {
    info "Setting up battery monitor script..."

    mkdir -p ~/.local/bin

    cat > ~/.local/bin/battery-monitor << 'EOF'
#!/bin/bash
# Battery monitoring script for notifications and auto-actions

BATTERY_PATH="/sys/class/power_supply/BAT0"
if [ ! -d "$BATTERY_PATH" ]; then
    BATTERY_PATH="/sys/class/power_supply/BAT1"
fi

if [ ! -d "$BATTERY_PATH" ]; then
    echo "No battery found"
    exit 1
fi

LOW_THRESHOLD=20
CRITICAL_THRESHOLD=10

while true; do
    CAPACITY=$(cat "$BATTERY_PATH/capacity")
    STATUS=$(cat "$BATTERY_PATH/status")

    if [ "$STATUS" = "Discharging" ]; then
        if [ "$CAPACITY" -le "$CRITICAL_THRESHOLD" ]; then
            notify-send -u critical "Battery Critical" "Battery at ${CAPACITY}%. Connect charger immediately!"
        elif [ "$CAPACITY" -le "$LOW_THRESHOLD" ]; then
            notify-send -u normal "Battery Low" "Battery at ${CAPACITY}%. Consider connecting charger."
        fi
    fi

    sleep 60
done
EOF

    chmod +x ~/.local/bin/battery-monitor

    success "Battery monitor script created!"
}

# =============================================================================
# Show Current Status
# =============================================================================

show_status() {
    echo
    echo "=========================================="
    echo " Current Power Status"
    echo "=========================================="

    # Battery status
    if [ -d /sys/class/power_supply/BAT0 ]; then
        echo
        echo "Battery:"
        echo "  Capacity: $(cat /sys/class/power_supply/BAT0/capacity)%"
        echo "  Status: $(cat /sys/class/power_supply/BAT0/status)"
    fi

    # TLP status
    if command -v tlp &>/dev/null; then
        echo
        echo "TLP Status:"
        sudo tlp-stat -s 2>/dev/null | head -n 10 || echo "  Run 'sudo tlp-stat' for details"
    fi

    # CPU governor
    echo
    echo "CPU Governor:"
    echo "  $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "N/A")"

    # Current power consumption (if available)
    if command -v powertop &>/dev/null; then
        echo
        echo "Power consumption:"
        echo "  Run 'sudo powertop' for detailed analysis"
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    echo "=========================================="
    echo " MacBook Battery Optimization"
    echo " for Fedora Sway Atomic"
    echo "=========================================="
    echo

    check_prerequisites

    echo
    echo "Select optimization to apply:"
    echo "  1) All optimizations"
    echo "  2) TLP configuration only"
    echo "  3) Powertop auto-tune only"
    echo "  4) Brightness control only"
    echo "  5) CPU governor helper only"
    echo "  6) Display power management only"
    echo "  7) Battery monitor script only"
    echo "  8) Show current power status"
    echo "  q) Quit"
    echo

    read -p "Enter your choice [1-8/q]: " choice

    case $choice in
        1)
            setup_tlp
            setup_powertop
            setup_brightness
            setup_cpu_governor
            setup_display_pm
            setup_battery_monitor
            ;;
        2) setup_tlp ;;
        3) setup_powertop ;;
        4) setup_brightness ;;
        5) setup_cpu_governor ;;
        6) setup_display_pm ;;
        7) setup_battery_monitor ;;
        8) show_status ;;
        q|Q) exit 0 ;;
        *)
            error "Invalid choice."
            exit 1
            ;;
    esac

    echo
    success "Battery optimization complete!"
    echo
    warning "Some changes may require a reboot to take effect."
    echo
    info "Useful commands:"
    echo "  - Check TLP status: sudo tlp-stat"
    echo "  - Run powertop: sudo powertop"
    echo "  - Change power mode: power-mode {performance|powersave|balanced|status}"
    echo "  - Adjust brightness: light -A 5 / light -U 5"
}

main "$@"
