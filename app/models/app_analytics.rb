module TrafficSpy
  class AppAnalytics

    def find_client(identifier)
      TrafficSpy::User.find_by(identifier: identifier)
    end

    def url_response_times(identifier, url)
      client = find_client(identifier)
      average = client.payloads.select(:responded_in).where(url: url).average("responded_in").to_f.round(3)
      "#{url}: #{average} ms"
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
      browsers.map { |k, v| "#{k}: #{v}"}
    end

    def os_breakdown(identifier)
      client = find_client(identifier)
      os = client.payloads.group(:platform).count
      os = os.sort_by { |k, v| [-v, k] }
      os.map { |k, v| "#{k}: #{v}"}
    end

    def resolution(identifier)
      client = find_client(identifier)
      pairs = client.payloads.pluck(:resolution_width, :resolution_height).uniq
      pairs.map { |p| "#{p[0]} x #{p[1]}" }
    end

  end
end
