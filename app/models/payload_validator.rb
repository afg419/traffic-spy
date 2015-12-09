module TrafficSpy
  class PayloadValidator

    attr_accessor :status, :body

    include TrafficSpy::JSONRubyTranslator

    def column_names
      names = TrafficSpy::Payload.columns.map { |x| x.name }
      names.delete("id")
      names
    end

    def missing_attribute?(ruby_params) #or extra attribute
      # column_names.any?{ |name| !ruby_params.keys.include?(name)}
      !(ruby_params.keys.sort == column_names.sort)
    end

    def validate(ruby_params, identifier)
      if TrafficSpy::User.find_by(identifier: identifier)
        ruby_params["user_id"] = TrafficSpy::User.find_by(identifier: identifier).id

        payload = TrafficSpy::Payload.new(ruby_params)
        if payload.save
          self.status = 200
          self.body = "Success - 200 OK"
        elsif missing_attribute?(ruby_params)
          self.status = 400
          self.body = "Missing Payload - 400 Bad Request"
        else
          self.status = 403
          self.body = "Already Received Request - 403 Forbidden"
        end
      else
        self.status = 403
        self.body = "Application Not Registered - 403 Forbidden"
      end
    end
  end
end
