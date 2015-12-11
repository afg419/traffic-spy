require_relative '../test_helper'

class AppAnalyticsTest < ModelTest

  def load_user_info(n)
    TrafficSpy::User.find_or_create_by("identifier"=>"identifier#{n}", "root_url"=>"http://jumpstartlab.com")
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

  def test_we_can_return_average_response_times_per_url_in_descending_order
    load_database_tables(1, 37, "blog")
    load_database_tables(1, 38, "blog")
    load_database_tables(1, 23, "about")
    load_database_tables(1, 16, "article/1")
    load_database_tables(1, 37, "about")
    load_database_tables(1, 11, "blog")
    load_database_tables(1, 99, "article/1")

    client = TrafficSpy::AppAnalytics.new

    assert_equal ["article/1: 57.5 ms", "about: 30.0 ms", "blog: 28.667 ms"], client.url_response_times("identifier1")
  end

  def test_we_can_return_all_the_requested_urls_in_the_correct_order
    load_database_tables(1, 37, "blog")
    load_database_tables(1, 38, "blog")
    load_database_tables(1, 23, "about")
    load_database_tables(1, 17, "article/1")
    load_database_tables(1, 37, "about")
    load_database_tables(1, 11, "blog")
    load_database_tables(1, 99, "article/2")

    client = TrafficSpy::AppAnalytics.new

    assert_equal ["blog", "about", "article/1", "article/2"], client.requested_urls("identifier1")
  end

  def test_we_can_return_all_the_browsers_and_their_breakdown
    load_database_tables(1, 37, "url")
    load_database_tables(1, 16, "url")
    load_database_tables(1, 17, "url")
    load_database_tables(1, 44, "url", "Firefox")
    load_database_tables(1, 45, "url", "Firefox")
    load_database_tables(1, 46, "url", "Firefox")
    load_database_tables(1, 47, "url", "Firefox")
    load_database_tables(1, 47, "url", "Safari")
    load_database_tables(1, 48, "url", "Safari")
    load_database_tables(1, 5, "url", "Internet Explorer")

    client = TrafficSpy::AppAnalytics.new

    assert_equal ["Firefox: 4", "Chrome: 3", "Safari: 2", "Internet Explorer: 1"], client.browser_breakdown("identifier1")
  end

  def test_we_can_return_all_the_operating_systems_and_their_breakdown
    load_database_tables(1, 37, "url", "Chrome")
    load_database_tables(1, 16, "url", "Firefox")
    load_database_tables(1, 17, "url", "Chrome")
    load_database_tables(1, 44, "url", "Chrome", "Microsoft")
    load_database_tables(1, 45, "url", "Safari", "Linux")
    load_database_tables(1, 46, "url", "Firefox", "Linux")

    client = TrafficSpy::AppAnalytics.new

    assert_equal ["Macintosh: 3", "Linux: 2", "Microsoft: 1"], client.os_breakdown("identifier1")
  end

  def test_we_can_return_screen_resolution_for_all_requests
    load_database_tables(1, 37, "url", "Chrome", "Linux")
    load_database_tables(1, 16, "url", "Firefox", "Linux")
    load_database_tables(1, 17, "url", "Chrome", "Linux")
    load_database_tables(1, 44, "url", "Chrome", "Microsoft", "1366", "768")
    load_database_tables(1, 45, "url", "Safari", "Linux", "1920", "1080")
    load_database_tables(1, 46, "url", "Firefox", "Linux", "1024", "768")

    client = TrafficSpy::AppAnalytics.new

    assert_equal ["1920 x 1280", "1366 x 768", "1920 x 1080", "1024 x 768"], client.resolution("identifier1")
  end

end
