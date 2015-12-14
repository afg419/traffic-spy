require_relative '../test_helper'

class PayloadTest < ModelTest
  def test_event_returns_one_requested_time
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 21:38:28 -0700"})

    user = TrafficSpy::User.find_by(identifier: "identifier1")

    assert_equal [21], user.payloads.find_event_times("event_name1")
  end

  def test_event_returns_two_requested_time
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 21:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 20:38:28 -0700"})

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    times = [21,20]
    assert_equal times, user.payloads.find_event_times("event_name1")
  end

  def test_total_events_counts_total
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 21:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 01:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 05:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 12:38:28 -0700"})

    user = TrafficSpy::User.find_by(identifier: "identifier1")

    assert_equal 4, user.payloads.total_events("event_name1")
  end

  def test_hourly_events_creates_hash
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 21:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 01:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 05:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 12:38:28 -0700"})

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    expected = {1=>1, 2=>0, 3=>0, 4=>0, 5=>1, 6=>0, 7=>0, 8=>0, 9=>0, 10=>0,
                11=>0, 12=>1, 13=>0, 14=>0, 15=>0, 16=>0, 17=>0, 18=>0, 19=>0,
                20=>0, 21=>1, 22=>0, 23=>0, 24=>0}

    assert_equal expected, user.payloads.hour_creation("event_name1")
  end

  def test_hourly_works_with_multiple_of_same_times
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 21:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 21:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 21:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 21:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 01:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 05:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 12:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 12:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 12:38:28 -0700"})

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    expected = {1=>1, 2=>0, 3=>0, 4=>0, 5=>1, 6=>0, 7=>0, 8=>0, 9=>0, 10=>0,
                11=>0, 12=>3, 13=>0, 14=>0, 15=>0, 16=>0, 17=>0, 18=>0, 19=>0,
                20=>0, 21=>4, 22=>0, 23=>0, 24=>0}

    assert_equal expected, user.payloads.hour_creation("event_name1")
  end

  def test_hour_edits_to_having_am_and_pm
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 01:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 21:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 12:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 12:38:28 -0700"})
    load_tables("identifier1", "url1", {"event_name" => "event_name1",
                                      "requested_at" => "2013-02-16 12:38:28 -0700"})

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    expected = {"1 am"=>1, "2 am"=>0, "3 am"=>0, "4 am"=>0, "5 am"=>0, "6 am"=>0,
                "7 am"=>0, "8 am"=>0, "9 am"=>0, "10 am"=>0, "11 am"=>0,
                "12 am"=>3, "1 pm"=>0, "2 pm"=>0, "3 pm"=>0, "4 pm"=>0,
                "5 pm"=>0, "6 pm"=>0, "7 pm"=>0, "8 pm"=>0, "9 pm"=>1,
                "10 pm"=>0, "11 pm"=>0, "12 pm"=>0}

    assert_equal expected, user.payloads.hour_edited("event_name1")
    assert_equal 3, user.payloads.hour_edited("event_name1")["12 am"]
  end

  def test_returns_events_by_popularity
    load_tables("identifier0", "url0", {"event_name" => "event_name0"})
    load_tables("identifier0", "url0", {"event_name" => "event_name0"})
    load_tables("identifier0", "url0", {"event_name" => "event_name0"})
    load_tables("identifier0", "url0", {"event_name" => "event_name1"})
    load_tables("identifier0", "url0", {"event_name" => "event_name2"})
    load_tables("identifier0", "url0", {"event_name" => "event_name2"})

    user = TrafficSpy::User.find_by(identifier: "identifier0")
    returned = user.payloads.events_by_popularity

    assert_equal ["event_name0","event_name2","event_name1"], returned
  end

  def test_returns_events_by_popularity_multiple_users
    load_tables("identifier2", "url2", {"event_name" => "event_name0"})
    load_tables("identifier2", "url2", {"event_name" => "event_name1"})
    load_tables("identifier2", "url2", {"event_name" => "event_name2"})
    load_tables("identifier2", "url2", {"event_name" => "event_name2"})

    load_tables("identifier0", "url0", {"event_name" => "event_name0"})
    load_tables("identifier0", "url0", {"event_name" => "event_name0"})
    load_tables("identifier0", "url0", {"event_name" => "event_name0"})
    load_tables("identifier0", "url0", {"event_name" => "event_name1"})
    load_tables("identifier0", "url0", {"event_name" => "event_name2"})
    load_tables("identifier0", "url0", {"event_name" => "event_name2"})

    load_tables("identifier1", "url1", {"event_name" => "event_name0"})
    load_tables("identifier1", "url1", {"event_name" => "event_name0"})
    load_tables("identifier1", "url1", {"event_name" => "event_name2"})

    user0 = TrafficSpy::User.find_by(identifier: "identifier0")
    user1 = TrafficSpy::User.find_by(identifier: "identifier1")
    user2 = TrafficSpy::User.find_by(identifier: "identifier2")

    returned0 = user0.payloads.events_by_popularity
    returned1 = user1.payloads.events_by_popularity
    returned2 = user2.payloads.events_by_popularity

    assert_equal ["event_name0","event_name2","event_name1"], returned0
    assert_equal ["event_name0","event_name2"],               returned1
    assert_equal ["event_name2","event_name0","event_name1"], returned2
  end
end
