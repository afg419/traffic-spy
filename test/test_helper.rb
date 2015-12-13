ENV["RACK_ENV"] ||= "test"

require 'bundler'
Bundler.require(:test)

require File.expand_path("../../config/environment", __FILE__)
DatabaseCleaner.strategy = :truncation, {except: %w[public.schema_migrations]}

require 'minitest/autorun'
require 'capybara'

Capybara.app = TrafficSpy::Server


class AppTest < Minitest::Test
  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end
end


class ControllerTest < AppTest
  include Rack::Test::Methods #gives GET, POST, DELETE, etc

  def app  #this is what tells Rack::Test what app to look for.
    TrafficSpy::Server
  end
end

class FeatureTest < AppTest
  include Capybara::DSL

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
end

class ModelTest < AppTest

end
