require_relative '../test_helper'

class AppAnalyticsTest < ModelTest
  attr_reader :user

  def user(n)
    @user = TrafficSpy::User.find_or_create_by("identifier"=>"identifier#{n}", "root_url"=>"http://jumpstartlab.com")
  end

  # def load_user_payload(n, url = "blog", response_time = 37, browser="Chrome")
  #   TrafficSpy::Payload.create({"url"=>url,
  #                               "requested_at"=>"2013-02-16 21:38:28 -0700",
  #                               "responded_in"=>response_time,
  #                               "referred_by"=>"http://jumpstartlab.com",
  #                               "request_type"=>"GET",
  #                               "event_name"=>"event_name#{n}",
  #                               "resolution_width"=>"1920",
  #                               "resolution_height"=>"1280",
  #                               "ip"=>"63.29.38.211",
  #                               "browser"=>browser,
  #                               "platform"=>"platform#{n}"})
  # end

  def associate_user_payload(n, url = "blog", response_time = 37, browser="Chrome")
    # load_user_info(n).payloads << load_user_payload(n, url, response_time, browser)
    user(n).payloads.create({"url"=>url,
                                "requested_at"=>"2013-02-16 21:38:28 -0700",
                                "responded_in"=>response_time,
                                "referred_by"=>"http://jumpstartlab.com",
                                "request_type"=>"GET",
                                "event_name"=>"event_name#{n}",
                                "resolution_width"=>"1920",
                                "resolution_height"=>"1280",
                                "ip"=>"63.29.38.211",
                                "browser"=>browser,
                                "platform"=>"platform#{n}"})
  end

  def test_we_can_return_all_the_requested_urls_in_the_correct_order
    associate_user_payload(1, "blog", 37)
    associate_user_payload(1, "blog", 38)
    associate_user_payload(1, "about", 23)
    associate_user_payload(1, "article/1", 37)
    associate_user_payload(1, "about", 37)
    associate_user_payload(1, "blog", 11)
    associate_user_payload(1, "article/2", 99)

    client = TrafficSpy::AppAnalytics.new

    assert_equal ["blog", "about", "article/1", "article/2"], client.requested_urls("identifier1")
  end

end
