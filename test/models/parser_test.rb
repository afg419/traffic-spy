require_relative '../test_helper'

class ParserTest < Minitest::Test

  def params
    {"payload"=>
      "{\"url\":\"http://jumpstartlab.com/blog\",
          \"requestedAt\":\"2013-02-16 21:38:28 -0700\",
          \"respondedIn\":37,
          \"referredBy\":\"http://jumpstartlab.com\",
          \"requestType\":\"GET\",
          \"parameters\":[],
          \"eventName\":\"socialLogin\",
          \"userAgent\":\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17\",
          \"resolutionWidth\":\"1920\",
          \"resolutionHeight\":\"1280\",
          \"ip\":\"63.29.38.211\"}",
     "splat"=>[],
     "captures"=>["jumpstartlab"],
     "identifier"=>"jumpstartlab"}
  end

  def params_without_agent
    {"payload"=>
      "{\"url\":\"http://jumpstartlab.com/blog\",
          \"requestedAt\":\"2013-02-16 21:38:28 -0700\",
          \"respondedIn\":37,
          \"referredBy\":\"http://jumpstartlab.com\",
          \"requestType\":\"GET\",
          \"parameters\":[],
          \"eventName\":\"socialLogin\",
          \"resolutionWidth\":\"1920\",
          \"resolutionHeight\":\"1280\",
          \"ip\":\"63.29.38.211\"}",
     "splat"=>[],
     "captures"=>["jumpstartlab"],
     "identifier"=>"jumpstartlab"}
  end

  # def params_with_agent_no_data
  #   {"payload"=>
  #     "{\"url\":\"http://jumpstartlab.com/blog\",
  #         \"requestedAt\":\"2013-02-16 21:38:28 -0700\",
  #         \"respondedIn\":37,
  #         \"referredBy\":\"http://jumpstartlab.com\",
  #         \"requestType\":\"GET\",
  #         \"parameters\":[],
  #         \"eventName\":\"socialLogin\",
  #         \"userAgent\":\"\",
  #         \"resolutionWidth\":\"1920\",
  #         \"resolutionHeight\":\"1280\",
  #         \"ip\":\"63.29.38.211\"}",
  #    "splat"=>[],
  #    "captures"=>["jumpstartlab"],
  #    "identifier"=>"jumpstartlab"}
  # end

  def test_module_exists
    assert Parser
  end

  def test_it_parses_params
    expected = {"url"=>"http://jumpstartlab.com/blog",
               "requested_at"=>"2013-02-16 21:38:28 -0700",
               "responded_in"=>37,
               "referred_by"=>"http://jumpstartlab.com",
               "request_type"=>"GET",
              #  "parameters"=>[],
               "event_name"=>"socialLogin",
               "resolution_width"=>"1920",
               "resolution_height"=>"1280",
               "ip"=>"63.29.38.211",
               "browser"=>"Chrome",
               "platform"=>"Macintosh"}
              #  "identifier"=>"jumpstartlab",
              #  "rootUrl"=>"jumpstartlab.com"}

    assert_equal expected, Parser.new.parse(params)
  end

  def test_it_parses_without_userAgent_data
    expected = {"url"=>"http://jumpstartlab.com/blog",
               "requested_at"=>"2013-02-16 21:38:28 -0700",
               "responded_in"=>37,
               "referred_by"=>"http://jumpstartlab.com",
               "request_type"=>"GET",
              #  "parameters"=>[],
               "event_name"=>"socialLogin",
               "resolution_width"=>"1920",
               "resolution_height"=>"1280",
               "ip"=>"63.29.38.211"}
    assert_equal expected, Parser.new.parse(params_without_agent)
  end
end
