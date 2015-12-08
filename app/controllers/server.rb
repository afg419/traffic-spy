module TrafficSpy
  class Server < Sinatra::Base
    get '/' do
      erb :index
    end

    not_found do
      erb :error
    end

    post '/sources' do
      user = User.new(params)

      if user.save
        status 200
        body "Success - 200 OK: User registered! {'identifier':'params[:identifier]'}"
      elsif
        
    end
  end
end
