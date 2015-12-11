require 'JSON'
require 'useragent'

module TrafficSpy
  class Parser
    include TrafficSpy::JSONRubyTranslator

    def parse(params)
      raw_data = JSON.parse(params["payload"])
      raw_data = user_agent_parsing(raw_data) if raw_data["userAgent"]
      raw_data.delete("parameters")
      raw_data["url"] = raw_data["url"].split('/')[3..-1].join('/')
      prep_for_table_column_names(raw_data)
    end

    def user_agent_parsing(parsed)
      agent = UserAgent.parse(parsed["userAgent"])
      parsed.delete("userAgent")
      parsed.merge({"browser" => agent.browser, "platform" => agent.platform})
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
