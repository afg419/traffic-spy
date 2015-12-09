require_relative '../test_helper'

class UrlAnalyticsTest < ModelTest

  def load_user_info(n)
    TrafficSpy::User.create("identifier"=>"identifier#{n}", "root_url"=>"http://root_url#{n}.com")
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
    load_user_info(n).payloads << load_user_payload(n, verb, datetime)
  end

  def test_we_can_access_a_specfic_users_payloads
    associate_user_payload(1)
    associate_user_payload(2)

    u1 = TrafficSpy::User.find_by(identifier: "identifier1")
    payload_1 = u1.payloads
    ip = payload_1.map { |p| p.ip }

    assert payload_1
    assert_equal ["63.29.38.211"], ip

    u2 = TrafficSpy::User.find_by(identifier: "identifier1")
    payload_2 = u2.payloads
    verb = payload_2.map { |p| p.request_type}

    assert payload_2
    assert_equal ["GET"], verb
  end

end
