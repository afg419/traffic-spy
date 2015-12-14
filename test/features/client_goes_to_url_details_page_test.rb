require_relative '../test_helper'

class UrlDetailsTest < FeatureTest
  def test_goes_to_url_details_page
    register_user("jumpstartlab", "http://jumpstartlab.com")
    load_tables("jumpstartlab", "http://jumpstartlab.com")

    visit('/sources/jumpstartlab/urls/blog')
    assert_equal '/sources/jumpstartlab/urls/blog', current_path

    within('#url_details_header') do
      assert page.has_content?("Jumpstartlab")
      assert page.has_content?("blog")
    end

    refute page.has_css?("app_details_error")
  end

  def test_goes_to_app_error_page_if_user_not_registered
    visit('/sources/jumpstartlab/urls/blog')
    assert_equal '/sources/jumpstartlab/urls/blog', current_path

    refute page.has_css?("#url_details_header")

    within('#app_details_header') do
      assert page.has_content?("Jumpstartlab's")
      assert page.has_content?("Error")
    end

    within('#app_details_error') do
      assert page.has_content?("has not been registered")
    end
  end

  def test_goes_to_app_error_page_if_url_does_not_exist
    register_user("jumpstartlab", "http://jumpstartlab.com")

    visit('/sources/jumpstartlab/urls/dog')
    assert_equal '/sources/jumpstartlab/urls/dog', current_path

    within('#app_details_header') do
      assert page.has_content?("Jumpstartlab")
    end

    within('#app_details_error') do
      assert page.has_content?("has not been requested")
    end
  end

  def test_sees_app_url_data
    register_user("jumpstartlab", "http://jumpstartlab.com")
    load_tables("jumpstartlab", "http://jumpstartlab.com")
    load_tables("jumpstartlab", "http://jumpstartlab.com",{
                "request_type" => "POST",
                "browser" => "Firefox"
    })
    load_tables("jumpstartlab", "http://jumpstartlab.com",{
                "request_type" => "DELETE",
                "browser" => "Firefox"
    })
    load_tables("jumpstartlab", "http://jumpstartlab.com",{
                "request_type" => "DELETE",
                "browser" => "Opera"
    })
    load_tables("jumpstartlab", "http://jumpstartlab.com",{
                "responded_in" => 10
    })
    load_tables("jumpstartlab", "http://jumpstartlab.com",{
                "responded_in" => 50
    })

    visit('/sources/jumpstartlab/urls/blog')


    within("#verbs") do
      assert page.has_content?("POST")
      assert page.has_content?("GET")
      assert page.has_content?("DELETE")
    end

    within("#agents") do
      assert page.has_content?("Firefox")
      assert page.has_content?("Chrome")
      assert page.has_content?("Opera")
    end

    within("#shortest-response") do
      assert page.has_content?("10")
    end

    within("#longest-response") do
      assert page.has_content?("50")
    end

    within("#average-response") do
      assert page.has_content?("34.667")
    end
  end
end
