#
# def make_it(root_url = "jumpstartlab.com",local_url = "blog", event_name = "socialLogin")
#   "payload={'url':'http://#{root_url}/#{local_url}','requestedAt':'2013-02-16 21:38:28 -0700','respondedIn':37,'referredBy':'http://#{root_url}','requestType':'GET','parameters':[],'eventName':#{event_name},'userAgent':'Mozilla/5.0 (Macintosh%3B Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17','resolutionWidth':'1920','resolutionHeight':'1280','ip':'63.29.38.211'}"
# end
#
# `" curl -i -d 'identifier=penneylane&rootUrl=http://penneylane.com'  http://localhost:9393/sources "`
# `" curl -i -d '#{make_it(penneylane.com)}' http://localhost:9393/sources/penneylane/data "`
class Curl
  def load_user_info(id, root_url)
    TrafficSpy::User.find_or_create_by("identifier"=>id, "root_url"=>root_url)
  end

  def load_database_tables(id="jumpstartlab", root_url = "http://jumpstartlab.com", local_url = "blog", event_name = "socialLogin", browser = "Chrome", operating_system = "Macintosh", resolution_width = "1920", resolution_height = "1280")
    load_user_info(id, root_url)
    TrafficSpy::DbLoader.new({"url"=> local_url,
               "requested_at"=>"2013-02-16 21:38:28 -0700",
               "responded_in"=> 10,
               "referred_by"=> root_url,
               "request_type"=>"GET",
               "event_name"=>event_name,
               "resolution_width"=> resolution_width,
               "resolution_height"=> resolution_height,
               "ip"=>"63.29.38.211",
               "user_id"=>1,
               "browser"=> browser,
               "platform"=> operating_system,
               "payload_sha" => "12489809850939491939823"}, "#{id}").load_databases
  end
end
