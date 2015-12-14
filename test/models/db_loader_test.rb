require_relative '../test_helper'

class DbLoaderTest < ModelTest
  def register_user
    TrafficSpy::User.find_or_create_by({"identifier"=>"jumpstartlab", "root_url"=>"http://jumpstartlab.com"})
  end

  def loader
    TrafficSpy::DbLoader.new({"url"=> "blog/2",
               "requested_at"=>"2013-02-16 21:38:28 -0700",
               "responded_in"=> 25,
               "referred_by"=>"http://jumpstartlab.com",
               "request_type"=>"GET",
               "event_name"=>"socialLogin",
               "resolution_width"=> "1920",
               "resolution_height"=> "1350",
               "ip"=>"63.29.38.211",
               "user_id"=>1,
               "browser"=> "firefox",
               "platform"=> "linux",
               "payload_sha" => "12489809850939491939823"}, "jumpstartlab")
  end

  def test_exists
    assert TrafficSpy::DbLoader
  end

  def test_initializes_with_loadable_data
    assert loader.ruby_params.is_a?(Hash)
    assert_equal "jumpstartlab", loader.identifier
  end

  def test_has_payload_columns
    expected = ["id",
                "event_name",
                "resolution_width",
                "resolution_height",
                "ip",
                "user_id",
                "payload_sha",
                "url_id",
                "requested_at"]

    assert_equal expected, loader.payload_columns
  end

  def test_has_url_columns
    expected = ["id",
                "url",
                "responded_in",
                "referred_by",
                "request_type",
                "browser",
                "platform"]
    assert_equal expected, loader.url_columns
  end

  def test_creates_url_row_from_loadable_data
    refute TrafficSpy::Url.all.first

    loader.loadable_params

    assert_equal 1, TrafficSpy::Url.all.first.id
    assert_equal "blog/2", TrafficSpy::Url.all.first.url
    assert_equal "firefox", TrafficSpy::Url.all.first.browser
  end

  def test_creates_payload_row_from_loadable_data
    register_user
    refute TrafficSpy::Payload.all.first

    loader.load_databases

    assert_equal 1, TrafficSpy::Payload.all.first.id
    assert_equal "63.29.38.211", TrafficSpy::Payload.all.first.ip
    assert_equal "socialLogin", TrafficSpy::Payload.all.first.event_name
  end

  def test_associates_url_and_payload_through_user
    register_user
    loader.load_databases
    user = TrafficSpy::User.all.first

    assert_equal user.payloads.first, TrafficSpy::Payload.all.first
    assert_equal user.urls.first, TrafficSpy::Url.all.first
    assert_equal user.urls.first.payloads.first, TrafficSpy::Payload.all.first
  end
end
