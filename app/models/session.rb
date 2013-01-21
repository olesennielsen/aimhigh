class Session < ActiveRecord::Base
  belongs_to :event
  belongs_to :session_description

  attr_accessible :session_description_id, :focus, :title
end
