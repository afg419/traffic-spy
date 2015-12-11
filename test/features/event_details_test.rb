require_relative '../test_helper'

class EventDetailsTest < FeatureTest

  def payload
    {          "url"=>"blog",
               "requested_at"=>"2013-02-16 21:38:28 -0700",
               "responded_in"=>37,
               "referred_by"=>"http://jumpstartlab.com",
               "request_type"=>"GET",
               "event_name"=>"socialLogin",
               "resolution_width"=>"1920",
               "resolution_height"=>"1280",
               "ip"=>"63.29.38.211",
               "user_id"=>1,
               "browser"=>"Mozilla",
               "platform"=>"Mac",
               "payload_sha" => "12489809850939491939823"}
  end

  def test_goes_to_event_details_page
    TrafficSpy::User.create("identifier" => "jumpstartlab", "root_url" => "http://jumpstartlab.com")
    TrafficSpy::DbLoader.new(payload,"jumpstartlab").load_databases

    visit('/sources/jumpstartlab/events/socialLogin')

    within('#event_details_header') do
      assert page.has_content?("jumpstartlab")
      assert page.has_content?("socialLogin")
    end

    refute page.has_css?("app_details_error")
  end

  def test_goes_to_app_error_page_if_user_not_registered
    visit('/sources/jumpstartlab/events/socialLogin')

    refute page.has_css?("#event_details_header")

    within('#app_details_header') do
      assert page.has_content?("jumpstartlab's")
      assert page.has_content?("Error")
    end

    within('#app_details_error') do
      assert page.has_content?("has not been registered")
    end
  end

  def test_goes_to_app_error_page_if_url_does_not_exist
    TrafficSpy::User.create("identifier":"jumpstartlab", "root_url":"/jumpstartlab")

    visit('/sources/jumpstartlab/events/socialBLOGIN')

    within('#app_details_header') do
      assert page.has_content?("jumpstartlab")
    end

    within('#app_details_error') do
      assert page.has_content?("has not been defined")
    end
  end
end
