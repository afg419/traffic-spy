require_relative '../test_helper'

class ParserTest < Minitest::Test
  def test_module_exists
    assert TrafficSpy::Parser
  end

  def test_it_removes_parameters_attribute
    params = {"payload"=>
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

    refute TrafficSpy::Parser.new.parse(params)["parameters"]
  end

  def test_it_extracts_local_url_with_multi_slashes
    params = {"payload"=>
              "{\"url\":\"http://jumpstartlab.com/blog/article/team\",
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

    assert_equal "blog/article/team", TrafficSpy::Parser.new.parse(params)["url"]
  end

  def test_it_parses_params_with_correct_column_names
    params = {"payload"=>
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

    expected = {"url"=>"blog",
               "requested_at"=>"2013-02-16 21:38:28 -0700",
               "responded_in"=>37,
               "referred_by"=>"http://jumpstartlab.com",
               "request_type"=>"GET",
               "event_name"=>"socialLogin",
               "resolution_width"=>"1920",
               "resolution_height"=>"1280",
               "ip"=>"63.29.38.211",
               "browser"=>"Chrome",
               "platform"=>"Macintosh"}

    assert_equal expected, TrafficSpy::Parser.new.parse(params)
  end

  def test_it_parses_without_userAgent_data
    params_without_agent = {"payload"=>
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

    expected = {"url"=>"blog",
               "requested_at"=>"2013-02-16 21:38:28 -0700",
               "responded_in"=>37,
               "referred_by"=>"http://jumpstartlab.com",
               "request_type"=>"GET",
               "event_name"=>"socialLogin",
               "resolution_width"=>"1920",
               "resolution_height"=>"1280",
               "ip"=>"63.29.38.211"}

    assert_equal expected, TrafficSpy::Parser.new.parse(params_without_agent)
  end

  def test_it_deletes_wrong_keys
    params_wrong_keys = {"payload"=>
                        "{\"url\":\"http://jumpstartlab.com/blog\",
                            \"requAGHedAt\":\"2013-02-16 21:38:28 -0700\",
                            \"respondedIn\":37,
                            \"refFFFerredBy\":\"http://jumpstartlab.com\",
                            \"requestType\":\"GET\",
                            \"parameters\":[],
                            \"eventName\":\"socialLogin\",
                            \"resolutionWidth\":\"1920\",
                            \"resolutionHeight\":\"1280\",
                            \"ip\":\"63.29.38.211\"}",
                       "splat"=>[],
                       "captures"=>["jumpstartlab"],
                       "identifier"=>"jumpstartlab"}

    expected = {"url"=>"blog",
               "responded_in"=>37,
               "request_type"=>"GET",
               "event_name"=>"socialLogin",
               "resolution_width"=>"1920",
               "resolution_height"=>"1280",
               "ip"=>"63.29.38.211"}

    assert_equal expected, TrafficSpy::Parser.new.parse(params_wrong_keys)
  end
end
