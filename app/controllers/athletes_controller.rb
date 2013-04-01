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
      @events = Event.where(:attachment_id => @attachment.id).where("starts_at >= ? AND ends_at <= ?" , from_date, to_date)
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
      from_date = params[:start_date_pdf].to_datetime.utc
      to_date = params[:end_date_pdf].to_datetime.utc
      @events = Event.where(:attachment_id => @attachment.id).where("starts_at >= ? AND ends_at <= ?" , from_date, to_date)
      
      # Fill events with days without events
      (from_date..to_date).each do |date|
        unless( @events.where(:starts_at => date).exists?)
          @events << Event.new(:starts_at => date)
        end
      end

      # Sort by event_date
      @events.sort_by! {|e| e.starts_at}
      
      pdf = pdf::EventPdf.new(@athlete, @events )
      send_data pdf.render, filename: "events_#{from_date.strftime("%d/%m/%Y")}.pdf", type: "application/pdf"
      headers['Content-Type'] = "text/pdf; charset=UTF-8"
    end
  end

  def changestatus
    @athlete = Athlete.find(params[:athlete_id])
    @athlete.toggle!(:status)
    respond_to do |format|
      format.html { redirect_to admins_path }
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
      super(:page_size => "A4", :page_layout => :landscape, :top_margin => 10)
      font = "Helvetica"
      logo
      move_down 40
      unless(athlete.name.blank?)
        text "Navn: #{athlete.name}", :size => 9
      else
        text "Email: #{athlete.email}", :size => 9
      end
      move_down 20
      draw_table(events)
      move_down 20
      stroke_horizontal_rule
      move_down 20
      unless(athlete.max_puls.nil?)
        float do
          indent(665) do
            pulsbox(athlete)
          end
        end
      end
      draw_descriptions(events)
    end

    def logo
      logopath =  "#{Rails.root}/app/assets/images/logopdf.png"
      image logopath, :vposition => 10, :scale => 0.8
    end

    def pulsbox(athlete)
      max_puls = athlete.max_puls || 0
      max_effect = athlete.max_effect || 0
      at_puls = athlete.at_puls || 0
      at_effect = athlete.at_effect || 0
      data = [["Zone","Puls","Effekt"],
              ["Max", "#{max_puls}", "#{max_effect}"],
              ["AT", "#{at_puls}", "#{at_effect}"],
              ["Max-Zone","#{(at_puls*1.02).round + 1} - #{max_puls}","#{(at_effect*1.04).round + 1} - #{max_effect}"],
              ["AT-Zone", "#{(at_puls*0.98).round} - #{(at_puls*1.02).round}","#{(at_effect*0.97).round} - #{(at_effect*1.04).round}"],
              ["sub-AT-Zone", "#{(at_puls*0.93).round} - #{(at_puls*0.98).round - 1}","#{(at_effect*0.89).round} - #{(at_effect*0.97).round - 1}"],
              ["int. grundzone", "#{(at_puls*0.88).round} - #{(at_puls*0.93).round - 1}","#{(at_effect*0.82).round} - #{(at_effect*0.89).round - 1}"],
              ["grundtræning", "#{(at_puls*0.70).round} - #{(at_puls*0.88).round - 1}","#{(at_effect*0.60).round} - #{(at_effect*0.82).round - 1}"],
              ["restitution","#{(at_puls*0.50).round} - #{(at_puls*0.70).round - 1}","#{(at_effect*0.30).round} - #{(at_effect*0.60).round - 1}"]]
      table data do
        cells.size = 6
        cells.border_width = 0.1
        cells.borders = []
        cells.padding = [2,2,2,2]
        columns(0).padding = [2,2,2,6]
        self.header = true
        columns(1..2).align = :center
        columns(0).borders = [:left]

      end

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
      table data, :width => 770 do
        cells.size = 6
        cells.borders = [:bottom, :top, :right, :left]
        cells.border_width = 0.1
        cells.padding = [2,2,2,2]
        row(0).borders      = [:bottom]
        row(0).font_style   = :bold
        self.header = true
        columns(2).align = :right
        columns(3..10).align = :center
        columns(0).width = 25
        columns(2).width = 20
        columns(3..10).width = 50
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
        text "Beskrivelser", :size => 9
        move_down 10
        session_descriptions.each do |desc|
          text desc.description, :size => 6, :width => 550
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
      cal_event = to_ics( event )
      calendar.add cal_event
    end
    return calendar
  end

  def to_ics( event ) 
    cal_event = Icalendar::Event.new
    cal_event.start = (event.starts_at + 6.hours).strftime("%Y%m%dT%H%M%S")
    cal_event.end = (event.ends_at + 6.hours).strftime("%Y%m%dT%H%M%S")
    cal_event.summary = event.title
    cal_event.description = description_to_ics( event )
    return cal_event
  end

  def description_to_ics ( event )
    description = event.description
    sessions = event.sessions
    description_string = ""
    unless sessions.empty? then
      sessions.each do |session|
        unless(session.session_description.nil?) then
          description_string = description_string + session.session_description.description + "\n"
        end
      end
    end
    unless event.description.nil? then
      description_string = description_string + "Andet: " + description
    end
    return description_string
  end
end
