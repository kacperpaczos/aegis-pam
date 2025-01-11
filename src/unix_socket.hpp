#pragma once
#include <string>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <stdexcept>

class UnixSocket {
private:
    int sock_fd;
    std::string socket_path;
    bool is_server;

public:
    UnixSocket(const std::string& path, bool server_mode = false) 
        : socket_path(path), is_server(server_mode) {
        sock_fd = socket(AF_UNIX, SOCK_DGRAM, 0);
        if (sock_fd == -1) {
            throw std::runtime_error("Failed to create socket");
        }

        if (is_server) {
            struct sockaddr_un addr;
            memset(&addr, 0, sizeof(addr));
            addr.sun_family = AF_UNIX;
            strncpy(addr.sun_path, socket_path.c_str(), sizeof(addr.sun_path)-1);

            if (bind(sock_fd, (struct sockaddr*)&addr, sizeof(addr)) == -1) {
                close(sock_fd);
                throw std::runtime_error("Failed to bind socket");
            }
        }
    }

    void send(const std::string& message) {
        struct sockaddr_un addr;
        memset(&addr, 0, sizeof(addr));
        addr.sun_family = AF_UNIX;
        strncpy(addr.sun_path, socket_path.c_str(), sizeof(addr.sun_path)-1);

        if (sendto(sock_fd, message.c_str(), message.length(), 0,
                  (struct sockaddr*)&addr, sizeof(addr)) == -1) {
            throw std::runtime_error("Failed to send message");
        }
    }

    std::string receive() {
        char buffer[1024];
        struct sockaddr_un sender;
        socklen_t sender_len = sizeof(sender);
        
        ssize_t bytes = recvfrom(sock_fd, buffer, sizeof(buffer)-1, 0,
                                (struct sockaddr*)&sender, &sender_len);
        
        if (bytes > 0) {
            buffer[bytes] = '\0';
            return std::string(buffer);
        }
        return "";
    }

    ~UnixSocket() {
        if (sock_fd != -1) {
            close(sock_fd);
        }
    }
}; 