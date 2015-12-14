require_relative '../test_helper'

class EventIndexTest < FeatureTest

  def test_event_index_page_nav_bar
    register_user("jumpstartlab", "http://jumpstartlab.com")
    load_tables("jumpstartlab", "http://jumpstartlab.com")

    visit('/sources/jumpstartlab/events')

    within('.nav-wrapper') do
      assert has_link?("Jumpstartlab")
      assert has_link?("Traffic Spy")
      assert has_link?("Event")
    end
  end

  def test_goes_to_event_index_page
    register_user("jumpstartlab", "http://jumpstartlab.com")
    load_tables("jumpstartlab", "http://jumpstartlab.com")


    visit('/sources/jumpstartlab/events')
    within('#event_index_header') do
      assert page.has_content?("Jumpstartlab")
    end

    refute page.has_css?("app_details_error")
  end

  def test_goes_to_event_page_and_finds_a_link
    register_user("jumpstartlab", "http://jumpstartlab.com")
    load_tables("jumpstartlab", "http://jumpstartlab.com")


    visit('/sources/jumpstartlab/events')
    within('.container') do
      assert page.has_content?("Most to Least Requested Events")
      assert has_link?("socialLogin")
    end

    refute page.has_css?("app_details_error")
  end

  def test_goes_to_event_page_and_finds_two_links
    register_user("jumpstartlab", "http://jumpstartlab.com")
    load_tables("jumpstartlab", "http://jumpstartlab.com")
    load_tables("jumpstartlab", "http://jumpstartlab.com", {
      "event_name" => "time"
      })


    visit('/sources/jumpstartlab/events')
    within('.container') do
      assert page.has_content?("Most to Least Requested Events")
      assert has_link?("socialLogin")
      assert has_link?("time")
    end

    refute page.has_css?("app_details_error")
  end

  def test_goes_to_app_error_page_if_user_not_registered
    visit('/sources/blax/events')

    refute page.has_css?("#event_index_header")

    within('#app_details_header') do
      assert page.has_content?("Blax's")
      assert page.has_content?("Error")
    end

    within('#app_details_error') do
      assert page.has_content?("has not been registered")
    end
  end

  def test_goes_to_app_error_page_if_no_data_for_user
    register_user("jumpstartlab", "http://jumpstartlab.com")

    visit('/sources/jumpstartlab/events')

    within('#app_details_header') do
      assert page.has_content?("Jumpstartlab")
    end

    within('#app_details_error') do
      assert page.has_content?("Sorry! No events have been defined!")
    end
  end
end
