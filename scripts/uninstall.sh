#!/bin/bash

# Check if script is running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

echo "Uninstalling Aegis PAM module..."

# Stop agent
systemctl stop aegis_pam_agent || true
systemctl disable aegis_pam_agent || true

# Remove systemd unit
rm -f /etc/systemd/system/aegis_pam_agent.service
systemctl daemon-reload
systemctl reset-failed

# Remove files installed by meson
rm -f /lib/security/pam_aegis.so
rm -f /usr/local/bin/aegis_pam_agent

# Remove configuration files
rm -f /etc/pam.d/aegis-auth
rm -f /etc/aegis/aegis_pam_agent.conf

# Remove directories
rm -rf /etc/aegis
rm -rf /var/run/aegis
rm -f /tmp/aegis_pam_dev.log

# Restore original PAM configuration
if [ -f /etc/pam.d/common-auth.orig ]; then
    mv /etc/pam.d/common-auth.orig /etc/pam.d/common-auth
else
    echo "Warning: Original PAM config backup not found!"
fi

# Clean temporary files
rm -f /tmp/aegis_pam_*.log
rm -f /var/log/aegis_pam.log

# Remove build directory
rm -rf builddir

echo "Uninstallation completed successfully!" 