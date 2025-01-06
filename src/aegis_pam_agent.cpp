#include "version.hpp"
#include "pam_config.hpp"
#include <iostream>
#include <thread>
#include <syslog.h>
#include <fstream>
#include <atomic>
#include <signal.h>

class AgentLogger {
private:
    std::ofstream log_file;
    bool dev_mode;
    std::chrono::system_clock::time_point start_time;

public:
    AgentLogger(const std::string& log_path, bool dev_mode) 
        : dev_mode(dev_mode), start_time(std::chrono::system_clock::now()) {
        if (dev_mode) {
            log_file.open(log_path, std::ios::app);
        }
        log_startup();
    }

    void log_startup() {
        auto timestamp = std::chrono::system_clock::to_time_t(start_time);
        std::string build_type = dev_mode ? "DEBUG" : "PRODUCTION";
        std::string message = std::string(std::ctime(&timestamp)) + 
                            "Agent v" + AEGIS_VERSION + 
                            " starting in " + build_type + " mode";
        
        syslog(LOG_AUTH|LOG_INFO, "Aegis Agent: %s", message.c_str());
        
        if (dev_mode && log_file.is_open()) {
            log_file << message << std::endl;
        }
    }

    void log(const std::string& message) {
        syslog(LOG_AUTH|LOG_INFO, "Aegis Agent: %s", message.c_str());
        
        if (dev_mode && log_file.is_open()) {
            log_file << "Agent: " << message << std::endl;
        }
    }

    void error(const std::string& message) {
        syslog(LOG_AUTH|LOG_ERR, "Aegis Agent Error: %s", message.c_str());
        
        if (dev_mode && log_file.is_open()) {
            log_file << "Agent Error: " << message << std::endl;
        }
    }
};

class AegisAgent {
private:
    AgentLogger logger;
    PAMConfig config;
    std::atomic<bool>& running;
    std::chrono::system_clock::time_point start_time;

public:
    AegisAgent(const PAMConfig& cfg, std::atomic<bool>& run_flag) 
        : logger(cfg.log_path, cfg.dev_mode),
          config(cfg),
          running(run_flag),
          start_time(std::chrono::system_clock::now()) {
        logger.log("Agent started");
    }

    void process_events() {
        static int cycle_count = 0;
        cycle_count++;
        
        if (config.dev_mode && cycle_count % 50 == 0) { // Co 5 sekund (50 * 100ms)
            auto now = std::chrono::system_clock::now();
            auto uptime = std::chrono::duration_cast<std::chrono::seconds>(
                now - start_time).count();
            
            logger.log("=== Agent Status ===");
            logger.log("Version: " + std::string(AEGIS_VERSION));
            logger.log("Build Type: " + std::string(BUILD_TYPE));
            logger.log("Uptime: " + std::to_string(uptime) + " seconds");
            logger.log("Dev Mode: " + std::string(config.dev_mode ? "enabled" : "disabled"));
            logger.log("Log Path: " + config.log_path);
            logger.log("Socket Path: " + config.socket_path);
            logger.log("==================");
            
            cycle_count = 0;
        }
        
        // Tu dodamy obsługę zdarzeń
    }

    void log_error(const std::string& error) {
        logger.error(error);
    }
};

// Globalna flaga dla sygnałów
std::atomic<bool> g_running{true};

void signal_handler(int) {
    g_running = false;
}

int main(int, char**) {
    try {
        PAMConfig config;
        #ifdef DEV_BUILD
        config.dev_mode = true;
        config.log_path = "/tmp/aegis_pam_dev.log";
        #endif

        AgentLogger logger(config.log_path, config.dev_mode);
        logger.log("Agent v" + std::string(AEGIS_VERSION) + " (" + BUILD_TYPE + " build) starting");
        
        // Rejestracja obsługi sygnałów
        signal(SIGTERM, signal_handler);
        signal(SIGINT, signal_handler);

        AegisAgent agent(config, g_running);
        
        while (g_running) {
            try {
                agent.process_events();
                std::this_thread::sleep_for(std::chrono::milliseconds(100));
            } catch (const std::exception& e) {
                agent.log_error(e.what());
            }
        }

        return 0;
    } catch (const std::exception& e) {
        syslog(LOG_ERR, "Aegis Agent fatal error: %s", e.what());
        return 1;
    }
}
