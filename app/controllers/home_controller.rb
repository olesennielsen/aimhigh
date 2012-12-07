class HomeController < ApplicationController

  def index
	if admin_signed_in?
		redirect_to admin_path(current_admin)
	elsif athlete_signed_in?
		redirect_to athlete_path(current_athlete)
	end
  end
  
  def show
  end

end