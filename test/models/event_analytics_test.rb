require_relative '../test_helper'

class EventAnalyticsTest < ModelTest
  def load_user_info(n)
    TrafficSpy::User.find_or_create_by({"identifier"=>"identifier#{n}", "root_url"=>"http://root_url#{n}.com"})
  end

  def load_user_payload(n, verb = "GET", datetime = "2013-02-16 21:38:28 -0700")
    TrafficSpy::Payload.create({"url"=>"url#{n}",
                                "requested_at"=>datetime,
                                "responded_in"=>37,
                                "referred_by"=>"http://root_url#{n}.com",
                                "request_type"=>verb,
                                "event_name"=>"event_name#{n}",
                                "resolution_width"=>"1920",
                                "resolution_height"=>"1280",
                                "ip"=>"63.29.38.211",
                                "browser"=>"browser#{n}",
                                "platform"=>"platform#{n}"})
  end

  def associate_user_payload(n, verb = "GET", datetime = "2013-02-16 21:38:28 -0700")
    n.times do |num|
      load_user_info(num).payloads << load_user_payload(num, verb, datetime)
    end
  end

  def test_event_returns_one_requested_time
    associate_user_payload(2)
    identifier = "identifier1"
    event = "event_name1"
    var = TrafficSpy::EventAnalytics.new
    assert_equal ["21:38:28"], var.find_event_times(identifier, event)
  end

  def test_event_returns_two_requested_time
    associate_user_payload(2)
    associate_user_payload(1, "GET",  "2013-02-16 20:38:28 -0700" )
    identifier = "identifier0"
    event = "event_name0"
    var = TrafficSpy::EventAnalytics.new
    time = ["20:38:28","21:38:28"]
    assert_equal time, var.find_event_times(identifier, event)
  end

end
