#!/bin/bash

echo "Monitoring Aegis PAM in dev mode..."
echo "Press Ctrl+C to stop"

# Czekaj na utworzenie pliku logu jeśli nie istnieje
while [ ! -f /tmp/aegis_pam_dev.log ]; do
    echo "Waiting for log file to be created..."
    sleep 1
done

# Monitorowanie logów deweloperskich w czasie rzeczywistym
tail -f /tmp/aegis_pam_dev.log 