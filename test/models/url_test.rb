  require_relative '../test_helper'

class UrlTest < ModelTest

  def test_we_can_access_a_specfic_users_url
    load_database_tables_x("identifier1", "url1")
    load_database_tables_x("identifier2", "url2", {"request_type"=>"POST"})

    client_1 = TrafficSpy::User.find_by(identifier: "identifier1")
    url_1 = client_1.urls
    platform = url_1.first.platform

    assert_equal "Mac", platform

    client_2 = TrafficSpy::User.find_by(identifier: "identifier2")
    url_2 = client_2.urls
    verb = url_2.last.request_type

    assert_equal "POST", verb
  end
#
  def test_longest_response_time
    load_database_tables_x("identifier1", "url1")
    load_database_tables_x("identifier1", "url1", {"responded_in" => 60})
    load_database_tables_x("identifier1", "url1", {"responded_in" => 13})

    user = TrafficSpy::User.find_by(identifier: "identifier1")

    assert_equal 60, user.urls.longest_response_time
  end

  def test_shortest_response_time
    load_database_tables_x("identifier1", "url1")
    load_database_tables_x("identifier1", "url1", {"responded_in" => 60})
    load_database_tables_x("identifier1", "url1", {"responded_in" => 13})

    user = TrafficSpy::User.find_by(identifier: "identifier1")

    assert_equal 13, user.urls.shortest_response_time
  end

  def test_average_response_time
    load_database_tables_x("identifier1", "url1")
    load_database_tables_x("identifier1", "url1", {"responded_in" => 60})
    load_database_tables_x("identifier1", "url1", {"responded_in" => 13})

    user = TrafficSpy::User.find_by(identifier: "identifier1")

    assert_equal 36.667, user.urls.average_response_time
  end

  def test_we_can_collect_http_verbs_that_have_been_used
    load_database_tables_x("identifier1", "url1", {"request_type" => "DELETE"})
    load_database_tables_x("identifier1", "url1", {"request_type" => "GET"})
    load_database_tables_x("identifier1", "url1", {"request_type" => "POST"})

    user = TrafficSpy::User.find_by(identifier: "identifier1")

    assert_equal ["DELETE", "GET", "POST"], user.urls.verbs_used
  end

  def test_most_popular_referrers_returns_top_3
    load_database_tables_x("identifier1", "url1", {"referred_by" => "refer1"})
    load_database_tables_x("identifier1", "url1", {"referred_by" => "refer1"})
    load_database_tables_x("identifier1", "url1", {"referred_by" => "refer2"})
    load_database_tables_x("identifier1", "url1", {"referred_by" => "refer2"})
    load_database_tables_x("identifier1", "url1", {"referred_by" => "refer2"})
    load_database_tables_x("identifier1", "url1", {"referred_by" => "refer3"})
    load_database_tables_x("identifier1", "url1", {"referred_by" => "refer3"})
    load_database_tables_x("identifier1", "url1", {"referred_by" => "refer4"})

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    expected = ["refer2",
                "refer1",
                "refer3"]

    assert_equal expected, user.urls.most_popular_referrers
  end

  def test_most_popular_user_agents_returns_top_3_browsers
    load_database_tables_x("identifier1", "url1", {"browser" => "Chrome"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Chrome"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Chrome"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Firefox"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Firefox"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Firefox"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Firefox"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Safari"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Safari"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Internet Explorer"})

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    expected = ["Firefox", "Chrome", "Safari"]

    assert_equal expected, user.urls.most_popular_user_agents
  end

  def test_we_can_return_average_response_times_per_url_in_descending_order
    load_database_tables_x("identifier1", "url1", {"url" => "blog", "responded_in" => 37})
    load_database_tables_x("identifier1", "url1", {"url" => "blog", "responded_in" => 38})
    load_database_tables_x("identifier1", "url1", {"url" => "about", "responded_in" => 23})
    load_database_tables_x("identifier1", "url1", {"url" => "article/1", "responded_in" => 16})
    load_database_tables_x("identifier1", "url1", {"url" => "about", "responded_in" => 37})
    load_database_tables_x("identifier1", "url1", {"url" => "blog", "responded_in" => 11})
    load_database_tables_x("identifier1", "url1", {"url" => "article/1", "responded_in" => 99})

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    expected = ["article/1: 57.5 ms", "about: 30.0 ms", "blog: 28.667 ms"]

    assert_equal expected, user.urls.url_response_times
  end


  def test_we_can_return_all_the_requested_urls_in_the_correct_order
    load_database_tables_x("identifier1", "url1", {"url" => "blog"})
    load_database_tables_x("identifier1", "url1", {"url" => "blog"})
    load_database_tables_x("identifier1", "url1", {"url" => "about"})
    load_database_tables_x("identifier1", "url1", {"url" => "article/1"})
    load_database_tables_x("identifier1", "url1", {"url" => "about"})
    load_database_tables_x("identifier1", "url1", {"url" => "blog"})
    load_database_tables_x("identifier1", "url1", {"url" => "article/2"})

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    expected = ["blog", "about", "article/1", "article/2"]

    assert_equal expected, user.urls.requested_urls
  end

  def test_we_can_return_all_the_operating_systems_and_their_breakdown
    load_database_tables_x("identifier1", "url1", {"platform" => "Macintosh"})
    load_database_tables_x("identifier1", "url1", {"platform" => "Macintosh"})
    load_database_tables_x("identifier1", "url1", {"platform" => "Macintosh"})
    load_database_tables_x("identifier1", "url1", {"platform" => "Microsoft"})
    load_database_tables_x("identifier1", "url1", {"platform" => "Linux"})
    load_database_tables_x("identifier1", "url1", {"platform" => "Linux"})

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    expected = ["Macintosh: 3", "Linux: 2", "Microsoft: 1"]

    assert_equal expected, user.urls.os_breakdown
  end

  def test_we_can_return_screen_resolution_for_all_requests
    load_database_tables_x("identifier1", "url1")
    load_database_tables_x("identifier1", "url1")
    load_database_tables_x("identifier1", "url1")
    load_database_tables_x("identifier1", "url1", {"resolution_width" => "1366", "resolution_height" => "768"})
    load_database_tables_x("identifier1", "url1", {"resolution_width" => "1920", "resolution_height" => "1080"})
    load_database_tables_x("identifier1", "url1", {"resolution_width" => "1024", "resolution_height" => "768"})

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    expected = ["1024 x 768", "1920 x 1080", "1366 x 768", "1920 x 1280"]

    assert_equal expected, user.urls.resolution
  end

  def test_we_can_return_all_the_browsers_and_their_breakdown
    load_database_tables_x("identifier1", "url1", {"browser" => "Chrome"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Chrome"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Chrome"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Firefox"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Firefox"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Firefox"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Firefox"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Safari"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Safari"})
    load_database_tables_x("identifier1", "url1", {"browser" => "Internet Explorer"})

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    expected = ["Firefox: 4", "Chrome: 3", "Safari: 2", "Internet Explorer: 1"]

    assert_equal expected, user.urls.browser_breakdown
  end
end
