module TrafficSpy
  class UserValidator

    include TrafficSpy::JSONRubyTranslator
    include TrafficSpy::Responses

    attr_accessor :status, :body

    def validate(params)
      ruby_params = change_attributes_to_match_table_column_names(params)
      user = TrafficSpy::User.new(ruby_params)
      id = ruby_params['identifier']
      if user.save
        response(200, registration_message_to_client(id)[:ok])
      elsif
        id.nil? || ruby_params["root_url"].nil?
        response(400, registration_message_to_client(id)[:error_missing])
      else
        response(403,registration_message_to_client(id)[:error_duplicate])
      end
    end

  end
end
