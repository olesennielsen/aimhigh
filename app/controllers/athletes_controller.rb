class AthletesController < ApplicationController
  before_filter :athlete_filter, :except => :invitation
  before_filter :authenticate_admin!, :only => :invitation
  before_filter :find_athlete, :only => [:show, :destroy]


  def exportcal
    @athlete = Athlete.find(params[:athlete_id])
    if(@athlete.attachment.nil?)
      flash[:error] = 'You have no current events'
      redirect_to athlete_path(@athlete)
    else
      @attachment = @athlete.attachment
      from_date = Date::civil(params[:from][:year].to_i, params[:from][:month].to_i, params[:from][:day].to_i)
      @events = Event.where(:attachment_id => @attachment.id).where("starts_at > ?" , from_date)
      @calendar = generate_ical_calendar(@events)
      headers['Content-Type'] = "text/calendar; charset=UTF-8"
      render :text => @calendar.to_ical
    end
  end
  
  def exportpdf
    @athlete = Athlete.find(params[:athlete_id])
    if(@athlete.attachment.nil?)
      flash[:error] = 'You have no current events'
      redirect_to athlete_path(@athlete)
    else
      @attachment = @athlete.attachment
      from_date = Date::civil(params[:from][:year].to_i, params[:from][:month].to_i, params[:from][:day].to_i)
      @events = Event.where(:attachment_id => @attachment.id).where("starts_at > ?" , from_date)
      pdf = pdf::EventPdf.new( @events )
      send_data pdf.render, filename: "events_#{from_date.strftime("%d/%m/%Y")}.pdf", type: "application/pdf"
      headers['Content-Type'] = "text/pdf; charset=UTF-8"
    end
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

   class EventPdf < Prawn::Document
     def initialize( events )
       super()
       text "This is an aimhigh event list"
     end
   end

   protected    
   def find_athlete
     @athlete = Athlete.find(params[:id])
   end	
   
   def generate_ical_calendar( events )
     calendar = Icalendar::Calendar.new
     events.each do |event|
       cal_event = Icalendar::Event.new
       cal_event.start = event.starts_at.strftime("%Y%m%dT%H%M%S")
       cal_event.end = event.ends_at.strftime("%Y%m%dT%H%M%S")
       cal_event.summary = event.title
       cal_event.description = event.description
       calendar.add cal_event
     end
     return calendar.publish
   end
 end
