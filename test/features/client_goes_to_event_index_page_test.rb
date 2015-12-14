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

  def test_goes_to_app_error_page_if_user_not_registered
    visit('/sources/jumpstartlab/events')

    refute page.has_css?("#event_index_header")

    within('#app_details_header') do
      assert page.has_content?("Jumpstartlab's")
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
