class User < ActiveRecord::Base
  validates :name, presence: true
  validate :name, uniqueness: true
end
