module TrafficSpy
  class User < ActiveRecord::Base
    has_many  :payloads
    validates :identifier, presence: true
    validates :root_url, presence: true
    validates :identifier, uniqueness: true
  end
end
