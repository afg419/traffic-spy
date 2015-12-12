module TrafficSpy
  class Server < Sinatra::Base
    get '/' do
      erb :index
    end

    not_found do
      erb :error
    end

    post '/sources' do
      validator = TrafficSpy::UserValidator.new
      validator.validate(params)

      status(validator.status)
      body(validator.body)
    end

    post '/sources/:identifier/data' do |identifier|
      validator = TrafficSpy::PayloadValidator.new
      ruby_params = TrafficSpy::Parser.new.parse(params)
      validator.insert_or_error_status(ruby_params, identifier)

      status(validator.status)
      body(validator.body)
    end

    get '/sources/:identifier' do |identifier|
      @id = identifier
      @user = User.find_by(identifier: @id)

      case true
      when @user.nil?
        @error = "Sorry! #{identifier.capitalize} has not been registered!"
        erb :application_details_error
      when @user.payloads.length == 0
        @error = "Sorry! No payload data has been registered for #{identifier.capitalize}."
        erb :application_details_error
      when true
        @analyst = TrafficSpy::AppAnalytics.new
        erb :application_details
      end

      #
      # if @user.nil?
      #   @error = "Sorry! #{identifier.capitalize} has not been registered!"
      #   erb :application_details_error
      # elsif @user.payloads.length == 0
      #   @error = "Sorry! No payload data has been registered for #{identifier.capitalize}."
      #   erb :application_details_error
      # else
      #   @analyst = TrafficSpy::AppAnalytics.new
      #   erb :application_details
      # end
    end

    get '/sources/:identifier/urls/:relative_path' do |identifier, relative_path|
      @id = identifier
      @user = User.find_by(identifier: @id)

      if @user.nil?
        @error = "Sorry! #{@id.capitalize} has not been registered!"
        erb :application_details_error
      elsif @user.urls.find_by(url:relative_path).nil?
        @error = "Sorry! #{relative_path} has not been requested!"
        erb :application_details_error
      else
        @local_url = relative_path
        @analyst = TrafficSpy::UrlAnalytics.new
        erb :url_details
      end
    end

    get '/sources/:identifier/events/:event_name' do |identifier, event_name|
      @id = identifier
      @user = User.find_by(identifier: @id)

      if @user.nil?
        @error = "Sorry! #{@id.capitalize} has not been registered!"
        erb :application_details_error
      elsif @user.payloads.find_by(event_name:event_name).nil?
        @error = "Sorry! #{event_name} has not been defined!"
        erb :application_details_error
      else
        @event = event_name
        @analyst = TrafficSpy::EventAnalytics.new(identifier,event_name)
        erb :event_details
      end
    end

    get '/sources/:identifier/events' do |identifier|
      @id = identifier
      @user = User.find_by(identifier: @id)

      if @user.nil?
        @error = "Sorry! #{@id.capitalize} has not been registered!"
        erb :application_details_error
      elsif @user.payloads.length == 0
        @error = "Sorry! No events have been defined!"
        erb :application_details_error
      else
        @data = 0
        erb :event_index
      end
    end

  end
end
