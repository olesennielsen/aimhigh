require 'spec_helper'

describe Athlete do
  it "has a valid factory" do
    FactoryGirl.create(:athlete).should be_valid 
  end
  it "is invalid without a email" do 
    FactoryGirl.build(:athlete, email: nil).should_not be_valid
  end
  it "email is unique" do
    FactoryGirl.create(:athlete, :email => "hest@hest.dk")
    FactoryGirl.build(:athlete, :email => "hest@hest.dk").should_not be_valid
  end
end
