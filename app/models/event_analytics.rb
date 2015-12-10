module TrafficSpy
  class EventAnalytics
    attr_reader :identifier, :event_name

    def initialize(identifier, event_name)
      @identifier = identifier
      @event_name = event_name
    end

    def find_event_times
      user_id = TrafficSpy::User.find_by(identifier: identifier).id
      event = TrafficSpy::Payload.find_by(user_id: user_id).event_name
      if event.include?(event_name)
        time_array = TrafficSpy::Payload.where(event_name: event).pluck(:requested_at)
          t = time_array.map { |t| t.split[1].split(":").first }.sort
      end
    end

    def total_events
      find_event_times.count
    end

    def hourly_events
      hour_count = Hash.new(0)
      array = find_event_times
      array.each do |num|
        hour_count[num] += 1
      end
      hour_count
    end
  end
end
