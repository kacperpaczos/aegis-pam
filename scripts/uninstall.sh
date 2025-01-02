#!/bin/bash
set -e

echo "Uninstalling Aegis PAM module..."

# Zatrzymanie agenta
sudo systemctl stop aegis-agent
sudo systemctl disable aegis-agent

# Usunięcie jednostki systemd
sudo rm -f /etc/systemd/system/aegis-agent.service
sudo systemctl daemon-reload
sudo systemctl reset-failed

# Usunięcie plików PAM
sudo rm -f /lib/security/pam_aegis.so
sudo rm -f /etc/pam.d/aegis-auth
sudo rm -f /usr/local/bin/aegis-agent

# Przywrócenie oryginalnej konfiguracji PAM
sudo ln -sf /etc/pam.d/common-auth.orig /etc/pam.d/common-auth

echo "Uninstallation completed successfully!" 