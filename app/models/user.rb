class User < ActiveRecord::Base
  validates :identifier, presence: true
  validates :rootUrl, presence: true
  validates :identifier, uniqueness: true
end
