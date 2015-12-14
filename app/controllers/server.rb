module TrafficSpy
  class Server < Sinatra::Base
    get '/' do
      erb :index
    end

    not_found do
      erb :error
    end

    helpers do

      def decide_view(condition, error)
        case true
        when @user.nil?
          @error = error![:no_user]
          erb :application_details_error
        when condition
          @error = error![error]
          erb :application_details_error
        when true
          yield
        end
      end

      def error!
        {
          :no_user => "Sorry! #{@id.capitalize} has not been registered!",
          :no_payload => "Sorry! No payload data has been registered for #{@id.capitalize}. - 400 Bad Request",
          :no_path => "Sorry! #{@local_url} has not been requested!",
          :no_event => "Sorry! #{@event} has not been defined!",
          :no_events => "Sorry! No events have been defined!"
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

      decide_view(@user.nil? || @user.payloads.length == 0, :no_payload) do
        erb :application_details
      end
    end

    get '/sources/:identifier/urls/:relative_path' do |identifier, relative_path|
      @id = identifier
      @user = User.find_by(identifier: @id)
      @local_url = relative_path

      decide_view(@user.nil? || @user.urls.find_by(url:relative_path).nil?, :no_path) do
        erb :url_details
      end
    end

    get '/sources/:identifier/events/:event_name' do |identifier, event_name|
      @id = identifier
      @user = User.find_by(identifier: @id)
      @event = event_name

      decide_view(@user.nil? || @user.payloads.find_by(event_name:event_name).nil?, :no_event) do
        erb :event_details
      end
    end

    get '/sources/:identifier/events' do |identifier|
      @id = identifier
      @user = User.find_by(identifier: @id)

      decide_view(@user.nil? || @user.payloads.length == 0, :no_events) do
        erb :event_index
      end
    end

  end
end
