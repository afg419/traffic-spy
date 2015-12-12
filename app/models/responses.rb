module TrafficSpy
  module Responses
    
    def registration_message_to_client(identifier)
      {
        :ok => "Success - 200 OK: User registered! {'identifier':'#{identifier}'}",
        :error_missing => "Missing Parameters - 400 Bad Request",
        :error_duplicate => "Identifier Already Exists - 403 Forbidden"
      }
    end

    def payload_message_to_client
      {
        :ok => "Success - 200 OK",
        :error_no_user => "Application Not Registered - 403 Forbidden",
        :error_missing => "Missing Payload - 400 Bad Request",
        :error_duplicate => "Already Received Request - 403 Forbidden"
      }
    end

    def response(status, message)
      self.status = status
      self.body = message
    end
  end
end
