require 'spec_helper'

describe Attachment do
  
  it "has a valid factory" do
    FactoryGirl.create(:attachment).should be_valid 
  end
    
end
