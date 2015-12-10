module TrafficSpy
  class AppAnalytics

    def find_client(identifier)
      TrafficSpy::User.find_by(identifier: identifier)
    end

    def url_response_times

    end

    def requested_urls(identifier)
      client = find_client(identifier)
      urls = client.payloads.group(:url).count
      urls.sort_by { |k, v| [-v, k] }.map{ |u| u[0] }
    end

    def browser_breakdown(identifier)
      client = find_client(identifier)
      browsers = client.payloads.group(:browser).count
      browsers = browsers.sort_by { |k, v| [-v, k] }
      breakdown = []
      browsers.each { |k, v| breakdown << "#{k}: #{v}"}
      breakdown
    end

    def os_breakdown(identifier)
      client = find_client(identifier)
      os = client.payloads.group(:platform).count
      os = os.sort_by { |k, v| [-v, k] }
      breakdown = []
      os.each { |k, v| breakdown << "#{k}: #{v}"}
      breakdown
    end

    def resolution(identifier)
      client = find_client(identifier)
      w = client.payloads.pluck(:resolution_width)
      h = client.payloads.pluck(:resolution_height)
      pairs = w.zip(h).uniq
      res = []
      pairs.each { |p| res << "#{p[0]} x #{p[1]}" }
      res
    end

  end
end
