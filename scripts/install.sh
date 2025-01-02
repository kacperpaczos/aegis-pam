#!/bin/bash
set -e

echo "Installing Aegis PAM module..."

# Budowanie projektu
meson setup builddir
cd builddir
meson compile
sudo meson install

# Konfiguracja PAM
echo "Configuring PAM..."
sudo cp ../config/aegis-auth /etc/pam.d/
sudo ln -sf /etc/pam.d/aegis-auth /etc/pam.d/common-auth

# Uruchomienie agenta
echo "Starting Aegis PAM agent..."
sudo systemctl enable aegis_pam_agent
sudo systemctl start aegis_pam_agent

sudo cp config/aegis-agent.service /etc/systemd/system/
sudo systemctl daemon-reload

echo "Installation completed successfully!" 