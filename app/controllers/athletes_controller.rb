class AthletesController < ApplicationController
	before_filter :athlete_filter, :except => :invitation
	before_filter :authenticate_admin!, :only => :invitation
	before_filter :find_athlete, :only => [:show, :destroy]
	
	
	def exportcal
    @athlete = Athlete.find(params[:athlete_id])
    @attachment = @athlete.attachment
    from_date = Date::civil(params[:from][:year].to_i, params[:from][:month].to_i, params[:from][:day].to_i)
    @events = Event.where(:attachment_id => @attachment.id).where("starts_at > ?" , from_date)
    @calendar = Icalendar::Calendar.new
    @events.each do |event|
      cal_event = Icalendar::Event.new
      cal_event.start = event.starts_at.strftime("%Y%m%dT%H%M%S")
      cal_event.end = event.ends_at.strftime("%Y%m%dT%H%M%S")
      cal_event.summary = event.title
      cal_event.description = event.description
      @calendar.add cal_event
    end
      @calendar.publish
      headers['Content-Type'] = "text/calendar; charset=UTF-8"
      render :text => @calendar.to_ical
  end
=begin  
  def export_events_google
    g = GData.new
    g.login('REPLACE_WITH_YOUR_MAIL@gmail.com', 'REPLACE_WITH_YOUR_PASSWORD')
    event = { :title=>'title',
      :content=>'content',
      :author=>'pub.cog',
      :email=>'pub.cog@gmail.com',
      :where=>'Toulouse,France',
      :startTime=>'2007-06-06T15:00:00.000Z',
      :endTime=>'2007-06-06T17:00:00.000Z'}
    g.new_event(event)
  end
=end
  def destroy
    @athlete.destroy

    respond_to do |format|
      format.html { redirect_to admins_path }
      format.xml  { head :ok }
    end
  end
	
protected    
  def find_athlete
      @athlete = Athlete.find(params[:id])
  end	
end
