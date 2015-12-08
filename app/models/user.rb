module TrafficSpy
  class User < ActiveRecord::Base
    has_many  :payloads
    validates :identifier, presence: true
    validates :rootUrl, presence: true
    validates :identifier, uniqueness: true
  end
end
