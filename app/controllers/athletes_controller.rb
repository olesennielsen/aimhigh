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
      to_date = Date::civil(params[:to][:year].to_i, params[:to][:month].to_i, params[:to][:day].to_i)
      @events = Event.where(:attachment_id => @attachment.id).where("starts_at > ? AND ends_at < ?" , from_date, to_date)
      @calendar = generate_ical_calendar(@events)
      @calendar.publish
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
      to_date = Date::civil(params[:to][:year].to_i, params[:to][:month].to_i, params[:to][:day].to_i)
      @events = Event.where(:attachment_id => @attachment.id).where("starts_at > ? AND ends_at < ?" , from_date, to_date)
      pdf = pdf::EventPdf.new(@athlete, @events )
      send_data pdf.render, filename: "events_#{from_date.strftime("%d/%m/%Y")}.pdf", type: "application/pdf"
      headers['Content-Type'] = "text/pdf; charset=UTF-8"
    end
  end
  
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
      font = "Helvetica"
      logo
      move_down 20
      unless(athlete.fullname.blank?)
        text "Navn: #{athlete.fullname}", :size => 20
      else
        text "Email: #{athlete.email}", :size => 20
      end
      draw_table(events)
      stroke_horizontal_rule
      draw_descriptions(events)
    end

    def logo
      headerpath = "#{Rails.root}/app/assets/images/header.jpg"
      logopath =  "#{Rails.root}/app/assets/images/logo1.png"
      image headerpath, :position => -40
      image logopath, :vposition => 10, :scale => 0.8
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
      table data, :row_colors => ["F3A648", '878786'] do
        cells.borders = []
        cells.size = 9
        row(0).borders      = [:bottom]
        row(0).font_style   = :bold
        self.header = true
        columns(2).align = :right
      end
    end

    def draw_descriptions(events)
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
    return calendar
  end
end
