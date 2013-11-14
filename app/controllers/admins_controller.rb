  class AdminsController < ApplicationController
    load_and_authorize_resource
    def index
      @search = Athlete.search(params[:q])
      puts "This is some search object stuff: #{@search.sorts.empty?}"
      if @search.sorts.empty?
        @athletes = Athlete.all.sort_by{|a| a.name || a.email}
      else
        @athletes = @search.result(:distinct => true)
      end
    end
    
    def show
      redirect_to admins_path
    end
  end
