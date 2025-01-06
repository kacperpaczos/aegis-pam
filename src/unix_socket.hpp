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

public:
    UnixSocket(const std::string& path) : socket_path(path) {
        sock_fd = socket(AF_UNIX, SOCK_DGRAM, 0);
        if (sock_fd == -1) {
            throw std::runtime_error("Failed to create socket");
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

    ~UnixSocket() {
        if (sock_fd != -1) {
            close(sock_fd);
        }
    }
}; 