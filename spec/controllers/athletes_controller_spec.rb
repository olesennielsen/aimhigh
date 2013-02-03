require 'spec_helper'

describe AthletesController do
  include Devise::TestHelpers
  before do
    @athlete = FactoryGirl.create(:athlete)
    sign_in :athlete, @athlete
  end
  
  describe "POST exportcal" do
    it "returns a file when hit exportcal" do
      @attachment = FactoryGirl.create(:attachment, :athlete_id => @athlete.id)
      @athlete.attachment = @attachment
      session[:athlete_id] = @athlete.id
      post :exportcal, :athlete_id => @athlete.id, :start_date_cal => DateTime.now - 1.days, :end_date_cal => DateTime.now
      response.header.should have_text('calendar') 
    end
    
    it "should not export if no attachment" do
      date = DateTime.now - 1.days
      post :exportcal, :athlete_id => @athlete.id, :start_date_cal => DateTime.now - 1.days, :end_date_cal => DateTime.now
      response.should redirect_to(athlete_path(@athlete))
    end
  end
  
  describe "POST exportpdf" do
    it "returns a file when hit exportpdf" do
      @attachment = FactoryGirl.create(:attachment, :athlete_id => @athlete.id)
      @athlete.attachment = @attachment
      post :exportpdf, :athlete_id => @athlete.id, :start_date_pdf => DateTime.now - 1.days, :end_date_pdf => DateTime.now
      response.header.should have_text('pdf') 
    end

    it "should not export if no attachment" do
      date = DateTime.now - 1.days
      post :exportcal, :athlete_id => @athlete.id, :start_date_pdf => DateTime.now - 1.days, :end_date_pdf => DateTime.now
      response.should redirect_to(athlete_path(@athlete))
    end
  end
end
