module TrafficSpy
  class UrlAnalytics

    def longest_response_time(identifier)
      u = TrafficSpy::User.find_by(identifier: identifier)
      response_time = u.payloads.map { |p| p.responded_in }
      response_time.sort.last
    end

    def shortest_response_time

    end

    def average_response_time

    end

  end
end
