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

    def self.verbs_used
      verbs = group(:request_type).count
      verbs.sort_by { |k, v| [-v, k] }.map{ |u| "#{u[0]}: #{u[1]}" }
    end

    def self.most_popular_referrers
      referrers = group(:referred_by).count
      referrers.sort_by { |k, v| [-v, k] }.map{ |u| u[0] }[0..2]
    end

    def self.most_popular_user_agents
      browsers = group(:browser).count
      browsers.sort_by { |k, v| [-v, k] }.map{ |u| u[0] }[0..2]
    end

    def self.url_response_times
      stats = group(:url).average(:responded_in).to_a
      stats.sort_by! { |g| [-g[1], g[0]] }
      stats.map { |s| "#{s[0]}: #{s[1].to_f.round(3)} ms" }
    end

    def self.requested_urls
      urls = group(:url).count
      urls.sort_by { |k, v| [-v, k] }.map{ |u| "#{u[0]}: #{u[1]}" }
    end

    def self.os_breakdown
      os = group(:platform).count
      os = os.sort_by { |k, v| [-v, k] }
      os.map { |k, v| "#{k}: #{v}"}
    end

    def self.resolution
      pairs = pluck(:resolution_width, :resolution_height).uniq
      pairs.map { |p| "#{p[0]} x #{p[1]}" }
    end

    def self.browser_breakdown
      browsers = group(:browser).count
      browsers = browsers.sort_by { |k, v| [-v, k] }
      browsers.map { |k, v| "#{k}: #{v}"}
    end
  end
end
