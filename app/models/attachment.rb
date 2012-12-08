class Attachment < ActiveRecord::Base
    belongs_to :athlete
    has_many :events, :dependent => :destroy
    mount_uploader :file, AttachmentUploader
    attr_accessible :title, :file, :athlete_id
    before_validation :make_title_from_file
    after_save :parse_document
    
    def make_title_from_file 
      self.title = self.file.identifier
    end
    
    def parse_document
      @workbook = get_workbook(self.file.current_path.to_s)
      generate_events   
    end
    
    def get_workbook( file_path )
      return Excelx.new(file_path)
    end
    
    def get_name( workbook )
       workbook.default_sheet = workbook.sheets[2]
      return workbook.cell('G',2)
    end

    def get_data( workbook )
      workbook.default_sheet = workbook.sheets[2]
      record = []
      16.upto(workbook.last_row) do |line|
        cell = workbook.cell(line, 'G')
        if !cell.nil?
          date = workbook.cell(line, 'F')
          title = workbook.cell(line, 'G')
          duration = workbook.cell(line, 'I')
          description = workbook.cell(line, 'R')
          record << {:date => date, :title => title, :duration => duration, :description => description}
        end
      end
      return record
    end

    def generate_events
      events = get_data(@workbook)
      events.each do |event|
      Event.create(:starts_at => event[:date], :ends_at => event[:date], :title => event[:title], 
                    :duration => event[:duration], :description => event[:description], :attachment_id => 1)
      end
    end         
end
