require 'JSON'
require 'useragent'

class Parser

  def parse(params)
    parsed = JSON.parse(params["payload"])
    parsed = user_agent_parsing(parsed) if parsed["userAgent"]
    parsed.delete("parameters")
    parsed
  end

  def user_agent_parsing(parsed)
    agent = UserAgent.parse(parsed["userAgent"])
    parsed.delete("userAgent")
    parsed["browser"] = agent.browser
    parsed["platform"] = agent.platform
    parsed
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
