# spec/models/admin.rb
require 'spec_helper'

describe Admin do
  it "has a valid factory" do
    FactoryGirl.create(:admin).should be_valid 
  end
  it "is invalid without a email" do 
    FactoryGirl.build(:admin, email: nil).should_not be_valid
  end
  it "email is unique" do
    FactoryGirl.create(:admin, :email => "hest@hest.dk")
    FactoryGirl.build(:admin, :email => "hest@hest.dk").should_not be_valid
  end
end
