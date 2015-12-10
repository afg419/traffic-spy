module TrafficSpy
  class Payload < ActiveRecord::Base
    belongs_to :user
    belongs_to :url
    validates_presence_of :url,
                          :requested_at,
                          :responded_in,
                          :referred_by,
                          :request_type,
                          :event_name,
                          :resolution_width,
                          :resolution_height,
                          :ip,
                          :browser,
                          :platform
  end
end
