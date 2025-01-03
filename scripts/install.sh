#!/bin/bash

# Check if script is running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Function to find available terminal
find_terminal() {
    if command -v gnome-terminal &> /dev/null; then
        echo "gnome-terminal"
    elif command -v konsole &> /dev/null; then
        echo "konsole"
    elif command -v xterm &> /dev/null; then
        echo "xterm"
    else
        echo ""
    fi
}

# Launch root terminal with warning
TERMINAL=$(find_terminal)
if [ ! -z "$TERMINAL" ]; then
    if [ "$TERMINAL" = "gnome-terminal" ]; then
        gnome-terminal --window --title="PAM Emergency Terminal (ROOT)" -- bash -c 'echo -e "\033[1;31mWARNING: Do not close this window!\033[0m\nThis is an emergency root terminal in case of PAM issues.\nKeep this window open during development work.\n\nIn case of sudo problems, you can use this terminal.\n"; bash'
    elif [ "$TERMINAL" = "konsole" ]; then
        konsole --separate --title="PAM Emergency Terminal (ROOT)" -e bash -c 'echo -e "\033[1;31mWARNING: Do not close this window!\033[0m\nThis is an emergency root terminal in case of PAM issues.\nKeep this window open during development work.\n\nIn case of sudo problems, you can use this terminal.\n"; bash'
    elif [ "$TERMINAL" = "xterm" ]; then
        xterm -T "PAM Emergency Terminal (ROOT)" -e bash -c 'echo -e "\033[1;31mWARNING: Do not close this window!\033[0m\nThis is an emergency root terminal in case of PAM issues.\nKeep this window open during development work.\n\nIn case of sudo problems, you can use this terminal.\n"; bash'
    fi
fi

echo "Installing Aegis PAM module..."

# Create directories
mkdir -p /etc/aegis
mkdir -p /var/run/aegis
mkdir -p /tmp

# Build project
meson setup builddir
cd builddir
meson compile
meson install

# Configure PAM
echo "Configuring PAM..."
cp ../config/aegis-auth /etc/pam.d/
cp /etc/pam.d/common-auth /etc/pam.d/common-auth.orig
ln -sf /etc/pam.d/aegis-auth /etc/pam.d/common-auth

# Configure and start agent
echo "Starting Aegis PAM agent..."
cp ../config/aegis_pam_agent.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable aegis_pam_agent
systemctl start aegis_pam_agent

echo "Installation completed successfully!" 