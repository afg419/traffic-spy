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

  def bad_params
    {"payload"=>
      "{\"url\":\"http://jumpstartlab.com/blog\",
          \"requestedAt\":\"2013-02-16 21:38:28 -0700\",
          \"respondedIn\":37,
          \"referredBy\":\"http://jumpstartlab.com\",
          \"parameters\":[],
          \"eventName\":\"socialLogin\",
          \"userAgent\":\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17\",
          \"resolutionHeight\":\"1280\",
          \"ip\":\"63.29.38.211\"}",
     "splat"=>[],
     "captures"=>["jumpstartlab"],
     "identifier"=>"jumpstartlab"}
  end

  def user_info
    registration = {"identifier"=>"jumpstartlab", "rootUrl"=>"http://jumpstartlab.com"}
    validator = TrafficSpy::UserValidator.new
    validator.validate(registration)
  end

  def test_loads_valid_payload_data_and_returns_correct_responses
    user_info

    initial_count = TrafficSpy::Payload.count
    post '/sources/jumpstartlab/data', params
    final_count = TrafficSpy::Payload.count

    assert_equal 1, (final_count - initial_count)
    assert_equal 200, last_response.status
    assert_equal "Success - 200 OK", last_response.body
  end

  def test_server_returns_correct_messages_for_missing_payload
    user_info

    initial_count = TrafficSpy::Payload.count
    post '/sources/jumpstartlab/data', bad_params
    final_count = TrafficSpy::Payload.count

    assert_equal 0, (final_count - initial_count)
    assert_equal 400, last_response.status
    assert_equal "Missing Payload - 400 Bad Request", last_response.body
  end

  def test_server_returns_correct_messages_if_request_payload_has_already_been_received
    user_info

    initial_count = TrafficSpy::Payload.count
    post '/sources/jumpstartlab/data', params
    post '/sources/jumpstartlab/data', params
    final_count = TrafficSpy::Payload.count

    assert_equal 1, (final_count - initial_count)
    assert_equal 403, last_response.status
    assert_equal "Already Received Request - 403 Forbidden", last_response.body
  end

  def test_server_returns_correct_messages_if_data_is_submitted_to_an_application_url_that_does_not_exist
    user_info

    initial_count = TrafficSpy::Payload.count
    post '/sources/blabblabity/data', params
    final_count = TrafficSpy::Payload.count

    assert_equal 0, (final_count - initial_count)
    assert_equal 403, last_response.status
    assert_equal "Application Not Registered - 403 Forbidden", last_response.body
  end

end
