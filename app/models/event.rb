class Event < ActiveRecord::Base
  belongs_to :attachment

  attr_accessible :title, :description, :duration, :all_day, :starts_at, :ends_at, :attachment_id
  
  # Creating dummy values in the start and end attributes
  before_validation :make_start_time, :make_end_time 

  validates :title, :presence => true
  validate :all_day, :all_day => true

  # These methods makes dummay values for calendar export
  def make_start_time
    self.starts_at = (self.starts_at.to_date.to_datetime + 6.hours)
  end
  
  def make_end_time
    self.ends_at = (self.ends_at.to_date.to_datetime + 8.hours)
  end
  
  # need to override the json view to return what full_calendar is expecting.
  # http://arshaw.com/fullcalendar/docs/event_data/Event_Object/
  def as_json(options = {})
    {
      :id => self.id,
      :title => self.title,
      :description => self.description || "",
      :start => starts_at.to_date.rfc822,
      :end => ends_at.to_date.rfc822,
      :allDay => true,
      :recurring => false,
      :athlete_id => self.attachment.athlete.id,
      # Ugly hack to get the URL working properly
      :url => Rails.application.routes.url_helpers.athlete_event_path(self.attachment.athlete.id,self.id)
    }
  end

  def self.format_date(date_time)
    Time.at(date_time.to_i).to_formatted_s(:db)
  end
end
