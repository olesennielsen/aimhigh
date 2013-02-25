class Document < ActiveRecord::Base
  belongs_to :athletes
  attr_accessible :file
  mount_uploader :file, FileUploader

end
