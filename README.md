# aegis-pam

The aegis-pam module provides integration with PAM (Pluggable Authentication Modules) - a universal authentication framework for Unix/Linux systems.

PAM serves as a standard interface mediating between applications and authentication mechanisms, enabling modular and configurable access control.

Through PAM integration, aegis can be seamlessly implemented in any Linux distribution using this framework, providing:

- Unified authentication mechanism
- Compatibility with existing PAM infrastructure
- Flexible security policy configuration
- Support for various authorization methods

## Architecture

The module consists of two main components:
1. PAM Module - installed in the PAM system, responsible for intercepting authentication requests
2. Aegis Agent - service triggered in response to PAM events

## Integration Points

The module activates in the following cases:
- Execution of sudo command
- User session login
- User switching (su)
- Screen unlock

## System Requirements

- Installed PAM framework
- Root privileges for PAM module configuration