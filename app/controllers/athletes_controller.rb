# -*- coding: utf-8 -*-
class AthletesController < ApplicationController
  load_and_authorize_resource
  before_filter :find_athlete, :only => [:show, :destroy]
  def exportcal
    @athlete = Athlete.find(params[:athlete_id])
    if(@athlete.attachment.nil?)
      flash[:error] = 'You have no current events'
      redirect_to athlete_path(@athlete)
    else
      @attachment = @athlete.attachment
      from_date = params[:start_date_cal].to_datetime
      to_date = params[:end_date_cal].to_datetime
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
      from_date = params[:start_date_pdf].to_datetime
      to_date = params[:end_date_pdf].to_datetime
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
      move_down 20
      stroke_horizontal_rule
      move_down 10
      draw_descriptions(events)
    end

    def logo
      logopath =  "#{Rails.root}/app/assets/images/logo1.png"
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
        event.focus_areas.each do |focus|
            event_data[find_focus(focus.code)] = "x"
        end
        unless event.sessions.empty? then 
          event.sessions.each do |session|
            event_data[find_focus(session.focus)] = session.title
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
      table data do
        cells.borders = []
        cells.size = 9
        row(0).borders      = [:bottom]
        row(0).font_style   = :bold
        self.header = true
        columns(2).align = :right
        columns(3..10).align = :center
        
      end
    end

    def draw_descriptions(events)
      session_descriptions = []
      events.each do |event|
        event.sessions.each do |session|
          unless (session_descriptions.include?(session.session_description) || session.session_description.nil?)
            session_descriptions << session.session_description
          end
        end
      end
      unless session_descriptions.empty? 
        text "Beskrivelser", :size => 20
        move_down 10
        session_descriptions.each do |desc|
          text desc.description, :size => 8
          move_down 2
        end
      end
    end
    
    protected
    def find_focus( focus_string )
      case focus_string
      when "Max"
        3
      when "AT"
        4
      when "Sub-AT" 
        5
      when "IG"
        6
      when "GZ"
        7
      when "Restitution"
        8
      when "Power"
        9
      when "FS"
        10
      else 7
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
    return calendar
  end
end
