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
    generate_events   
  end

  # Getting access to the file
  def get_workbook( file_path )
    return Excelx.new(file_path)
  end

=begin
  Getting the athletes name according to the xlsx file
  NOTICE: Not yet used
=end  
  def get_name( workbook )
    workbook.default_sheet = workbook.sheets[2]
    return workbook.cell('G',2)
  end

=begin
  Method responsible for retrieving data from the attachment/workbook
  and storing them in events. It utilizes the 'roo' gem to get access to the cells
  NOTICE: Ugly implementation because of the workbook reference that has to be kept
=end

  def get_data( workbook )
    workbook.default_sheet = workbook.sheets[2]
    record = []                                             # record for the events
    16.upto(workbook.last_row) do |row|                     # Defines the row of interest - may variate 
      cell = workbook.cell(row, 'G')                        # Check for blank line 
      if !cell.nil? then
        date = workbook.cell(row, 'F')                      # Getting data for the event
        title = workbook.cell(row, 'G')
        duration = workbook.cell(row, 'H')
        description = workbook.cell(row, 'Q')
        sessions = []                                       # Making the session array
        9.upto(16) do |column|                             # Defines the columns of interest and make sure it is not empty or just 'x'
          if !workbook.cell(row, column).nil? && workbook.cell(row, column) != "x" then 
            session_title = workbook.cell(row, column) 
            session_focus = find_focus( column )
            session_findings = SessionDescription.find_by_name(session_focus + ": " + session_title) # Locate training in the static table sessiondescription
            unless session_findings.nil? # Check for null before calling description on the findings
              session_description = session_findings.description
            end
            # Reassembling the session array
            sessions << Session.new(:title => session_title, :focus => session_focus, :description => session_description)
          end
        end
        # Reassembling the record which is an event
        record << Event.new(:starts_at => date, :ends_at => date, :title => title, 
        :duration => duration, :description => description, :sessions => sessions, :attachment_id => self.id)
      end
    end
    return record
  end

=begin 
  Get data via get_data and for each event store them in the event table
=end
  def generate_events
    events = get_data(@workbook)                            
    events.each do |event|
      event.save
    end
  end  

=begin
  Find focues eases the use of correlation between column number and
  session intensity which is defined by strings
=end
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
