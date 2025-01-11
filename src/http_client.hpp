#pragma once
#include <Poco/Net/HTTPClientSession.h>
#include <Poco/Net/HTTPRequest.h>
#include <Poco/Net/HTTPResponse.h>
#include <Poco/URI.h>
#include <string>
#include <syslog.h>

class HttpClient {
public:
    static bool sendPamRecord(const std::string& username, const std::string& event, const std::string& endpoint) {
        try {
            Poco::URI uri(endpoint);
            Poco::Net::HTTPClientSession session(uri.getHost(), uri.getPort());
            
            Poco::Net::HTTPRequest request(Poco::Net::HTTPRequest::HTTP_POST, 
                                         uri.getPathAndQuery(),
                                         Poco::Net::HTTPMessage::HTTP_1_1);
            
            std::string payload = "{\"username\":\"" + username + 
                                "\",\"event\":\"" + event + "\"}";
            
            request.setContentType("application/json");
            request.setContentLength(payload.length());
            
            std::ostream& os = session.sendRequest(request);
            os << payload;
            
            Poco::Net::HTTPResponse response;
            session.receiveResponse(response);
            
            return response.getStatus() == Poco::Net::HTTPResponse::HTTP_OK;
        }
        catch (const std::exception& e) {
            syslog(LOG_AUTH|LOG_ERR, "HTTP request failed: %s", e.what());
            return false;
        }
    }
}; 