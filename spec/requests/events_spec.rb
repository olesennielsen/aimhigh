require 'spec_helper'

describe "Events" do
  include Warden::Test::Helpers
  Warden.test_mode!
  describe "CREATE /events" do
    it "if existing attachment: alert the user" do
      @athlete = FactoryGirl.create(:athlete)
      admin = FactoryGirl.create(:admin)
      login_as(admin, :scope => :admin)
      @attachment = FactoryGirl.create(:attachment, :athlete_id => @athlete.id)
      visit new_athlete_attachment_path(:athlete_id => @athlete.id)
      click_button 'Create Attachment'
      
    end

    it "if no existing attachment: do not alert the user" do

    end
  end
end
