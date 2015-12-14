module TrafficSpy
  class Payload < ActiveRecord::Base
    belongs_to :user
    belongs_to :url
    validates_presence_of :requested_at,
                          :event_name,
                          :resolution_width,
                          :resolution_height,
                          :ip


    def self.events_by_popularity
      group(:event_name).count.sort_by { |k, v| [-v, k] }.map{ |u| "#{u[0]}: #{u[1]}" }
    end

    def self.find_event_times(event_name)
      where(event_name: event_name).pluck(:requested_at).map do |num|
        num.localtime.hour if num
      end
    end

    def self.total_events(event_name)
      find_event_times(event_name).count
    end

    def self.hour_creation(event_name)
      hour_count = (1..24).to_a.zip(Array.new(24,0)).to_h
      find_event_times(event_name).each do |num|
        hour_count[num] += 1
      end
      hour_count
    end

    def self.hour_edited(event_name)
      hour_creation(event_name).sort.map do |k, v|
        if k <= 12
          [ k.to_s + " am" , v]
        else
          [(k - 12).to_s + " pm", v]
        end
      end.to_h
    end
  end
end
