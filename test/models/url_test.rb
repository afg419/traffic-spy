  require_relative '../test_helper'

class UrlTest < ModelTest

  def load_user_info(n)
    TrafficSpy::User.find_or_create_by("identifier"=>"identifier#{n}", "root_url"=>"http://jumpstartlab.com")
  end

  def payload_data
    {
      "requested_at"=> "2013-02-16 21:38:28 -0700",
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

    user = TrafficSpy::User.find_by(identifier: "identifier1")

    assert_equal 60, user.urls.longest_response_time
  end

  def test_shortest_response_time
    associate_user_url(1)
    associate_user_url(1, "GET", 60)
    associate_user_url(1, "GET", 13)

    user = TrafficSpy::User.find_by(identifier: "identifier1")

    assert_equal 13, user.urls.shortest_response_time
  end

  def test_average_response_time
    associate_user_url(1)
    associate_user_url(1, "GET", 60)
    associate_user_url(1, "GET", 13)

    user = TrafficSpy::User.find_by(identifier: "identifier1")

    assert_equal 36.667, user.urls.average_response_time
  end

  def test_we_can_collect_http_verbs_that_have_been_used
    associate_user_url(1, "DELETE")
    associate_user_url(1, "GET")
    associate_user_url(1, "POST")

    user = TrafficSpy::User.find_by(identifier: "identifier1")

    assert_equal ["DELETE", "GET", "POST"], user.urls.verbs_used
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

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    expected = ["http://google.com",
                "http://facebook.com",
                "http://jumpstartlab.com"]

    assert_equal expected, user.urls.most_popular_referrers
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

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    expected = ["Firefox", "Chrome", "Safari"]

    assert_equal expected, user.urls.most_popular_user_agents
  end

  def test_we_can_return_average_response_times_per_url_in_descending_order
    load_database_tables(1, 37, "blog")
    load_database_tables(1, 38, "blog")
    load_database_tables(1, 23, "about")
    load_database_tables(1, 16, "article/1")
    load_database_tables(1, 37, "about")
    load_database_tables(1, 11, "blog")
    load_database_tables(1, 99, "article/1")

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    expected = ["article/1: 57.5 ms", "about: 30.0 ms", "blog: 28.667 ms"]

    assert_equal expected, user.urls.url_response_times
  end


  def test_we_can_return_all_the_requested_urls_in_the_correct_order
    load_database_tables(1, 37, "blog")
    load_database_tables(1, 38, "blog")
    load_database_tables(1, 23, "about")
    load_database_tables(1, 17, "article/1")
    load_database_tables(1, 37, "about")
    load_database_tables(1, 11, "blog")
    load_database_tables(1, 99, "article/2")

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    expected = ["blog: 3", "about: 2", "article/1: 1", "article/2: 1"]

    assert_equal expected, user.urls.requested_urls
  end

  def test_we_can_return_all_the_operating_systems_and_their_breakdown
    load_database_tables(1, 37, "url", "Chrome")
    load_database_tables(1, 16, "url", "Firefox")
    load_database_tables(1, 17, "url", "Chrome")
    load_database_tables(1, 44, "url", "Chrome", "Microsoft")
    load_database_tables(1, 45, "url", "Safari", "Linux")
    load_database_tables(1, 46, "url", "Firefox", "Linux")

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    expected = ["Macintosh: 3", "Linux: 2", "Microsoft: 1"]

    assert_equal expected, user.urls.os_breakdown
  end

  def test_we_can_return_screen_resolution_for_all_requests
    load_database_tables(1, 37, "url", "Chrome", "Linux")
    load_database_tables(1, 16, "url", "Firefox", "Linux")
    load_database_tables(1, 17, "url", "Chrome", "Linux")
    load_database_tables(1, 44, "url", "Chrome", "Microsoft", "1366", "768")
    load_database_tables(1, 45, "url", "Safari", "Linux", "1920", "1080")
    load_database_tables(1, 46, "url", "Firefox", "Linux", "1024", "768")

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    expected = ["1920 x 1280", "1366 x 768", "1920 x 1080", "1024 x 768"]

    assert_equal expected, user.urls.resolution
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

    user = TrafficSpy::User.find_by(identifier: "identifier1")
    expected = ["Firefox: 4", "Chrome: 3", "Safari: 2", "Internet Explorer: 1"]

    assert_equal expected, user.urls.browser_breakdown
  end
end
