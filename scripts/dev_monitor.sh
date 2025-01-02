#!/bin/bash

echo "Monitoring Aegis PAM in dev mode..."
echo "Press Ctrl+C to stop"

# Monitorowanie logów deweloperskich w czasie rzeczywistym
tail -f /tmp/aegis_pam_dev.log 