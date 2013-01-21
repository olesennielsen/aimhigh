class Session < ActiveRecord::Base
  belongs_to :event
  belongs_to :session_description
  attr_accessible :description, :focus, :title
end
