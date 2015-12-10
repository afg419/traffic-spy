module TrafficSpy
  class EventAnalytics
    attr_reader :identifier, :event_name

    def initialize(identifier, event_name)
      @identifier = identifier
      @event_name = event_name
    end

    def find_event_times
      time_array = TrafficSpy::Payload.where(event_name: event_name).pluck(:requested_at)
      time_array.map { |t| t.split[1].split(":").first }.sort
    end

    def total_events
      find_event_times.count
    end

    def hourly_events
      hour_count = Hash.new(0)
      find_event_times.each do |num|
        hour_count[num] += 1
      end
      hour_count
    end
  end
end
