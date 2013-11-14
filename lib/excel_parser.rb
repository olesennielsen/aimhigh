class ExcelParser
  require 'roo'
  require 'active_record'

  def initialize(file)
    @workbook = get_workbook(file.current_path.to_s)
    @workbook.default_sheet = "Ugeplan"
    @session_descriptions = ActiveRecord::Base.connection.select_all("SELECT * FROM session_descriptions")
    @focus_areas = ActiveRecord::Base.connection.select_all("SELECT * FROM focus_areas")
  end

  # Getting access to the file
  def get_workbook( file_path )
    return Roo::Excelx.new(file_path)
  end

  def dispatch
    {
      athlete_name: get_name(@workbook), 
      data: get_athlete_data(@workbook),
      events: get_event_data(@workbook)
    }
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
  
  
  def get_event_data( workbook )
    records = []                                             # record for the events
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
            event_focus.concat(@focus_areas.select{|area| area[:code] == find_focus(column)})
          end   # Defines the columns of interest and make sure it is not empty or just 'x'
          if !workbook.cell(row, column).nil? && workbook.cell(row, column) != "x" then 
            session_title = workbook.cell(row, column) 
            session_focus = find_focus( column )
            session_findings = @session_descriptions.
              select{|desc| desc["name"] == session_focus + ": " + session_title}.first
            # Locate training in the static table sessiondescription
            
            unless session_findings.nil? # Check for null before calling description on the findings
              session_description_id = session_findings["id"]
            end
            # Reassembling the session array
            sessions << Hash[title: session_title, focus: session_focus, 
                             session_description_id: session_description_id]
          end
        end
        #Reassembling the record which is an event
        records << Hash[starts_at: date, ends_at: calculate_ends_at(date, duration), title: title, 
                        duration: duration.to_i, all_day: false, 
                        description: description, focus_areas: event_focus,
                        sessions: sessions]
      end
    end
    return records
  end

  def calculate_ends_at(date, duration)
    date.to_time + duration.to_i.minutes
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
