  class AdminsController < ApplicationController
	before_filter :authenticate_admin!
	
	def index
		@search = Athlete.search(params[:q])
		@athletes = @search.result(:distinct => true)
	end
	
	def show
		redirect_to admins_path
	end
end
