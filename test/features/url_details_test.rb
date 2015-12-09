require_relative '../test_helper'

class UrlDetailsTest < FeatureTest

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
               "platform"=>"Mac"}
  end

  def test_the_truth
    assert_equal 1+1, 2
  end

  def test_goes_to_url_details_page
    TrafficSpy::User.create("identifier" => "jumpstartlab", "root_url" => "http://jumpstartlab.com")
    TrafficSpy::Payload.create(payload)

    visit('/sources/jumpstartlab/urls/blog')
    assert_equal '/sources/jumpstartlab/urls/blog', current_path

    within('#url_details_header') do
      assert page.has_content?("jumpstartlab")
    end

    refute page.has_css?("app_details_error")

  end
  #
  # def test_goes_to_app_error_page_if_user_not_registered
  #   visit('/sources/jumpstartlab')
  #   assert_equal '/sources/jumpstartlab', current_path
  #
  #   within('#app_details_header') do
  #     assert page.has_content?("jumpstartlab")
  #   end
  #
  #   within('#app_details_error') do
  #     assert page.has_content?("has not been registered!")
  #   end
  # end
  #
  # def test_goes_to_app_details_page
  #   TrafficSpy::User.create("identifier":"jumpstartlab", "root_url":"/jumpstartlab")
  #
  #   visit('/sources/jumpstartlab')
  #   assert_equal '/sources/jumpstartlab', current_path
  #
  #   within('#app_details_header') do
  #     assert page.has_content?("jumpstartlab")
  #   end
  #
  #   within('#app_details_error') do
  #     assert page.has_content?("No payload data has been registered")
  #   end
  # end

end
