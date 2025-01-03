#pragma once
#include <vector>
#include <string>

struct PAMConfig {
    bool dev_mode = false;
    std::vector<std::string> monitored_events = {
        "auth",      // Uwierzytelnianie
        "session",   // Zarządzanie sesjami
        "account",   // Zarządzanie kontami
        "password"   // Zmiana hasła
    };
    std::string log_path = "/var/log/aegis_pam.log";
    std::string socket_path = "/var/run/aegis_pam.sock";
}; 