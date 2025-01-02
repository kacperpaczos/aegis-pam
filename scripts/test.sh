#!/bin/bash
set -e

echo "Testing Aegis PAM module..."

# Czyszczenie logów
sudo truncate -s 0 /var/log/auth.log

# Test sudo
echo "Testing sudo authentication..."
sudo echo "Sudo test"

# Test su
echo "Testing su authentication..."
su -c "whoami" $USER

# Sprawdzenie logów
echo -e "\nChecking syslog entries:"
sudo grep "Aegis PAM:" /var/log/auth.log

# Sprawdzenie statusu agenta
echo -e "\nChecking Aegis agent status:"
systemctl status aegis-agent

# Wyświetlenie statystyk
echo -e "\nAuthentication statistics:"
sudo grep "Aegis PAM:" /var/log/auth.log | sort | uniq -c 