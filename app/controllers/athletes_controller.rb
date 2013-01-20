# -*- coding: utf-8 -*-
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
      pdf = pdf::EventPdf.new(@athlete, @events )
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
     def initialize( athlete, events )
       super(:page_size => "A4", :page_layout => :landscape)
       logo
       move_down 20
       unless(athlete.fullname.blank?)
         text "Navn: #{athlete.fullname}"
       else
         text "Email: #{athlete.email}"
       end
       move_down 20
       draw_table(events)
     end

     def logo
       logopath =  "#{Rails.root}/app/assets/images/logo1.png"
       image logopath
     end

     def create_data(events)
       data = [[" ","Træningsform", "Tid", "Max", "AT","Sub-AT", "Int. Grundt.","Grundt.",
         "Rest", "Power", "Funk. Styrke","Andet"]]
       events.each do |event|
         event_data = Array.new(12)
         event_data[0] = event.starts_at.to_date.to_formatted_s(:short)
         event_data[1] = event.title
         event_data[2] = event.duration
         if(event.sessions.empty?)
           (1..8).each do 
             event_data | [""]
           end
         else
           event.sessions.each do |session|
             if session.focus == "Max" then
               event_data[3] = session.title
             elsif (event_data[3].nil?)
               event_data[3] = ""
             end
             if session.focus == "AT" then
               event_data[4] = session.title
             elsif (event_data[4].nil?)
               event_data[4] = ""
             end
             if session.focus == "Sub-AT" then
               event_data[5] = session.title
             elsif (event_data[5].nil?)
               event_data[5] = ""
             end
             if session.focus == "IG" then
               event_data[6] = session.title
             elsif (event_data[6].nil?)
               event_data[6] = ""
             end
             if session.focus == "GZ" then
               event_data[7] = session.title
             elsif (event_data[7].nil?)
               event_data[7] = ""
             end
             if session.focus == "Resitution" then
               event_data[8] = session.title
             elsif (event_data[8].nil?)
               event_data[8] = ""
             end
             if session.focus == "Power" then
               event_data[9] = session.title
             elsif (event_data[9].nil?)
               event_data[9] = ""
             end
             if session.focus == "FS" then
               event_data[10] = session.title
             elsif (event_data[10].nil?)
               event_data[10] = ""
             end
           end
         end
         unless(event.description.blank?)
           event_data[11] = event.description
         else 
           event_data[11] = ""
         end
         data << event_data
       end
       return data
     end

     def draw_table(events)
       data = create_data(events)
       table (data) do
         self.header = true

         columns(2).align = :right
       end
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
