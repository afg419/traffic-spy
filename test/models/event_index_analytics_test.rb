require_relative '../test_helper'

class EventIndexAnalyticsTest < ModelTest

  def load_user_info(m)
    TrafficSpy::User.find_or_create_by("identifier"=>"identifier#{m}", "root_url"=>"http://jumpstartlab.com")
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
                                "platform"=>"platform#{n}",
                                "payload_sha"=>"#{rand(0..1000)}"})
  end

  def associate_user_payload(m, n, verb = "GET", response_time = 37, referred_by = "http://jumpstartlab.com", browser="Chrome")
    load_user_info(m).payloads << load_user_payload(n, verb, response_time, referred_by, browser)
  end

  def test_returns_events_by_popularity
    associate_user_payload(0,0)
    associate_user_payload(0,0)
    associate_user_payload(0,0)
    associate_user_payload(0,1)
    associate_user_payload(0,2)
    associate_user_payload(0,2)

    returned = TrafficSpy::EventIndexAnalytics.new.events_by_popularity("identifier0")

    assert_equal ["event_name#{0}","event_name#{2}","event_name#{1}"], returned
  end

  def test_returns_events_by_popularity_multiple_users
    associate_user_payload(2,0)
    associate_user_payload(2,1)
    associate_user_payload(2,2)
    associate_user_payload(2,2)

    associate_user_payload(0,0)
    associate_user_payload(0,0)
    associate_user_payload(0,0)
    associate_user_payload(0,1)
    associate_user_payload(0,2)
    associate_user_payload(0,2)

    associate_user_payload(1,0)
    associate_user_payload(1,0)
    associate_user_payload(1,2)

    returned0 = TrafficSpy::EventIndexAnalytics.new.events_by_popularity("identifier0")
    returned1 = TrafficSpy::EventIndexAnalytics.new.events_by_popularity("identifier1")
    returned2 = TrafficSpy::EventIndexAnalytics.new.events_by_popularity("identifier2")

    assert_equal ["event_name#{0}","event_name#{2}","event_name#{1}"], returned0
    assert_equal ["event_name#{0}","event_name#{2}"],                  returned1
    assert_equal ["event_name#{2}","event_name#{0}","event_name#{1}"], returned2

  end
end
