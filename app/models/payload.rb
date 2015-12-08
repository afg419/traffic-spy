class Payload < ActiveRecord::Base
  belongs_to :user
  # validates_presence_of :name #has all the columns in the data
end
