class Attachment < ActiveRecord::Base
  belongs_to :athlete
  has_many :events, :dependent => :destroy
  mount_uploader :file, AttachmentUploader
  attr_accessible :title, :file, :athlete_id
  before_validation :make_title_from_file
  after_save :parse_document

  # Take the title of file as title of attachment in DB
  def make_title_from_file 
    self.title = self.file.identifier
  end

  # Parsing the document
  def parse_document
    @workbook = get_workbook(self.file.current_path.to_s)
    @workbook.default_sheet = "Ugeplan"
    @athlete = Athlete.find(self.athlete_id)
    unless get_name( @workbook ).nil? then
      name = get_name( @workbook )
    else
      name = ""
    end
    @athlete.update_attribute(:name, name)
    @athlete.update_attributes(get_athlete_data( @workbook ))
    generate_events   
  end

  # Getting access to the file
  def get_workbook( file_path )
    return Roo::Excelx.new(file_path)
  end

  # Getting the athletes name according to the xlsx file
  def get_name( workbook )
    return workbook.cell('G',2)
  end

  def get_athlete_data( workbook )
    max_puls = workbook.cell('Y',5)
    max_effect = workbook.cell('AB',5)
    at_puls = workbook.cell('Y',6)
    at_effect = workbook.cell('AB',6)
    return {:max_puls => max_puls, :max_effect => max_effect, :at_puls => at_puls, :at_effect => at_effect }
  end
  
  # Method responsible for retrieving data from the attachment/workbook
  # and storing them in events. It utilizes the 'roo' gem to get access to the cells
  # NOTICE: Ugly implementation because of the workbook reference that has to be kept
  

  def get_data( workbook )
    record = []                                             # record for the events
    puts "this is the last row #{workbook.last_row}"
    16.upto(workbook.last_row) do |row|                     # Defines the row of interest - may variate \
      cell = workbook.cell(row, 'G')                        # Check for blank line 
      if !cell.nil? then
        date = workbook.cell(row, 'F')                      # Getting data for the event
        date = date.to_s + ' UTC'                                      # Using UTC
        title = workbook.cell(row, 'G')
        duration = workbook.cell(row, 'H')
        description = workbook.cell(row, 'Q')
        event_focus = []
        sessions = []                                       # Making the session array
        9.upto(16) do |column|
          if workbook.cell(row, column) == "x" then
            event_focus.concat(FocusArea.where(:code => find_focus(column)))
          end   # Defines the columns of interest and make sure it is not empty or just 'x'
          if !workbook.cell(row, column).nil? && workbook.cell(row, column) != "x" then 
            session_title = workbook.cell(row, column) 
            session_focus = find_focus( column )
            session_findings = SessionDescription.find_by_name(session_focus + ": " + session_title) # Locate training in the static table sessiondescription
            unless session_findings.nil? # Check for null before calling description on the findings
              session_description_id = session_findings.id
            end
            # Reassembling the session array
            sessions << Session.new(:title => session_title, :focus => session_focus, 
                                    :session_description_id => session_description_id)
          end
        end
        # Reassembling the record which is an event
        record << Event.new(:starts_at => date, :ends_at => date, :title => title, 
                            :duration => duration.to_i, :all_day => false, 
                            :description => description, :sessions => sessions, 
                            :attachment_id => self.id, :focus_areas => event_focus)
      end
    end
    return record
  end


  # Get data via get_data and for each event store them in the event table
  
  def generate_events
    events = get_data(@workbook)
    prev_event = nil                            
    events.each do |event|
      begin
        event.save
        prev_event = event
      rescue
        if !prev_event.starts_at.nil?
          error = "event dated just after #{prev_event.starts_at.to_date}"
        elsif !event.title.nil?
          error = "event named \"#{event.title}\" with event number #{events.find_index(event)}"
        else
          error = "event number #{events.find_index(event)}"   
        end  
        self.errors.add(:events, "upload did not succeed. Take a look at the row with #{error}")
        next
      end
    end
  end  


  # Find focues eases the use of correlation between column number and
  # session intensity which is defined by strings

  def find_focus( focus_number )
    case focus_number
    when 12
      "IG"
    when 14
      "Restitution"
    when 15 
      "Power"
    when 16
      "FS"
    when 13
      "GZ"
    when 11
      "Sub-AT"
    when 10
      "AT"
    when 9
      "Max"
    else "Unknown"
    end
  end
end
