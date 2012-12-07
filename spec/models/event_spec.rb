# spec/models/event.rb
require 'spec_helper'

describe Event do
  it "has a valid factory" do
    FactoryGirl.create(:event).should be_valid 
  end
  it "is invalid without a title" do 
    FactoryGirl.build(:event, title: nil).should_not be_valid
  end
end
