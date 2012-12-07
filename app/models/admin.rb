class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :recoverable, 
  :registerable, :rememberable, :trackable, :validatable
  
  # Necessary for the admin-only-invite setting in application-controller
  include DeviseInvitable::Inviter

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

end
