module TrafficSpy
  class PayloadValidator

    attr_accessor :status, :body

    include TrafficSpy::JSONRubyTranslator

    def insert_or_error_status(ruby_params, identifier)
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
        DbLoader.new(ruby_params,identifier).load_databases

        # payload_params = ruby_params.select{|k,v| payload_columns.include?(k)}
        # url_params = ruby_params.select{|k,v| url_columns.include?(k)}
        # ruby_params_loadable = payload_params.merge({"url" => Url.find_or_create_by(url_params)})
        # user = User.find_by(identifier: identifier)
        # user.payloads.create(ruby_params_loadable)

        self.status = 200
        self.body = "Success - 200 OK"
      end
    end
    #
    # def ruby_params
    #   { event: Event.find_or_create_by(),
    #   { url: Url.find_or_create_by(),
    #     requested_at: params["requestedAt"]}
    # end

    def duplicate_data?(ruby_params)
      TrafficSpy::Payload.find_by("payload_sha" => ruby_params["payload_sha"])
    end

    def no_user?(ruby_params,identifier)
      TrafficSpy::User.find_by(identifier: identifier).nil?
    end

    def missing_or_extra_attribute?(ruby_params)
      keys = ruby_params.keys
      keys.delete("user_id")
      !(keys.sort == column_names.sort)
    end

    def payload_columns
      TrafficSpy::Payload.columns.map { |x| x.name }
    end

    def url_columns
      TrafficSpy::Url.columns.map {|x| x.name}
    end

    def column_names
      names = payload_columns + url_columns
      names.reject{|x| x == "id" || x == "url_id" || x == "user_id"}
    end

    def prep_sha(ruby_params)
      sha = Digest::SHA1.hexdigest(ruby_params.values.join)
      ruby_params.merge({"payload_sha" => sha})
    end
  end
end
