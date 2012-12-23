require 'spec_helper'

describe Attachment do
  it "has a valid factory" do
    FactoryGirl.create(:attachment).should be_valid 
  end
  
  it "should not accept exe file in model" do
    expect{
      FactoryGirl.create(:attachment, 
        :file => Rack::Test::UploadedFile.new(File.join(Rails.root, "/spec/files/stub.exe"),"mime/type"))
          }.to raise_error
  end
  
    
end
