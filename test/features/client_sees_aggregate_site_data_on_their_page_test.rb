require_relative '../test_helper'

class ClientSeesAggregateSiteData < FeatureTest
  def test_client_sees_aggregate_site_data_on_their_site
    TrafficSpy::User.create("identifier" => "jumpstartlab", "root_url" => "http://jumpstartlab.com")
    TrafficSpy::DbLoader.new(payload,"jumpstartlab").load_databases

    visit "/sources/jumpstartlab"

    within('.container') do
      assert page.has_content? "Most to Least Requested URLS"
      assert page.has_content? 'Screen Resolution'
    end
  end
end
