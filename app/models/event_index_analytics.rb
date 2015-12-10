module TrafficSpy
  class EventIndexAnalytics
    def find_client(identifier)
      TrafficSpy::User.find_by(identifier: identifier)
    end

    def events_by_popularity(identifier)
      client = find_client(identifier)
      binding.pry
      referrers = client.payloads.group(:event_name)
    end

  end
end
