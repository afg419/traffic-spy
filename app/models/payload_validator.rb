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
      !(ruby_params.keys.sort == column_names.sort)
    end

    def validate(ruby_params, identifier)
      validate_or_insert(ruby_params,identifier)
      # if TrafficSpy::User.find_by(identifier: identifier)
      #   ruby_params["user_id"] = TrafficSpy::User.find_by(identifier: identifier).id
      #   determine_user_payload_status(ruby_params)
      # else
      #   self.status = 403
      #   self.body = "Application Not Registered - 403 Forbidden"
      # end
    end

    def determine_user_payload_status(ruby_params)
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
    end

    def prep_sha(ruby_params)
      sha = Digest::SHA1.hexdigest(ruby_params.values.join)
      ruby_params.merge({"payload_sha" => sha})
    end

    def validate_or_insert(ruby_params, identifier)
      ruby_params = prep_sha(ruby_params)
      if no_user?(ruby_params,identifier)
        self.status = 403
        self.body = "Application Not Registered - 403 Forbidden"
      elsif missing_or_extra_attribute?(ruby_params)
        self.status = 400
        self.body = "Missing Payload - 400 Bad Request"
      elsif duplicate_data?(ruby_params)
        self.status = 403
        self.body = "Already Received Request - 403 Forbidden"
      else
        TrafficSpy::Payload.create(ruby_params)
        self.status = 200
        self.body = "Success - 200 OK"
      end
    end

    def duplicate_data?(ruby_params)
      TrafficSpy::Payload.find_by("payload_sha" => ruby_params["payload_sha"])
    end

    def no_user?(ruby_params,identifier)
      TrafficSpy::User.find_by(identifier: identifier).nil?
    end

    def missing_or_extra_attribute?(ruby_params)
      columns = column_names
      columns.delete("user_id")
      keys = ruby_params.keys
      keys.delete("user_id")
      !(keys.sort == columns.sort)
    end


  end
end
