require 'JSON'
require 'useragent'

module TrafficSpy
  class Parser

    def parse(params)
      raw_data = JSON.parse(params["payload"])
      raw_data = user_agent_parsing(raw_data) if raw_data["userAgent"]
      raw_data.delete("parameters")
      prep_for_table_column_names(raw_data)
    end

    def user_agent_parsing(parsed)
      agent = UserAgent.parse(parsed["userAgent"])
      parsed.delete("userAgent")
      parsed["browser"] = agent.browser
      parsed["platform"] = agent.platform
      parsed
    end


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
      "userId"].zip(
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
       "user_id"]).to_h
    end
  end
end

# user_agent.browser
# # => 'Chrome'
# user_agent.version
# # => '19.0.1084.56'
# user_agent.platform

# {"payload"=>
#   "{\"url\":\"http://jumpstartlab.com/blog\",
#       \"requestedAt\":\"2013-02-16 21:38:28 -0700\",
#       \"respondedIn\":37,
#       \"referredBy\":\"http://jumpstartlab.com\",
#       \"requestType\":\"GET\",
#       \"parameters\":[],
#       \"eventName\":\"socialLogin\",
#       \"userAgent\":\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17\",
#       \"resolutionWidth\":\"1920\",
#       \"resolutionHeight\":\"1280\",
#       \"ip\":\"63.29.38.211\"}",
#  "splat"=>[],
#  "captures"=>["jumpstartlab"],
#  "identifier"=>"jumpstartlab"}
