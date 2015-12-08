require_relative '../test_helper'

class LoadPayloadTest < ControllerTest

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

  def test_loads_valid_payload_data
    initial_count = TrafficSpy::Payload.count
    post '/sources/jumpstartlab/data', params
    final_count = TrafficSpy::Payload.count

    assert_equal 1, final_count - initial_count
  end

end
