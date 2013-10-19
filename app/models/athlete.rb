class Athlete < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :recoverable, :registerable, 
  :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :id, :status, :max_puls, :max_effect, :at_puls, :at_effect, :link_address, :link_username, :link_password, :events
  
  has_one :attachment
  has_many :events, :through => :attachment
  has_many :documents
  
  def active_for_authentication?
    #remember to call the super
    #then put our own check to determine "active" state using 
    #our own "is_active" column
    super and self.status?
  end


  def status_string
    if self.status then
      "Active"
    else
      "Passive"
    end
  end
  
end
