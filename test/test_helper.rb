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
  def register_user(n)
    TrafficSpy::User.find_or_create_by("identifier"=>"identifier#{n}", "root_url"=>"http://jumpstartlab.com")
  end

  def ruby_payload_params
    {
      "requested_at"=> "2013-02-16 21:38:28 -0700",
      "event_name"=>"event_name",
      "resolution_width"=>"1920",
      "resolution_height"=>"1280",
      "ip"=>"63.29.38.211",
      "payload_sha"=>"953829399845098230498130948"
    }
  end

    def load_user_url(n, verb = "GET", response_time = 37, referred_by = "http://jumpstartlab.com", browser="Chrome")
    ruby_payload_params.merge(url: TrafficSpy::Url.create({"url"=>"url#{n}",
                                "responded_in"=>response_time,
                                "referred_by"=>referred_by,
                                "request_type"=>verb,
                                "browser"=>browser,
                                "platform"=>"platform#{n}"}))
  end

  def load_url_data_to_user(n, verb = "GET", response_time = 37, referred_by = "http://jumpstartlab.com", browser="Chrome")
    register_user(n).payloads.create(load_user_url(n,verb,response_time,referred_by,browser))
  end

  def load_database_tables(n, responded_in, url = "blog", browser = "Chrome", operating_system = "Macintosh", resolution_width = "1920", resolution_height = "1280")
    register_user(n)
    TrafficSpy::DbLoader.new({"url"=> url,
               "requested_at"=>"2013-02-16 21:38:28 -0700",
               "responded_in"=> responded_in,
               "referred_by"=>"http://jumpstartlab.com",
               "request_type"=>"GET",
               "event_name"=>"socialLogin",
               "resolution_width"=> resolution_width,
               "resolution_height"=> resolution_height,
               "ip"=>"63.29.38.211",
               "user_id"=>1,
               "browser"=> browser,
               "platform"=> operating_system,
               "payload_sha" => "12489809850939491939823"}, "identifier#{n}").load_databases
  end

  def defaults
    {"url"=>"blog",
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

  def register_user_x(identifier, root_url)
    TrafficSpy::User.find_or_create_by("identifier"=> identifier, "root_url"=> root_url)
  end

  def load_database_tables_x(identifier, root_url, payload_options = {})
    ruby_params = defaults.merge(payload_options)
    register_user_x(identifier, root_url)
    TrafficSpy::DbLoader.new(ruby_params, identifier).load_databases
  end
end
