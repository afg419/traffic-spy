module TrafficSpy
  class Url < ActiveRecord::Base
    has_many :payloads

    def self.longest_response_time
      maximum(:responded_in)
    end

    def self.shortest_response_time
      minimum(:responded_in)
    end

    def self.average_response_time
      average(:responded_in).round(3).to_f
    end

    def self.verbs_used(identifier)
      pluck(:request_type)
    end

    def self.most_popular_referrers(identifier)
      referrers = group(:referred_by).count
      referrers.sort_by { |k, v| [-v, k] }.map{ |u| u[0] }[0..2]
    end

    def self.most_popular_user_agents(identifier) #browser
      browsers = group(:browser).count
      browsers.sort_by { |k, v| [-v, k] }.map{ |u| u[0] }[0..2]
    end
  end
end
