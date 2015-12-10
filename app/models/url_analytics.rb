module TrafficSpy
  class UrlAnalytics

    def find_client(identifier)
      TrafficSpy::User.find_by(identifier: identifier)
    end

    def longest_response_time(identifier)
      client = find_client(identifier)
      client.payloads.maximum(:responded_in)
    end

    def shortest_response_time(identifier)
      client = find_client(identifier)
      client.payloads.minimum(:responded_in)
    end

    def average_response_time(identifier)
      client = find_client(identifier)
      client.payloads.average(:responded_in).round(3).to_f
    end

    def verbs_used(identifier)
      client = find_client(identifier)
      client.payloads.pluck(:request_type)
    end

    def most_popular_referrers(identifier)
      client = find_client(identifier)
      referrers = client.payloads.group(:referred_by).count
      referrers.sort_by { |k, v| [-v, k] }.map{ |u| u[0] }[0..2]
    end

    def most_popular_user_agents(identifier) #browser
      client = find_client(identifier)
      browsers = client.payloads.group(:browser).count
      browsers.sort_by { |k, v| [-v, k] }.map{ |u| u[0] }[0..2]
    end

  end
end
