require_relative '../test_helper'

class SiteHomepageTest < FeatureTest
  def test_goes_to_home_page_and_renders_users_in_nav
    register_user("jumpstartlab", "http://jumpstartlab.com")
    register_user("penneyjumps", "http://penneyjumps.com")
    register_user("taylorsits", "http://taylorsits.com")
    register_user("aaronrides", "http://aaronrides.com")

    visit('/')

    within('#title') do
      assert page.has_content?("Hello, Traffic Spyer")
    end

    within('#dropdown1') do
      assert page.has_content?("jumpstartlab")
      assert page.has_content?("penneyjumps")
      assert page.has_content?("taylorsits")
      assert page.has_content?("aaronrides")
    end
  end
end
