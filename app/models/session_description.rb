class SessionDescription < ActiveRecord::Base
  has_one :session
  attr_accessible :description, :name, :time, :id
end
