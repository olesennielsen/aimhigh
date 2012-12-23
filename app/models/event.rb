class Event < ActiveRecord::Base
  belongs_to :attachment
  has_many :sessions, :dependent => :destroy

  attr_accessible :title, :description, :duration, :all_day, :starts_at, :ends_at, :attachment_id, :sessions

  # Creating dummy values in the start and end attributes
  before_validation :make_start_time, :make_end_time 

  validates :title, :presence => true
  validate :all_day, :all_day => true

  # These methods makes dummay values for calendar export
  # such that the events are always placed in the bottum of the calendar 
  # (6am-8am)
  def make_start_time
    self.starts_at = (self.starts_at.to_date.to_datetime + 6.hours)
  end
  
  def make_end_time
    self.ends_at = (self.ends_at.to_date.to_datetime + 8.hours)
  end
  
  # The json object configured for the fullcalendar jQuery liberary
  # Pressing the event will redirect to athlete_event_path
  def as_json(options = {})
    {
      :id => self.id,
      :title => self.title,
      :description => self.description || "",
      :start => starts_at.to_date.rfc822,
      :end => ends_at.to_date.rfc822,
      :allDay => true,
      :recurring => false
    }
  end

  # Date formatter to agree on date/time with fullcalendar
  def self.format_date(date_time)
    Time.at(date_time.to_i).to_formatted_s(:db)
  end
end
