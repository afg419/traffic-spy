require_relative '../test_helper'

class UrlAnalyticsTest < ModelTest

  def load_user_info(n)
    TrafficSpy::User.find_or_create_by("identifier"=>"identifier#{n}", "root_url"=>"http://jumpstartlab.com")
  end

  def load_user_payload(n, verb = "GET", response_time = 37, referred_by = "http://jumpstartlab.com", browser="Chrome")
    TrafficSpy::Payload.create({"url"=>"url#{n}",
                                "requested_at"=>"2013-02-16 21:38:28 -0700",
                                "responded_in"=>response_time,
                                "referred_by"=>referred_by,
                                "request_type"=>verb,
                                "event_name"=>"event_name#{n}",
                                "resolution_width"=>"1920",
                                "resolution_height"=>"1280",
                                "ip"=>"63.29.38.211",
                                "browser"=>browser,
                                "platform"=>"platform#{n}"})
  end

  def associate_user_payload(n, verb = "GET", response_time = 37, referred_by = "http://jumpstartlab.com", browser="Chrome")
    load_user_info(n).payloads << load_user_payload(n, verb, response_time, referred_by, browser)
  end

  def test_we_can_access_a_specfic_users_payloads
    associate_user_payload(1)
    associate_user_payload(2)

    client_1 = TrafficSpy::User.find_by(identifier: "identifier1")
    payload_1 = client_1.payloads
    ip = payload_1.first.ip

    assert_equal "63.29.38.211", ip

    client_2 = TrafficSpy::User.find_by(identifier: "identifier1")
    payload_2 = client_2.payloads
    verb = payload_2.last.request_type

    assert_equal "GET", verb
  end

  def test_longest_response_time
    associate_user_payload(1)
    associate_user_payload(1, "GET", 60)
    associate_user_payload(1, "GET", 13)

    client_2 = TrafficSpy::UrlAnalytics.new

    assert_equal 60, client_2.longest_response_time("identifier1")
  end

  def test_shortest_response_time
    associate_user_payload(1)
    associate_user_payload(1, "GET", 60)
    associate_user_payload(1, "GET", 13)

    client = TrafficSpy::UrlAnalytics.new

    assert_equal 13, client.shortest_response_time("identifier1")
  end

  def test_average_response_time
    associate_user_payload(1)
    associate_user_payload(1, "GET", 60)
    associate_user_payload(1, "GET", 13)

    client = TrafficSpy::UrlAnalytics.new

    assert_equal 36.667, client.average_response_time("identifier1")
  end

  def test_we_can_collect_http_verbs_that_have_been_used
    associate_user_payload(1, "DELETE")
    associate_user_payload(1, "GET")
    associate_user_payload(1, "POST")

    client = TrafficSpy::UrlAnalytics.new

    assert_equal ["DELETE", "GET", "POST"], client.verbs_used("identifier1")
  end

  def test_most_popular_referrers_returns_top_3
    associate_user_payload(1, "GET", 37)
    associate_user_payload(1, "GET", 16)
    associate_user_payload(1, "GET", 44, "http://google.com")
    associate_user_payload(1, "GET", 45, "http://google.com")
    associate_user_payload(1, "GET", 46, "http://google.com")
    associate_user_payload(1, "GET", 47, "http://facebook.com")
    associate_user_payload(1, "GET", 48, "http://facebook.com")
    associate_user_payload(1, "GET", 5, "http://turing.io")

    client = TrafficSpy::UrlAnalytics.new

    assert_equal ["http://google.com", "http://facebook.com", "http://jumpstartlab.com"], client.most_popular_referrers("identifier1")
  end

  def test_most_popular_user_agents_returns_top_3_browsers
    associate_user_payload(1, "GET", 37, "url")
    associate_user_payload(1, "GET", 16, "url")
    associate_user_payload(1, "GET", 17, "url")
    associate_user_payload(1, "GET", 44, "url", "Firefox")
    associate_user_payload(1, "GET", 45, "url", "Firefox")
    associate_user_payload(1, "GET", 46, "url", "Firefox")
    associate_user_payload(1, "GET", 47, "url", "Firefox")
    associate_user_payload(1, "GET", 47, "url", "Safari")
    associate_user_payload(1, "GET", 48, "url", "Safari")
    associate_user_payload(1, "GET", 5, "url", "Internet Explorer")

    client = TrafficSpy::UrlAnalytics.new

    assert_equal ["Firefox", "Chrome", "Safari"], client.most_popular_user_agents("identifier1")
  end

end
