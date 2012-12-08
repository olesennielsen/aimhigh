require 'spec_helper'

describe "Events" do
  include Warden::Test::Helpers
  Warden.test_mode!
  describe "CREATE /events" do
    it "wrong filetype generate error" do
      @athlete = FactoryGirl.create(:athlete)
      admin = FactoryGirl.create(:admin)
      login_as(admin, :scope => :admin)
      @attachment = FactoryGirl.create(:attachment, :athlete_id => @athlete.id)
      visit new_athlete_attachment_path(:athlete_id => @athlete.id)
      attach_file "attachment[file]", File.join(Rails.root, '/spec/files/stub.xls')
      click_button 'Create Attachment'
      page.should have_selector(:id, 'flash_error')      
    end

    it "Uploaded file should be visible in the view" do
      @athlete = FactoryGirl.create(:athlete)
      admin = FactoryGirl.create(:admin)
      login_as(admin, :scope => :admin)
      @attachment = FactoryGirl.create(:attachment, :athlete_id => @athlete.id)
      visit new_athlete_attachment_path(:athlete_id => @athlete.id)
      attach_file "attachment[file]", File.join(Rails.root, '/spec/files/stub.xlsx')
      click_button 'Create Attachment'
      page.should have_content('stub.xlsx')
    end
  end
end
