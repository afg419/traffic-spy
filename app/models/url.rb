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
      pluck(:request_type)
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
      pairs = pluck(:url, :responded_in)
      grouped = pairs.group_by(&:first).map { |url, rt| [url, rt.map(&:last)]}
      urls = grouped.map { |g| g[0] }
      averages = grouped.map { |g| g[1].reduce(:+)/g[1].length.to_f }
      stats = urls.zip(averages)
      #client.urls.group(:url).average(:responded_in).map{|k,v| [k,v.to_f]}.to_h
      stats.sort_by { |g| g[1] }.reverse
      stats.map { |s| "#{s[0]}: #{s[1].round(3)} ms" }.reverse
    end

    def self.requested_urls
      urls = group(:url).count
      urls.sort_by { |k, v| [-v, k] }.map{ |u| u[0] }
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
