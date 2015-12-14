module TrafficSpy
  class Server < Sinatra::Base
    get '/' do
      erb :index
    end

    not_found do
      erb :error
    end

    helpers do
      def run_routes(condition, error1, error2)
        case true
        when @user.nil?
          @error = error1
          erb :application_details_error
        when condition
          @error = error2
          erb :application_details_error
        when true
          yield
        end
      end

      def errors(identifier = nil)
        {
          :non_registered => "Sorry! #{identifier.capitalize} has not been registered!",
          :error_missing => "Missing Payload - 400 Bad Request",
          :error_duplicate => "Already Received Request - 403 Forbidden"
        }
      end

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
        erb :application_details
      end
      #
      # run_routes(@user.payloads.length == 0,
      #           "Sorry! #{identifier.capitalize} has not been registered!",
      #           "Sorry! No payload data has been registered for #{identifier.capitalize}.") do
      #
      #             erb :application_details
      #
      #           end
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
        erb :event_index
      end
    end

  end
end
