require_relative 'responses'

module TrafficSpy
  class PayloadValidator

    attr_accessor :status, :body

    include TrafficSpy::JSONRubyTranslator
    include TrafficSpy::Responses

    def insert_or_error_status(ruby_params, identifier)
      ruby_params = prep_sha(ruby_params)
      if no_user?(ruby_params, identifier)
        response(403, payload_message_to_client[:error_no_user] )
      elsif missing_or_extra_attribute?(ruby_params)
        response(400, payload_message_to_client[:error_missing])
      elsif duplicate_data?(ruby_params)
        response(403, payload_message_to_client[:error_duplicate])
      else
        DbLoader.new(ruby_params,identifier).load_databases
        response(200, payload_message_to_client[:ok])
      end
    end

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
