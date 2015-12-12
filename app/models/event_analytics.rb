module TrafficSpy
  class EventAnalytics
    attr_reader :identifier, :event_name

    def initialize(identifier, event_name)
      @identifier = identifier
      @event_name = event_name
    end

    def find_event_times
      time_array = TrafficSpy::Payload.where(event_name: event_name).pluck(:requested_at).map do |num|
        num.localtime.hour
      end
    end

    def total_events
      find_event_times.count
    end

    def hour_creation
      hour_count = (1..24).to_a.zip(Array.new(24,0)).to_h
      find_event_times.each do |num|
        hour_count[num] += 1
      end
      hour_count
    end

    def hour_edited
      hour_creation.sort.map do |k, v|
        if k <= 12
          [ k.to_s + " am" , v]
        else
          [(k - 12).to_s + " pm", v]
        end
      end.to_h
    end
  end
end
