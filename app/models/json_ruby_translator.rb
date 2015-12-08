module TrafficSpy
  module JSONRubyTranslator

    def prep_for_table_column_names(raw_data)
      raw_data.map do |key, value|
        [json_ruby_translator[key],value]
      end.to_h
    end


    def json_ruby_translator
      ["url",
      "requestedAt",
      "respondedIn",
      "referredBy",
      "requestType",
      "eventName",
      "resolutionWidth",
      "resolutionHeight",
      "ip",
      "browser",
      "platform",
      "userId","rootUrl","identifier"].zip(
      ["url",
       "requested_at",
       "responded_in",
       "referred_by",
       "request_type",
       "event_name",
       "resolution_width",
       "resolution_height",
       "ip",
       "browser",
       "platform",
       "user_id","root_url","identifier"]).to_h
    end

  end
end
