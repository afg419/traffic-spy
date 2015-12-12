require_relative '../test_helper'

class PayloadTest < ModelTest

  def load_user_info(n)
    TrafficSpy::User.find_or_create_by({"identifier"=>"identifier#{n}", "root_url"=>"http://root_url#{n}.com"})
  end

  def load_user_payload(n, verb = "GET", datetime = "2013-02-16 21:38:28 -0700")
    TrafficSpy::Payload.create({"url_id"=>10,
                                "requested_at"=> datetime,
                                "event_name"=>"event_name#{n}",
                                "resolution_width"=>"1920",
                                "resolution_height"=>"1280",
                                "ip"=>"63.29.38.211"})
  end

  def associate_user_payload(m, n)
    load_user_info(m).payloads << load_user_payload(n)
  end

  def associate_user_payloads(n, verb = "GET", datetime = "2013-02-16 21:38:28 -0700")
    n.times do |num|
      load_user_info(num).payloads << load_user_payload(num, verb, datetime)
    end
  end

  def load_database_tables(n, responded_in, url = "blog", browser = "Chrome", operating_system = "Macintosh", resolution_width = "1920", resolution_height = "1280")
    load_user_info(n)
    TrafficSpy::DbLoader.new({"url"=> url,
               "requested_at"=>"2013-02-16 21:38:28 -0700",
               "responded_in"=> responded_in,
               "referred_by"=>"http://jumpstartlab.com",
               "request_type"=>"GET",
               "event_name"=>"socialLogin",
               "resolution_width"=> resolution_width,
               "resolution_height"=> resolution_height,
               "ip"=>"63.29.38.211",
               "user_id"=>1,
               "browser"=> browser,
               "platform"=> operating_system,
               "payload_sha" => "12489809850939491939823"}, "identifier#{n}").load_databases
  end

  def test_event_returns_one_requested_time
    associate_user_payloads(2)

    user = TrafficSpy::User.find_by(identifier: "identifier1")

    assert_equal [21], user.payloads.find_event_times("event_name1")
  end

  def test_event_returns_two_requested_time
    associate_user_payloads(2)
    associate_user_payloads(1, "GET",  "2013-02-16 20:38:28 -0700" )

    user = TrafficSpy::User.find_by(identifier: "identifier0")
    time = [21,20]
    assert_equal time, user.payloads.find_event_times("event_name0")
  end

  def test_total_events_counts_total
    associate_user_payloads(2)
    associate_user_payloads(1, "GET",  "2013-02-16 01:38:28 -0700" )
    associate_user_payloads(1, "GET",  "2013-02-16 05:38:28 -0700" )
    associate_user_payloads(1, "GET",  "2013-02-16 12:38:28 -0700" )

    user = TrafficSpy::User.find_by(identifier: "identifier0")

    assert_equal 4, user.payloads.total_events("event_name0")
  end

  def test_hourly_events_creates_hash
    associate_user_payloads(2)
    associate_user_payloads(1, "GET",  "2013-02-16 01:38:28 -0700" )
    associate_user_payloads(1, "GET",  "2013-02-16 12:23:28 -0700" )

    user = TrafficSpy::User.find_by(identifier: "identifier0")
    expected = {1=>1, 2=>0, 3=>0, 4=>0, 5=>0, 6=>0, 7=>0, 8=>0, 9=>0, 10=>0, 11=>0, 12=>1, 13=>0, 14=>0, 15=>0, 16=>0, 17=>0, 18=>0, 19=>0, 20=>0, 21=>1, 22=>0, 23=>0, 24=>0}

    assert_equal expected, user.payloads.hour_creation("event_name0")
  end

  def test_hourly_works_with_multiple_of_same_times
    associate_user_payloads(4)
    associate_user_payloads(1, "GET",  "2013-02-16 01:38:28 -0700" )
    associate_user_payloads(1, "GET",  "2013-02-16 12:23:28 -0700" )
    associate_user_payloads(1, "GET",  "2013-02-16 12:38:28 -0700" )
    associate_user_payloads(1, "GET",  "2013-02-16 12:34:28 -0700" )
    associate_user_payloads(1, "GET",  "2013-02-16 21:43:28 -0700" )

    user = TrafficSpy::User.find_by(identifier: "identifier0")
    expected = {1=>1, 2=>0, 3=>0, 4=>0, 5=>0, 6=>0, 7=>0, 8=>0, 9=>0, 10=>0, 11=>0, 12=>3, 13=>0, 14=>0, 15=>0, 16=>0, 17=>0, 18=>0, 19=>0, 20=>0, 21=>2, 22=>0, 23=>0, 24=>0}

    assert_equal expected, user.payloads.hour_creation("event_name0")
  end

  def test_hour_edits_to_having_am_and_pm
    associate_user_payloads(4)
    associate_user_payloads(1, "GET",  "2013-02-16 01:38:28 -0700" )
    associate_user_payloads(1, "GET",  "2013-02-16 12:23:28 -0700" )
    associate_user_payloads(1, "GET",  "2013-02-16 12:38:28 -0700" )
    associate_user_payloads(1, "GET",  "2013-02-16 12:34:28 -0700" )
    associate_user_payloads(1, "GET",  "2013-02-16 21:43:28 -0700" )

    user = TrafficSpy::User.find_by(identifier: "identifier0")
    expected = {"1 am"=>1, "2 am"=>0, "3 am"=>0, "4 am"=>0, "5 am"=>0, "6 am"=>0, "7 am"=>0, "8 am"=>0, "9 am"=>0, "10 am"=>0, "11 am"=>0, "12 am"=>3, "1 pm"=>0, "2 pm"=>0, "3 pm"=>0, "4 pm"=>0, "5 pm"=>0, "6 pm"=>0, "7 pm"=>0, "8 pm"=>0, "9 pm"=>2, "10 pm"=>0, "11 pm"=>0, "12 pm"=>0}

    assert_equal expected, user.payloads.hour_edited("event_name0")
    assert_equal 3, user.payloads.hour_edited("event_name0")["12 am"]
  end

  def test_returns_events_by_popularity
    associate_user_payload(0,0)
    associate_user_payload(0,0)
    associate_user_payload(0,0)
    associate_user_payload(0,1)
    associate_user_payload(0,2)
    associate_user_payload(0,2)
    user = TrafficSpy::User.find_by(identifier: "identifier0")
    returned = user.payloads.events_by_popularity

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

    user0 = TrafficSpy::User.find_by(identifier: "identifier0")
    user1 = TrafficSpy::User.find_by(identifier: "identifier1")
    user2 = TrafficSpy::User.find_by(identifier: "identifier2")

    returned0 = user0.payloads.events_by_popularity
    returned1 = user1.payloads.events_by_popularity
    returned2 = user2.payloads.events_by_popularity

    assert_equal ["event_name#{0}","event_name#{2}","event_name#{1}"], returned0
    assert_equal ["event_name#{0}","event_name#{2}"],                  returned1
    assert_equal ["event_name#{2}","event_name#{0}","event_name#{1}"], returned2
  end
end
