module TrafficSpy
  class EventIndexAnalytics
    def find_client(identifier)
      TrafficSpy::User.find_by(identifier: identifier)
    end

    def events_by_popularity(identifier)
      client = find_client(identifier)
      referrers = client.payloads.group(:event_name).count
      referrers.sort_by { |k, v| [-v, k] }.map{ |u| u[0] }
    end
  end
end
