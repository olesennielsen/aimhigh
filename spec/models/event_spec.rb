# spec/models/event.rb
require 'spec_helper'

describe Event do
  it "has a valid factory" do
    FactoryGirl.create(:event).should be_valid 
  end
  it "is invalid without a title" do 
    FactoryGirl.build(:event, title: nil).should_not be_valid
  end
  it "has computed start time" do
  	@event = FactoryGirl.create(:event)
  	@event.starts_at.should == DateTime.now.to_date.to_datetime
  end
  it "has computed end time" do
  	@event = FactoryGirl.create(:event)
  	@event.ends_at.should == (DateTime.now.to_date.to_datetime + @event.duration)
  end
end
