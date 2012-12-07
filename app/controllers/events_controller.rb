class EventsController < ApplicationController
  
  before_filter :find_athlete, :only => [:index, :show, :new, :edit, :create, :destroy]
  
  # GET /events
  # GET /events.xml
  def index   
	  @attachment = @athlete.attachment
		@events = Event.where("ends_at < ? AND starts_at > ? AND attachment_id = ?", Event.format_date(params['end']), Event.format_date(params['start']), @attachment.id)
 
    respond_to do |format|
      format.js  { render :json => @events }
      format.xml  { render :xml => @events }   
    end
  end
  
  def show    
	@event = Event.find(params[:id])
    respond_to do |format|
      format.html { render :html => @event }
      format.xml  { render :xml => @event }
      format.js { render :json => @event.to_json }
    end
  end

  def new
    @event = Event.new
	
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def edit
	  @event = @athlete.events.find(params[:id])
  end

  def create
	  @event = @athlete.events.new(params[:event])
	  @event.all_day = true
	
    respond_to do |format|
      if @event.save
        format.html { redirect_to athletes_path, :notice => 'Event was successfully created.' }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @event = Event.find(params[:id])
		@event.attributes = params[:event]
		
    respond_to do |format|
		if @event.save
			format.html { redirect_to(@event, :notice => 'Event was successfully updated.') }
			format.xml  { head :ok }
			format.js { head :ok}
		else
			format.html { render :action => "edit" }
			format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
			format.js  { render :js => @event.errors, :status => :unprocessable_entity }
		end
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to athletes_path }
      format.xml  { head :ok }
    end
  end  
end
