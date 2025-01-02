#!/bin/bash

echo "Monitoring Aegis PAM activities..."
echo "Press Ctrl+C to stop"

# Monitorowanie logów w czasie rzeczywistym
sudo tail -f /var/log/auth.log | grep --line-buffered "Aegis PAM:" 