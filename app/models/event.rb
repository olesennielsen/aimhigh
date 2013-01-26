class Event < ActiveRecord::Base
  belongs_to :attachment
  has_many :sessions, :dependent => :destroy
  has_and_belongs_to_many :focus_areas, :uniq => true, :autosave => true

  attr_accessible :title, :description, :duration, :all_day, :starts_at, :ends_at, :attachment_id, :sessions, :focus_areas

  # Creating dummy values in the start and end attributes
  before_validation :make_start_time, :make_end_time 

  validates :title, :presence => true

  # These methods makes dummy values for calendar export
  # such that the events are always placed in the bottom of the calendar 
  # (6am-8am)
  def make_start_time
    self.starts_at = (self.starts_at.to_date.to_datetime)
  end
  
  def make_end_time
    self.ends_at = (self.ends_at.to_date.to_datetime + duration.minutes)
  end
  
  # The json object configured for the fullcalendar jQuery liberary
  # Pressing the event will redirect to athlete_event_path
  def as_json(options = {})
    {
      :id => self.id,
      :title => self.title,
      :description => self.description || "",
      :start => starts_at.to_time.iso8601,
      :end => ends_at.to_time.iso8601,
      :allDay => false,
      :recurring => false
    }
  end

  # Date formatter to agree on date/time with fullcalendar
  def self.format_date(date_time)
    Time.at(date_time.to_i).to_formatted_s(:db)
  end
end
