module TrafficSpy
  class Server < Sinatra::Base
    get '/' do
      erb :index
    end

    not_found do
      erb :error
    end

    post '/sources' do
      user = TrafficSpy::UserValidator.new
      user.validate(params)
      status(user.status)
      body(user.body)
    end

    post '/sources/:identifier/data' do |identifier|
      ruby_params = TrafficSpy::Parser.new.parse(params)
      payload = TrafficSpy::PayloadValidator.new
      payload.insert_or_error_status(ruby_params, identifier)

      status(payload.status)
      body(payload.body)
    end

    get '/sources/:identifier' do |identifier|
      # @user = User.find_by(identifier: identifer)
      @user = identifier
      if TrafficSpy::User.find_by(identifier: identifier).nil?
        @error = "Sorry! #{@user.capitalize} has not been registered!"
        erb :application_details_error
      elsif TrafficSpy::User.find_by(identifier: identifier).payloads.length == 0
        @error = "Sorry! No payload data has been registered for #{@user.capitalize}."
        erb :application_details_error
      else
        @analyst = TrafficSpy::AppAnalytics.new
        erb :application_details
      end
    end

    get '/sources/:identifier/urls/:relative_path' do |identifier, relative_path|
      @user = identifier
      user_row = TrafficSpy::User.find_by(identifier: identifier)
      if user_row.nil?
        @error = "Sorry! #{@user.capitalize} has not been registered!"
        erb :application_details_error
      elsif user_row.payloads.find_by(url:relative_path).nil?
        @error = "Sorry! #{relative_path} has not been requested!"
        erb :application_details_error
      else
        @local_url = relative_path
        @analyst = TrafficSpy::UrlAnalytics.new
        erb :url_details
      end
    end

    get '/sources/:identifier/events/:event_name' do |identifier, event_name|
      @user = identifier
      user_row = TrafficSpy::User.find_by(identifier: identifier)
      if user_row.nil?
        @error = "Sorry! #{@user.capitalize} has not been registered!"
        erb :application_details_error
      elsif user_row.payloads.find_by(event_name:event_name).nil?
        @error = "Sorry! #{event_name} has not been defined!"
        erb :application_details_error
      else
        @event = event_name
        @analyst = TrafficSpy::EventAnalytics.new(identifier,event_name)
        erb :event_details
      end
    end

    get '/sources/:identifier/events' do |identifier|
      @user = identifier
      user_row = TrafficSpy::User.find_by(identifier: identifier)
      if user_row.nil?
        @error = "Sorry! #{@user.capitalize} has not been registered!"
        erb :application_details_error
      elsif user_row.payloads.length == 0
        @error = "Sorry! No events have been defined!"
        erb :application_details_error
      else
        @data = 0
        erb :event_index
      end
    end

  end
end
