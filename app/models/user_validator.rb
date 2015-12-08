module TrafficSpy
  class UserValidator

    include TrafficSpy::JSONRubyTranslator

    attr_accessor :status, :body

    def validate(params)
      ruby_params = prep_for_table_column_names(params)
      user = TrafficSpy::User.new(ruby_params)
      if user.save
        self.status = 200
        self.body = "Success - 200 OK: User registered! {'identifier':'#{params[:identifier]}'}"
      elsif
        params[:identifier].nil? || params[:rootUrl].nil?
        self.status = 400
        self.body = "Missing Parameters - 400 Bad Request"
      else
        self.status = 403
        self.body = "Identifier Already Exists - 403 Forbidden"
      end
    end
  end
end
