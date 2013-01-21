require 'spec_helper'

describe Session do
  it "has valid factory" do
    session = FactoryGirl.create(:session, :session_description_id => Random.rand(5..50)
).should be_valid
  end
end
