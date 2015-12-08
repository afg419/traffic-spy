module TrafficSpy
  class Server < Sinatra::Base
    get '/' do
      erb :index
    end

    not_found do
      erb :error
    end

    post '/sources' do
      user = UserValidator.new
      user.validate(params)
      status(user.status)
      body(user.body)
    end

    post '/sources/:identifier/data' do |identifier|
      parsed = Parser.new.parse(params)
      Payload.create(parsed)
    end
  end
end
