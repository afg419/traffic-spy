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

    post '/sources/:identifier/data' do |identifier|
      binding.pry
    end

  end
end


# {"payload"=>
#   "{\"url\":\"http://jumpstartlab.com/blog\",
#       \"requestedAt\":\"2013-02-16 21:38:28 -0700\",
#       \"respondedIn\":37,
#       \"referredBy\":\"http://jumpstartlab.com\",
#       \"requestType\":\"GET\",
#       \"parameters\":[],
#       \"eventName\":\"socialLogin\",
#       \"userAgent\":\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17\",
#       \"resolutionWidth\":\"1920\",
#       \"resolutionHeight\":\"1280\",
#       \"ip\":\"63.29.38.211\"}",
#  "splat"=>[],
#  "captures"=>["jumpstartlab"],
#  "identifier"=>"jumpstartlab"}
