class Session < ActiveRecord::Base
  belongs_to :event
  attr_accessible :description, :focus, :title
end
