require_relative '../test_helper'

class AppDetailsTest < FeatureTest
  def test_goes_to_app_details_page_nav_bar
    register_user("jumpstartlab", "http://jumpstartlab.com")
    load_tables("jumpstartlab", "http://jumpstartlab.com")

    visit('/sources/jumpstartlab')

    within('.nav-wrapper') do
      assert has_link?("Jumpstartlab")
      assert has_link?("Traffic Spy")
      assert has_link?("Event Index")
    end
  end

  def test_goes_to_app_details_page
    register_user("jumpstartlab", "http://jumpstartlab.com")
    load_tables("jumpstartlab","http://jumpstartlab.com")

    visit('/sources/jumpstartlab')
    assert_equal '/sources/jumpstartlab', current_path

    within('#app_details_header') do
      assert page.has_content?("Jumpstartlab's")
    end

    refute page.has_css?('#app_details_error')
  end

  def test_goes_to_app_error_page_if_user_not_registered
    visit('/sources/jumpstartlab')
    assert_equal '/sources/jumpstartlab', current_path

    within('#app_details_header') do
      assert page.has_content?("Jumpstartlab")
    end

    within('#app_details_error') do
      assert page.has_content?("has not been registered!")
    end
  end

  def test_goes_to_app_error_page_if_no_data_for_user
    register_user("jumpstartlab", "http://jumpstartlab.com")

    visit('/sources/jumpstartlab')
    assert_equal '/sources/jumpstartlab', current_path

    within('#app_details_header') do
      assert page.has_content?("Jumpstartlab")
    end

    within('#app_details_error') do
      assert page.has_content?("No payload data has been registered")
    end
  end

  def test_sees_app_data_when_registered
    register_user("jumpstartlab", "http://jumpstartlab.com")
    load_tables("jumpstartlab","http://jumpstartlab.com",{
      "url" => "article",
      "browser" => "Firefox"
    })
    load_tables("jumpstartlab","http://jumpstartlab.com",{
      "url" => "article",
      "browser" => "Firefox",
      "platform" => "Linux",
      "resolution_width" => "15",
      "resolution_height" => "30"
    })
    load_tables("jumpstartlab","http://jumpstartlab.com")
    visit('/sources/jumpstartlab')

    within('#requested-urls') do
      assert page.has_content? ("article")
      assert page.has_content? ("blog")
    end

    within('#browser-breakdown') do
      assert page.has_content? ("Firefox")
      assert page.has_content? ("2")
      assert page.has_content? ("Chrome")
      assert page.has_content? ("1")
    end

    within('#os-breakdown') do
      assert page.has_content? ("Macintosh")
      assert page.has_content? ("Linux")
    end

    within('#screen-res') do
      assert page.has_content? ("15 x 30")
      assert page.has_content? ("1920 x 1280")
    end

    within('#response-time') do
      assert page.has_content?("blog: 37.0 ms")
      assert page.has_content?("article: 37.0 ms")
    end
  end
end
