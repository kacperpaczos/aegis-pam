#include "pam_config.hpp"
#include <security/pam_modules.h>
#include <syslog.h>
#include <fstream>
#include <chrono>

class PAMLogger {
private:
    std::ofstream log_file;
    bool dev_mode;

public:
    PAMLogger(const std::string& log_path, bool dev_mode) 
        : dev_mode(dev_mode) {
        if (dev_mode) {
            log_file.open(log_path, std::ios::app);
        }
    }

    void log(const std::string& event, const std::string& username) {
        auto now = std::chrono::system_clock::now();
        auto timestamp = std::chrono::system_clock::to_time_t(now);
        
        std::string message = std::string(std::ctime(&timestamp)) + 
                             " Event: " + event + 
                             " User: " + username;

        syslog(LOG_AUTH|LOG_INFO, "Aegis PAM: %s", message.c_str());
        
        if (dev_mode && log_file.is_open()) {
            log_file << message << std::endl;
        }
    }
};

extern "C" {
    PAM_EXTERN int pam_sm_authenticate(pam_handle_t *pamh, int flags, int argc, const char **argv) {
        const char *username;
        PAMConfig config;
        
        // W trybie dev ustawiamy dodatkowe opcje
        #ifdef DEV_BUILD
        config.dev_mode = true;
        config.log_path = "/tmp/aegis_pam_dev.log";
        #endif

        PAMLogger logger(config.log_path, config.dev_mode);

        if (pam_get_user(pamh, &username, nullptr) != PAM_SUCCESS) {
            return PAM_AUTH_ERR;
        }

        logger.log("authenticate", username);
        return PAM_SUCCESS;
    }
}
