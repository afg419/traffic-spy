require_relative '../test_helper'

class UrlAnalyticsTest < ModelTest

  def load_user_info(n)
    TrafficSpy::User.find_or_create_by("identifier"=>"identifier#{n}", "root_url"=>"http://jumpstartlab.com")
  end

  def payload_data
    {
      "requested_at"=>"NOW",
      "event_name"=>"event_name",
      "resolution_width"=>"1920",
      "resolution_height"=>"1280",
      "ip"=>"63.29.38.211",
      "payload_sha"=>"953829399845098230498130948"
    }
  end

  def load_user_url(n, verb = "GET", response_time = 37, referred_by = "http://jumpstartlab.com", browser="Chrome")
    payload_data.merge(url: TrafficSpy::Url.create({"url"=>"url#{n}",
                                "responded_in"=>response_time,
                                "referred_by"=>referred_by,
                                "request_type"=>verb,
                                "browser"=>browser,
                                "platform"=>"platform#{n}"}))
  end

  def associate_user_url(n, verb = "GET", response_time = 37, referred_by = "http://jumpstartlab.com", browser="Chrome")
    load_user_info(n).payloads.create(load_user_url(n,verb,response_time,referred_by,browser))
    #  << load_user_payload(n, verb, response_time, referred_by, browser)
  end

  def test_we_can_access_a_specfic_users_url
    associate_user_url(1)
    associate_user_url(2, "POST")

    client_1 = TrafficSpy::User.find_by(identifier: "identifier1")
    url_1 = client_1.urls
    platform = url_1.first.platform

    assert_equal "platform1", platform

    client_2 = TrafficSpy::User.find_by(identifier: "identifier2")
    url_2 = client_2.urls
    verb = url_2.last.request_type

    assert_equal "POST", verb
  end
#
  def test_longest_response_time
    associate_user_url(1)
    associate_user_url(1, "GET", 60)
    associate_user_url(1, "GET", 13)

    client_2 = TrafficSpy::UrlAnalytics.new

    assert_equal 60, client_2.longest_response_time("identifier1")
  end

  def test_shortest_response_time
    associate_user_url(1)
    associate_user_url(1, "GET", 60)
    associate_user_url(1, "GET", 13)

    client = TrafficSpy::UrlAnalytics.new

    assert_equal 13, client.shortest_response_time("identifier1")
  end

  def test_average_response_time
    associate_user_url(1)
    associate_user_url(1, "GET", 60)
    associate_user_url(1, "GET", 13)

    client = TrafficSpy::UrlAnalytics.new

    assert_equal 36.667, client.average_response_time("identifier1")
  end

  def test_we_can_collect_http_verbs_that_have_been_used
    associate_user_url(1, "DELETE")
    associate_user_url(1, "GET")
    associate_user_url(1, "POST")

    client = TrafficSpy::UrlAnalytics.new

    assert_equal ["DELETE", "GET", "POST"], client.verbs_used("identifier1")
  end

  def test_most_popular_referrers_returns_top_3
    associate_user_url(1, "GET", 37)
    associate_user_url(1, "GET", 16)
    associate_user_url(1, "GET", 44, "http://google.com")
    associate_user_url(1, "GET", 45, "http://google.com")
    associate_user_url(1, "GET", 46, "http://google.com")
    associate_user_url(1, "GET", 47, "http://facebook.com")
    associate_user_url(1, "GET", 48, "http://facebook.com")
    associate_user_url(1, "GET", 5, "http://turing.io")

    client = TrafficSpy::UrlAnalytics.new

    assert_equal ["http://google.com", "http://facebook.com", "http://jumpstartlab.com"], client.most_popular_referrers("identifier1")
  end

  def test_most_popular_user_agents_returns_top_3_browsers
    associate_user_url(1, "GET", 37, "url")
    associate_user_url(1, "GET", 16, "url")
    associate_user_url(1, "GET", 17, "url")
    associate_user_url(1, "GET", 44, "url", "Firefox")
    associate_user_url(1, "GET", 45, "url", "Firefox")
    associate_user_url(1, "GET", 46, "url", "Firefox")
    associate_user_url(1, "GET", 47, "url", "Firefox")
    associate_user_url(1, "GET", 47, "url", "Safari")
    associate_user_url(1, "GET", 48, "url", "Safari")
    associate_user_url(1, "GET", 5, "url", "Internet Explorer")

    client = TrafficSpy::UrlAnalytics.new

    assert_equal ["Firefox", "Chrome", "Safari"], client.most_popular_user_agents("identifier1")
  end

end
