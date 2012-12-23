require 'spec_helper'

describe SessionDescription do
  it "has valid factory" do
    session_description = FactoryGirl.create(:session_description).should be_valid
  end
end
