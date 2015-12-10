require_relative '../test_helper'

class EventAnalyticsTest < ModelTest
  def load_user_info(n)
    TrafficSpy::User.find_or_create_by({"identifier"=>"identifier#{n}", "root_url"=>"http://root_url#{n}.com"})
  end

  def load_user_payload(n, verb = "GET", datetime = "2013-02-16 21:38:28 -0700")
    TrafficSpy::Payload.create({"url_id"=>10,
                                "requested_at"=>datetime,
                                "event_name"=>"event_name#{n}",
                                "resolution_width"=>"1920",
                                "resolution_height"=>"1280",
                                "ip"=>"63.29.38.211"})
  end

  def associate_user_payload(n, verb = "GET", datetime = "2013-02-16 21:38:28 -0700")
    n.times do |num|
      load_user_info(num).payloads << load_user_payload(num, verb, datetime)
    end
  end

  def test_event_returns_one_requested_time
    associate_user_payload(2)

    var = TrafficSpy::EventAnalytics.new("identifier1", "event_name1")
    assert_equal [21], var.find_event_times
  end

  def test_event_returns_two_requested_time
    associate_user_payload(2)
    associate_user_payload(1, "GET",  "2013-02-16 20:38:28 -0700" )

    var = TrafficSpy::EventAnalytics.new("identifier0", "event_name0")
    time = [20,21]
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
    expected = {1=>1, 2=>0, 3=>0, 4=>0, 5=>0, 6=>0, 7=>0, 8=>0, 9=>0, 10=>0, 11=>0, 12=>1, 13=>0, 14=>0, 15=>0, 16=>0, 17=>0, 18=>0, 19=>0, 20=>0, 21=>1, 22=>0, 23=>0, 24=>0}

    assert_equal expected, var.hour_creation
  end

  def test_hourly_works_with_multiple_of_same_times
    associate_user_payload(4)
    associate_user_payload(1, "GET",  "2013-02-16 01:38:28 -0700" )
    associate_user_payload(1, "GET",  "2013-02-16 12:23:28 -0700" )
    associate_user_payload(1, "GET",  "2013-02-16 12:38:28 -0700" )
    associate_user_payload(1, "GET",  "2013-02-16 12:34:28 -0700" )
    associate_user_payload(1, "GET",  "2013-02-16 21:43:28 -0700" )

    var = TrafficSpy::EventAnalytics.new("identifier0", "event_name0")
    expected = {1=>1, 2=>0, 3=>0, 4=>0, 5=>0, 6=>0, 7=>0, 8=>0, 9=>0, 10=>0, 11=>0, 12=>3, 13=>0, 14=>0, 15=>0, 16=>0, 17=>0, 18=>0, 19=>0, 20=>0, 21=>2, 22=>0, 23=>0, 24=>0}

    assert_equal expected, var.hour_creation
  end

  def test_hour_edits_to_having_am_and_pm
    associate_user_payload(4)
    associate_user_payload(1, "GET",  "2013-02-16 01:38:28 -0700" )
    associate_user_payload(1, "GET",  "2013-02-16 12:23:28 -0700" )
    associate_user_payload(1, "GET",  "2013-02-16 12:38:28 -0700" )
    associate_user_payload(1, "GET",  "2013-02-16 12:34:28 -0700" )
    associate_user_payload(1, "GET",  "2013-02-16 21:43:28 -0700" )

    var = TrafficSpy::EventAnalytics.new("identifier0", "event_name0")
    expected = {"1 am"=>1, "2 am"=>0, "3 am"=>0, "4 am"=>0, "5 am"=>0, "6 am"=>0, "7 am"=>0, "8 am"=>0, "9 am"=>0, "10 am"=>0, "11 am"=>0, "12 am"=>3, "1 pm"=>0, "2 pm"=>0, "3 pm"=>0, "4 pm"=>0, "5 pm"=>0, "6 pm"=>0, "7 pm"=>0, "8 pm"=>0, "9 pm"=>2, "10 pm"=>0, "11 pm"=>0, "12 pm"=>0}

    assert_equal expected, var.hour_edited
    assert_equal 3, var.hour_edited["12 am"]
  end
end
