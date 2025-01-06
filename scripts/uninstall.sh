#!/bin/bash

# Check if script is running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

echo "Uninstalling Aegis PAM module..."

# Przywracanie kopii zapasowej
restore_backup() {
    if [ -f /etc/aegis/last_backup ]; then
        local backup_dir=$(cat /etc/aegis/last_backup)
        if [ -d "$backup_dir" ]; then
            echo "Przywracanie kopii zapasowej z: $backup_dir"
            
            # Przywracanie plików konfiguracyjnych
            if [ -f "$backup_dir/common-auth" ]; then
                cp "$backup_dir/common-auth" /etc/pam.d/
            fi
            if [ -f "$backup_dir/sudo" ]; then
                cp "$backup_dir/sudo" /etc/pam.d/
            fi
            
            echo "Kopia zapasowa przywrócona"
        else
            echo "Nie znaleziono katalogu kopii zapasowej: $backup_dir"
        fi
    else
        echo "Nie znaleziono informacji o ostatniej kopii zapasowej"
    fi
}

# Zatrzymanie i wyłączenie agenta
systemctl stop aegis_pam_agent 2>/dev/null || true
systemctl disable aegis_pam_agent 2>/dev/null || true

# Usuwanie plików
rm -f /lib/security/pam_aegis.so
rm -f /usr/local/bin/aegis_pam_agent
rm -f /etc/systemd/system/aegis_pam_agent.service
rm -f /etc/pam.d/aegis

# Czyszczenie konfiguracji PAM
sed -i '/@include aegis/d' /etc/pam.d/common-auth 2>/dev/null || true
sed -i '/@include aegis/d' /etc/pam.d/sudo 2>/dev/null || true

# Przywracanie kopii zapasowej
restore_backup

# Usuwanie pozostałych plików
rm -f /tmp/aegis_pam_dev.log
rm -f /var/log/aegis_pam.log

# Zabijanie sesji monitorowania
tmux kill-session -t aegis_monitor 2>/dev/null || true

# Przeładowanie systemd
systemctl daemon-reload
systemctl reset-failed

# Usuwanie katalogu budowania
rm -rf builddir

echo "Uninstallation completed successfully!" 