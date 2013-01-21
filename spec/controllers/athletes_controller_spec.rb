require 'spec_helper'

describe AthletesController do
  before do
    controller.stub(:athlete_filter).and_return true 
  end
  
  describe "POST exportcal" do
    it "returns a file when hit exportcal" do
      @attachment = FactoryGirl.create(:attachment)
      @athlete = FactoryGirl.create(:athlete, :attachment => @attachment)
      date = DateTime.now - 1.days
      post :exportcal, :athlete_id => @athlete.id, :from => {:day => date.day, :year => date.year, :month => date.month}
      response.header.should have_text('calendar') 
    end
    
    it "should not export if no attachment" do
      @athlete = FactoryGirl.create(:athlete, :attachment => @attachment)
      date = DateTime.now - 1.days
      post :exportcal, :athlete_id => @athlete.id, :from => {:day => date.day, :year => date.year, :month => date.month}
      response.should redirect_to(athlete_path(@athlete))
    end
  end
  
  describe "POST exportpdf" do
    it "returns a file when hit exportpdf" do
      @attachment = FactoryGirl.create(:attachment)
      @athlete = FactoryGirl.create(:athlete, :attachment => @attachment)
      date = DateTime.now - 1.days
      post :exportpdf, :athlete_id => @athlete.id, :from => {:day => date.day, :year => date.year, :month => date.month}
      response.header.should have_text('pdf') 
    end

    it "should not export if no attachment" do
      @athlete = FactoryGirl.create(:athlete, :attachment => @attachment)
      date = DateTime.now - 1.days
      post :exportcal, :athlete_id => @athlete.id, :from => {:day => date.day, :year => date.year, :month => date.month}
      response.should redirect_to(athlete_path(@athlete))
    end
  end
end
