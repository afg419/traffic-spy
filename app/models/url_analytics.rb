module TrafficSpy
  class UrlAnalytics

    def longest_response_time(identifier)
      u = Users.find_by(identifier: identifier)
    end

  end
end
