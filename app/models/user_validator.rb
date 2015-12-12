module TrafficSpy
  class UserValidator

    include TrafficSpy::JSONRubyTranslator

    attr_accessor :status, :body

    def validate(params)
      ruby_params = change_attributes_to_match_table_column_names(params)
      user = TrafficSpy::User.new(ruby_params)
      id = ruby_params['identifier']
      if user.save
        response(200, message_to_client(id)[:ok])
      elsif
        id.nil? || ruby_params["root_url"].nil?
        response(400, message_to_client(id)[:error_missing])
      else
        response(403,message_to_client(id)[:error_duplicate])
      end
    end

    def message_to_client(identifier)
      {
        :ok => "Success - 200 OK: User registered! {'identifier':'#{identifier}'}",
        :error_missing => "Missing Parameters - 400 Bad Request",
        :error_duplicate => "Identifier Already Exists - 403 Forbidden"
      }
    end

    def response(status, message)
      self.status = status
      self.body = message
    end
  end
end
