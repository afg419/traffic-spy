module TrafficSpy
  class EventAnalytics
    attr_accessor :identifier, :event

    def find_event_times(identifier, event_name)
      user_id = TrafficSpy::User.find_by(identifier: identifier).id
      event = TrafficSpy::Payload.find_by(user_id: user_id).event_name
      if event.include?(event_name)
        time_array = TrafficSpy::Payload.where(event_name: event).pluck(:requested_at)
          time_array.split.sort
      else
        "ERROR"
      end
    end
  end
end
