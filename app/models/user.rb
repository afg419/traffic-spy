module TrafficSpy
  class User < ActiveRecord::Base
    has_many  :payloads
    has_many  :urls, through: :payloads

    validates :identifier, presence: true
    validates :root_url, presence: true
    validates :identifier, uniqueness: true

    # def requested_urls
    #   payloads.
    # end
  end
end
