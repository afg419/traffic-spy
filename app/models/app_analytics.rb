module TrafficSpy
  class AppAnalytics

    def find_client(identifier)
      TrafficSpy::User.find_by(identifier: identifier)
    end

    def url_response_times(identifier)
      client = find_client(identifier)
      pairs = client.urls.pluck(:url, :responded_in)
      grouped = pairs.group_by(&:first).map { |url, rt| [url, rt.map(&:last)]}
      urls = grouped.map { |g| g[0] }
      averages = grouped.map { |g| g[1].reduce(:+)/g[1].length.to_f }
      stats = urls.zip(averages)
      stats.sort_by { |g| g[1] }.reverse
      stats.map { |s| "#{s[0]}: #{s[1].round(3)} ms" }.reverse
    end

    def requested_urls(identifier)
      client = find_client(identifier)
      urls = client.urls.group(:url).count
      urls.sort_by { |k, v| [-v, k] }.map{ |u| u[0] }
    end

    def browser_breakdown(identifier)
      client = find_client(identifier)
      browsers = client.urls.group(:browser).count
      browsers = browsers.sort_by { |k, v| [-v, k] }
      browsers.map { |k, v| "#{k}: #{v}"}
    end

    def os_breakdown(identifier)
      client = find_client(identifier)
      os = client.urls.group(:platform).count
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
