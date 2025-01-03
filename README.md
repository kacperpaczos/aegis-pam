# aegis-pam

⚠️ **WARNING: SYSTEM MODIFICATION RISK** ⚠️

This module modifies core system authentication mechanisms. Incorrect configuration or bugs may lead to system lockout or authentication failures. Always test in a safe environment first and keep an emergency root terminal open during development.

## Overview

The aegis-pam module provides integration with PAM (Pluggable Authentication Modules) - a universal authentication framework for Unix/Linux systems.

PAM serves as a standard interface mediating between applications and authentication mechanisms, enabling modular and configurable access control.

## Key Features

- Unified authentication mechanism
- Compatibility with existing PAM infrastructure
- Flexible security policy configuration
- Support for various authorization methods
- Development mode with enhanced logging
- Emergency terminal fallback

## Architecture

The system consists of three main components:

1. **PAM Module** (`pam_aegis.so`)
   - Installed in the PAM system
   - Intercepts authentication requests
   - Lightweight and fast processing
   - Communicates with the agent via socket

2. **Aegis Agent** (`aegis_pam_agent`)
   - Background service
   - Handles complex authentication logic
   - Manages security policies
   - Provides logging and monitoring
   - Automatic restart capability

3. **Configuration Layer**
   - PAM stack configuration
   - Agent configuration
   - Security policy definitions
   - Development mode settings

## Integration Points

The module activates during:
- Execution of sudo command
- User session login
- User switching (su)
- Screen unlock
- Any PAM-aware application authentication

## System Requirements

- Linux system with PAM framework
- Root privileges for installation
- systemd for service management
- C++20 compatible compiler
- meson build system

## Development Mode

Development mode provides:
- Enhanced logging at `/tmp/aegis_pam_dev.log`
- Real-time monitoring tools
- Emergency root terminal
- Detailed authentication tracking

## Security Considerations

1. **System Access**
   - Always maintain an emergency root terminal during development
   - Keep original PAM configuration backups
   - Test in a safe environment first

2. **Monitoring**
   - Check logs for unauthorized access attempts
   - Monitor agent status regularly
   - Review authentication patterns

3. **Recovery**
   - Emergency terminal provides system access if PAM fails
   - Uninstall script restores original configuration
   - Backup of original PAM settings is maintained

## License

This project is licensed under GNU General Public License v3.0 - see the LICENSE file for details.

## Contributing

Before contributing:
1. Test all changes in an isolated environment
2. Maintain comprehensive logging
3. Document security implications
4. Follow secure coding practices
5. Include test cases

## Emergency Recovery

In case of authentication issues:
1. Use the emergency terminal (if available)
2. Boot in single-user mode
3. Execute the uninstall script
4. Restore original PAM configuration

Remember: PAM modifications can lock you out of your system. Always maintain a backup authentication method.