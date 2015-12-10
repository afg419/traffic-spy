module TrafficSpy
  class AppAnalytics

    def find_client(identifier)
      TrafficSpy::User.find_by(identifier: identifier)
    end

    def requested_urls(identifier)
      client = find_client(identifier)
      urls = client.payloads.group(:url).count
      urls.sort_by { |k, v| [-v, k] }.map{ |u| u[0] }
    end

  end
end
