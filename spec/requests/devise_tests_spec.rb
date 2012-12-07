require 'spec_helper'

describe "DeviseTests" do
  include Warden::Test::Helpers
  Warden.test_mode!
  it "admin is able to invite people" do
    admin = FactoryGirl.create(:admin)
    login_as(admin, :scope => :admin)
    visit new_athlete_invitation_path
    fake_email = Faker::Internet.email
    fill_in "athlete[email]", :with => fake_email
    click_button 'Send an invitation'
    last_email.to.should include( fake_email )
  end
  
  it "athlete is unable to invite" do
    admin = FactoryGirl.create(:athlete)
    login_as(admin, :scope => :athlete)
    visit new_athlete_invitation_path
    page.should_not have_content("invitation")
  end
  
end
