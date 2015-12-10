module TrafficSpy
  class Payload < ActiveRecord::Base
    belongs_to :user
    belongs_to :url
    validates_presence_of :requested_at,
                          :event_name,
                          :resolution_width,
                          :resolution_height,
                          :ip
  end
end
