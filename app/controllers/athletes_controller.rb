class AthletesController < ApplicationController
	before_filter :athlete_filter, :except => :invitation
	before_filter :authenticate_admin!, :only => :invitation
	before_filter :find_athlete, :only => [:show]
	
	def index
		
	end
	
	def show
		@event = Event.new
	end
	
	protected    
  def find_athlete
      @athlete = Athlete.find(params[:id])
  end
	
end
