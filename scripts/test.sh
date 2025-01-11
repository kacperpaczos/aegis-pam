#!/bin/bash
set -e

echo "Testing Aegis PAM module..."

# Check if running in debug mode
if [ -f "/tmp/aegis_pam_dev.log" ]; then
    echo "Debug mode detected"
    LOGFILE="/tmp/aegis_pam_dev.log"
else
    echo "Production mode detected"
    LOGFILE="/var/log/aegis_pam.log"
fi

# Component verification
echo "Verifying components..."

# Check PAM module
if [ -f "/lib/security/pam_aegis.so" ]; then
    echo "✓ PAM module installed"
else
    echo "✗ PAM module missing"
    exit 1
fi

# Check agent
if [ -f "/usr/local/bin/aegis_pam_agent" ]; then
    echo "✓ Agent binary present"
else
    echo "✗ Agent binary missing"
    exit 1
fi

# Check agent service
if systemctl is-active --quiet aegis_pam_agent; then
    echo "✓ Agent service running"
else
    echo "✗ Agent service not running"
    exit 1
fi

echo "All components verified successfully!"

# Po sprawdzeniu komponentów
echo "Testing PAM integration..."
if pamtester -n aegis $USER authenticate; then
    echo "✓ PAM authentication test passed"
else
    echo "✗ PAM authentication test failed"
    exit 1
fi 