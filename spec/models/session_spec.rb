require 'spec_helper'

describe Session do
  it "has valid factory" do
    session = FactoryGirl.create(:session).should be_valid
  end
end
