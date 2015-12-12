require 'JSON'
require 'useragent'

module TrafficSpy
  class Parser
    include TrafficSpy::JSONRubyTranslator

    def parse(params)
      raw_data = JSON.parse(params["payload"])
      raw_data.delete("parameters")
      raw_data = replace_agent_with_browser_and_platorm(raw_data) if raw_data["userAgent"]
      raw_data["url"] = local_url(raw_data)
      change_attributes_to_match_table_column_names(raw_data)
    end

    def local_url(data)
      data["url"].split('/')[3..-1].join('/')
    end

    def replace_agent_with_browser_and_platorm(data)
      agent = UserAgent.parse(data["userAgent"])
      data.delete("userAgent")
      data.merge({"browser" => agent.browser, "platform" => agent.platform})
    end
  end
end
