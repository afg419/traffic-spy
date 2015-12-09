require_relative '../test_helper'

class UrlAnalyticsTest < ModelTest

  def load_user_info(n)
    TrafficSpy::User.find_or_create_by("identifier"=>"identifier#{n}", "root_url"=>"http://root_url#{n}.com")
  end

  def load_user_payload(n, verb = "GET", response_time = 37)
    TrafficSpy::Payload.create({"url"=>"url#{n}",
                                "requested_at"=>"2013-02-16 21:38:28 -0700",
                                "responded_in"=>response_time,
                                "referred_by"=>"http://root_url#{n}.com",
                                "request_type"=>verb,
                                "event_name"=>"event_name#{n}",
                                "resolution_width"=>"1920",
                                "resolution_height"=>"1280",
                                "ip"=>"63.29.38.211",
                                "browser"=>"browser#{n}",
                                "platform"=>"platform#{n}"})
  end

  def associate_user_payload(n, verb = "GET", response_time = 37)
    load_user_info(n).payloads << load_user_payload(n, verb, response_time)
  end

  def test_we_can_access_a_specfic_users_payloads
    associate_user_payload(1)
    associate_user_payload(2)

    u1 = TrafficSpy::User.find_by(identifier: "identifier1")
    payload_1 = u1.payloads
    ip = payload_1.first.ip

    assert_equal "63.29.38.211", ip

    u2 = TrafficSpy::User.find_by(identifier: "identifier1")
    payload_2 = u2.payloads
    verb = payload_2.last.request_type

    assert_equal "GET", verb
  end

  def test_longest_response_time
    associate_user_payload(1)
    associate_user_payload(1, "GET", 60)
    associate_user_payload(1, "GET", 13)

    u = TrafficSpy::UrlAnalytics.new

    assert_equal 60, u.longest_response_time("identifier1")
  end

  def test_shortest_response_time

  end

  def test_average_response_time

  end

  def test_we_can_collect_http_verbs_that_have_been_used

  end

  def test_most_popular_referrers

  end

  def test_most_popular_user_agents

  end

end
