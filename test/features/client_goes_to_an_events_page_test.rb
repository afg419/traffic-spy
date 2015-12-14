require_relative '../test_helper'

class EventDetailsTest < FeatureTest

  def test_event_page_nav_bar
    register_user("jumpstartlab", "http://jumpstartlab.com")
    load_tables("jumpstartlab", "http://jumpstartlab.com")

    visit('/sources/jumpstartlab/events/socialLogin')

    within('.nav-wrapper') do
      assert has_link?("Jumpstartlab")
      assert has_link?("Traffic Spy")
      assert has_link?("Event")
      assert has_link?("socialLogin")
    end
  end

  def test_goes_to_event_details_page
    register_user("jumpstartlab", "http://jumpstartlab.com")
    load_tables("jumpstartlab", "http://jumpstartlab.com")

    visit('/sources/jumpstartlab/events/socialLogin')

    within('#event_details_header') do
      assert page.has_content?("Jumpstartlab")
      assert page.has_content?("socialLogin")
    end

    refute page.has_css?("app_details_error")
  end

  def test_goes_into_event_page_finds_content
    register_user("jumpstartlab", "http://jumpstartlab.com")
    load_tables("jumpstartlab", "http://jumpstartlab.com")


    visit('/sources/jumpstartlab/events')
    click_link('socialLogin')

    within('h2') do
      assert page.has_content?("Total Events: 1")
    end

    within('.container') do
      assert page.has_content?("Hour Amount Total Count")
      assert page.has_content?("9 pm	1	1")
      assert page.has_content?("10 pm  0 1")
    end

    refute page.has_css?("app_details_error")
  end

  def test_goes_to_app_error_page_if_user_not_registered
    visit('/sources/jumpstartlab/events/socialLogin')

    refute page.has_css?("#event_details_header")

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

    visit('/sources/jumpstartlab/events/socialBLOGIN')

    within('#app_details_header') do
      assert page.has_content?("Jumpstartlab")
    end

    within('#app_details_error') do
      assert page.has_content?("has not been defined")
    end
  end
end
