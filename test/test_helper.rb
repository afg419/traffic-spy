ENV["RACK_ENV"] ||= "test"

require 'bundler'
Bundler.require(:test)

require File.expand_path("../../config/environment", __FILE__)
DatabaseCleaner.strategy = :truncation, {except: %w[public.schema_migrations]}

require 'minitest/autorun'
require 'capybara'

Capybara.app = TrafficSpy::Server
