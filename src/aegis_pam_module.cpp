#include "pam_config.hpp"
#include "unix_socket.hpp"
#include <security/pam_modules.h>
#include <syslog.h>
#include <fstream>
#include <chrono>
#include "version.hpp"

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

    void log(const std::string& message) {
        syslog(LOG_AUTH|LOG_INFO, "Aegis PAM: %s", message.c_str());
        
        if (dev_mode && log_file.is_open()) {
            log_file << "PAM: " << message << std::endl;
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

    void log_startup() {
        auto now = std::chrono::system_clock::now();
        auto timestamp = std::chrono::system_clock::to_time_t(now);
        
        std::string build_type = dev_mode ? "DEBUG" : "PRODUCTION";
        std::string message = std::string(std::ctime(&timestamp)) + 
                             "PAM Module v" + AEGIS_VERSION + 
                             " starting in " + build_type + " mode";
        
        syslog(LOG_AUTH|LOG_INFO, "Aegis PAM: %s", message.c_str());
        
        if (dev_mode && log_file.is_open()) {
            log_file << message << std::endl;
        }
    }

    void flush() {
        if (dev_mode && log_file.is_open()) {
            log_file.flush();
        }
    }
};

extern "C" {
    PAM_EXTERN int pam_sm_authenticate(pam_handle_t *pamh, int flags, int argc, const char **argv) {
        try {
            PAMConfig config;
            #ifdef DEV_BUILD
            config.dev_mode = true;
            config.log_path = "/tmp/aegis_pam_dev.log";
            #endif

            PAMLogger logger(config.log_path, config.dev_mode);
            
            // Logowanie informacji o module
            logger.log("=== PAM Module Status ===");
            logger.log("Version: " + std::string(AEGIS_VERSION));
            logger.log("Build Type: " + std::string(BUILD_TYPE));
            logger.log("Dev Mode: " + std::string(config.dev_mode ? "enabled" : "disabled"));
            logger.log("Log Path: " + config.log_path);
            logger.log("=======================");
            logger.log("Starting authentication process...");
            
            const char *username = nullptr;
            int ret = pam_get_user(pamh, &username, nullptr);
            if (ret != PAM_SUCCESS) {
                logger.log("Failed to get username, error: " + std::to_string(ret));
                return ret;
            }
            
            logger.log("Got username: " + std::string(username));
            logger.log("Authentication flags: " + std::to_string(flags));
            
            // Wysyłanie wiadomości do agenta przez socket
            if (config.dev_mode) {
                try {
                    UnixSocket socket(config.socket_path, false);
                    std::string auth_msg = "AUTH_SUCCESS|" + std::string(username);
                    socket.send(auth_msg);
                    logger.log("Sent auth success message to agent");
                } catch (const std::exception& e) {
                    logger.log("Failed to send message to agent: " + std::string(e.what()));
                }
            }

            logger.flush();
            return PAM_SUCCESS;
        } catch (const std::exception& e) {
            syslog(LOG_AUTH|LOG_ERR, "Aegis PAM error: %s", e.what());
            return PAM_SYSTEM_ERR;
        }
    }

    // Pozostałe wymagane funkcje PAM
    PAM_EXTERN int pam_sm_setcred(pam_handle_t *pamh, int flags, int argc, const char **argv) {
        return PAM_IGNORE;
    }

    PAM_EXTERN int pam_sm_acct_mgmt(pam_handle_t *pamh, int flags, int argc, const char **argv) {
        return PAM_IGNORE;
    }

    PAM_EXTERN int pam_sm_open_session(pam_handle_t *pamh, int flags, int argc, const char **argv) {
        return PAM_IGNORE;
    }

    PAM_EXTERN int pam_sm_close_session(pam_handle_t *pamh, int flags, int argc, const char **argv) {
        return PAM_IGNORE;
    }
}
