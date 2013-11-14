class Attachment < ActiveRecord::Base
  require 'roo'
  require 'excel_parser'
  belongs_to :athlete
  has_many :events
  mount_uploader :file, AttachmentUploader
  attr_accessible :title, :file, :athlete_id
  before_validation :make_title_from_file
  after_save :parse_document

  # Take the title of file as title of attachment in DB
  def make_title_from_file 
    self.title = self.file.identifier
  end

  # Get data via get_data and for each event store them in the event table
  
  def parse_document
    @athlete = Athlete.find(self.athlete_id)
    excel_parser = ExcelParser.new(self.file)
    file_content = excel_parser.dispatch
    @athlete.update_attributes({name: file_content[:athlete_name]}.merge(file_content[:data]))
    batch_update(file_content[:events])
  end

  
  def batch_update(events)
    sql_delete_sessions = "DELETE FROM sessions WHERE event_id IN (SELECT event_id FROM sessions INNER JOIN events ON (sessions.event_id = events.id) WHERE attachment_id = #{self.id});"
    sql_delete_events = "DELETE FROM events WHERE attachment_id = #{self.id};"
    sql_get_id = (Attachment.connection.execute "SELECT nextval('events_id_seq');")[0]["nextval"].to_i
    sql_sessions = []
    sql_events = []    
    events.each do |event|
      sql_events << event_to_sql(event, sql_get_id)
      event[:sessions].each do |session|
        sql_sessions << session_to_sql(session, sql_get_id)
      end
      sql_get_id = (Attachment.connection.execute "SELECT nextval('events_id_seq');")[0]["nextval"].to_i
    end
      
    sql_create_events = "INSERT INTO events 
                  (id, title, duration, starts_at, ends_at, all_day, description, created_at, updated_at, attachment_id) 
                  VALUES #{sql_events.join(", ")}"
    if !sql_sessions.empty?
      sql_create_sessions = "INSERT INTO sessions
                  (title, focus, created_at, updated_at, event_id, session_description_id) 
                  VALUES #{sql_sessions.join(", ")}"
      Attachment.connection.execute sql_create_sessions
    end
    
    Attachment.connection.execute sql_create_events
    
  end  

  def event_to_sql(event, id)
    "(#{id}, '#{event[:title]}', #{event[:duration]}, '#{event[:starts_at]}', '#{event[:ends_at]}', #{event[:all_day]}, '#{event[:description]}', 'now', 'now', #{self.id})"
  end

  def session_to_sql(session, event_id)
    "('#{session[:title]}', '#{session[:focus]}', 'now', 'now', #{event_id}, #{nullify(session[:session_description_id])})"
  end

  def nullify(string)
    string.nil? ? "NULL" : string 
  end
    
end
