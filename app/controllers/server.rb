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
        params[:identifier].to_s == "" || params[:rootUrl].to_s == ""
        status 400
        body "Missing Parameters - 400 Bad Request"
      else
        status 403
        body "Identifier Already Exists - 403 Forbidden"
      end
    end

  end
end
