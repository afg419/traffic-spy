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
      parsed = TrafficSpy::Parser.new(params)
      payload = TrafficSpy::PayloadValidator.new
      payload.validate(parsed)
      status(user.status)
      body(user.body)


      parsed = TrafficSpy::Parser.new.parse(params)
      TrafficSpy::Payload.create(parsed)
    end
  end
end
