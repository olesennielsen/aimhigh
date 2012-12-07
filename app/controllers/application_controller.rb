class ApplicationController < ActionController::Base
	protect_from_forgery
=begin
		Method used when authenticating athletes and admin
=end
	def athlete_filter
		if athlete_signed_in?
			authenticate_athlete!
		else
			authenticate_admin!
		end
	end
=begin
	Used for making sure that admins are the only
	model who is able to invite
=end
	protected
	def authenticate_inviter!
			authenticate_admin!(:force => true)
	end
=begin
	The path after sign in should differentiate
	depending on the user priveleges
=end
	def after_sign_in_path_for(resource)
		if admin_signed_in?
			admin_path(current_admin)
		elsif athlete_signed_in?
			athlete_path(current_athlete)
		end
	end
=begin 
  help finding the current_athlete by params
=end
	def find_athlete
      @athlete = Athlete.find(params[:athlete_id])
  end

end
