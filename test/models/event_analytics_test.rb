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

    var = TrafficSpy::EventAnalytics.new("identifier1", "event_name1")
    assert_equal ["21"], var.find_event_times
  end

  def test_event_returns_two_requested_time
    associate_user_payload(2)
    associate_user_payload(1, "GET",  "2013-02-16 20:38:28 -0700" )

    var = TrafficSpy::EventAnalytics.new("identifier0", "event_name0")
    time = ["20","21"]
    assert_equal time, var.find_event_times
  end

  def test_total_events_counts_total
    associate_user_payload(2)
    associate_user_payload(1, "GET",  "2013-02-16 01:38:28 -0700" )
    associate_user_payload(1, "GET",  "2013-02-16 05:38:28 -0700" )
    associate_user_payload(1, "GET",  "2013-02-16 12:38:28 -0700" )

    var = TrafficSpy::EventAnalytics.new("identifier0", "event_name0")

    assert_equal 4, var.total_events
  end

  def test_hourly_events_creates_hash
    associate_user_payload(2)
    associate_user_payload(1, "GET",  "2013-02-16 01:38:28 -0700" )
    associate_user_payload(1, "GET",  "2013-02-16 12:23:28 -0700" )

    var = TrafficSpy::EventAnalytics.new("identifier0", "event_name0")
    expected = {"01"=>1, "12"=>1, "21"=>1}

    assert_equal expected, var.hourly_events
  end

  def test_hourly_works_with_multiple_of_same_times
    associate_user_payload(4)
    associate_user_payload(1, "GET",  "2013-02-16 01:38:28 -0700" )
    associate_user_payload(1, "GET",  "2013-02-16 12:23:28 -0700" )
    associate_user_payload(1, "GET",  "2013-02-16 12:38:28 -0700" )
    associate_user_payload(1, "GET",  "2013-02-16 12:34:28 -0700" )
    associate_user_payload(1, "GET",  "2013-02-16 21:43:28 -0700" )

    var = TrafficSpy::EventAnalytics.new("identifier0", "event_name0")
    expected = {"01"=>1, "12"=>3, "21"=>2}

    assert_equal expected, var.hourly_events
  end
end
