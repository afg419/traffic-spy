ENV["RACK_ENV"] ||= "test"

require 'bundler'
Bundler.require(:test)

require File.expand_path("../../config/environment", __FILE__)
DatabaseCleaner.strategy = :truncation, {except: %w[public.schema_migrations]}

require 'minitest/autorun'
require 'capybara'

Capybara.app = TrafficSpy::Server

class ControllerTest < Minitest::Test
  include Rack::Test::Methods #gives GET, POST, DELETE, etc

  def app  #this is what tells Rack::Test what app to look for.
    TrafficSpy::Server
  end

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end
end

class ModelTest < Minitest::Test
  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end
end
