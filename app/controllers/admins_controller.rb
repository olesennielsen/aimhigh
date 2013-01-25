  class AdminsController < ApplicationController
    load_and_authorize_resource
    def index
      @search = Athlete.search(params[:q])
      @athletes = @search.result(:distinct => true)
    end
    
    def show
      redirect_to admins_path
    end
  end
