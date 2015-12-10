require_relative '../test_helper'

class AppAnalyticsTest < ModelTest

  def load_user_info(n)
    TrafficSpy::User.find_or_create_by("identifier"=>"identifier#{n}", "root_url"=>"http://jumpstartlab.com")
  end

  def load_user_payload(n, response_time = 37, url = "blog", browser="Chrome", platform="Macintosh", res_width="1920", res_height="1280")
    TrafficSpy::Payload.create({"url"=>url,
                                "requested_at"=>"2013-02-16 21:38:28 -0700",
                                "responded_in"=>response_time,
                                "referred_by"=>"http://jumpstartlab.com",
                                "request_type"=>"GET",
                                "event_name"=>"event_name#{n}",
                                "resolution_width"=>res_width,
                                "resolution_height"=>res_height,
                                "ip"=>"63.29.38.211",
                                "browser"=>browser,
                                "platform"=>platform})
  end

  def associate_user_payload(n, response_time = 37, url = "blog", browser="Chrome", platform="Macintosh", res_width="1920", res_height="1280")
    load_user_info(n).payloads << load_user_payload(n, response_time, url, browser, platform, res_width, res_height)
  end

  def test_we_can_return_average_response_times_per_url_in_descending_order
    skip
    associate_user_payload(1, 37, "blog")
    associate_user_payload(1, 38, "blog")
    associate_user_payload(1, 23, "about")
    associate_user_payload(1, 16, "article/1")
    associate_user_payload(1, 37, "about")
    associate_user_payload(1, 11, "blog")
    associate_user_payload(1, 99, "article/1")

    client = TrafficSpy::AppAnalytics.new

    assert_equal ["blog: 28.667 ms", "about: 30.0 ms", "article/1: 57.5 ms"], client.url_response_times("identifier1")
  end

  def test_we_can_return_all_the_requested_urls_in_the_correct_order
    associate_user_payload(1, 37, "blog")
    associate_user_payload(1, 38, "blog")
    associate_user_payload(1, 23, "about")
    associate_user_payload(1, 17, "article/1")
    associate_user_payload(1, 37, "about")
    associate_user_payload(1, 11, "blog")
    associate_user_payload(1, 99, "article/2")

    client = TrafficSpy::AppAnalytics.new

    assert_equal ["blog", "about", "article/1", "article/2"], client.requested_urls("identifier1")
  end

  def test_we_can_return_all_the_browsers_and_their_breakdown
    associate_user_payload(1, 37, "url")
    associate_user_payload(1, 16, "url")
    associate_user_payload(1, 17, "url")
    associate_user_payload(1, 44, "url", "Firefox")
    associate_user_payload(1, 45, "url", "Firefox")
    associate_user_payload(1, 46, "url", "Firefox")
    associate_user_payload(1, 47, "url", "Firefox")
    associate_user_payload(1, 47, "url", "Safari")
    associate_user_payload(1, 48, "url", "Safari")
    associate_user_payload(1, 5, "url", "Internet Explorer")

    client = TrafficSpy::AppAnalytics.new

    assert_equal ["Firefox: 4", "Chrome: 3", "Safari: 2", "Internet Explorer: 1"], client.browser_breakdown("identifier1")
  end

  def test_we_can_return_all_the_operating_systems_and_their_breakdown
    associate_user_payload(1, 37, "url", "Chrome")
    associate_user_payload(1, 16, "url", "Firefox")
    associate_user_payload(1, 17, "url", "Chrome")
    associate_user_payload(1, 44, "url", "Chrome", "Microsoft")
    associate_user_payload(1, 45, "url", "Safari", "Linux")
    associate_user_payload(1, 46, "url", "Firefox", "Linux")

    client = TrafficSpy::AppAnalytics.new

    assert_equal ["Macintosh: 3", "Linux: 2", "Microsoft: 1"], client.os_breakdown("identifier1")
  end

  def test_we_can_return_screen_resolution_for_all_requests
    associate_user_payload(1, 37, "url", "Chrome", "Linux")
    associate_user_payload(1, 16, "url", "Firefox", "Linux")
    associate_user_payload(1, 17, "url", "Chrome", "Linux")
    associate_user_payload(1, 44, "url", "Chrome", "Microsoft", "1366", "768")
    associate_user_payload(1, 45, "url", "Safari", "Linux", "1920", "1080")
    associate_user_payload(1, 46, "url", "Firefox", "Linux", "1024", "768")

    client = TrafficSpy::AppAnalytics.new

    assert_equal ["1920 x 1280", "1366 x 768", "1920 x 1080", "1024 x 768"], client.resolution("identifier1")
  end

end
