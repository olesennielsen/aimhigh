require 'spec_helper'

describe AttachmentsController do
  before do
    controller.stub(:authenticate_admin!).and_return true
    @athlete = FactoryGirl.create(:athlete)
    
  end
  describe "GET index" do
    it "assigns all attachments to @attachments" do
      @attachment = FactoryGirl.create(:attachment, :athlete_id => @athlete.id)
      get :index, :athlete_id => @athlete.id
      expect(assigns(:attachment)).to eq(@attachment)
    end
  end

  describe "POST create" do
    it "POST create and redirecting" do
      @attachment = FactoryGirl.create(:attachment, :athlete_id => @athlete.id)
      post :create, :attachment => FactoryGirl.attributes_for(:attachment), :athlete_id => @athlete.id
      response.should be_redirect
    end

    it "If no existing attachment: Attachment increase by one" do
      expect{ post :create, :athlete_id => @athlete.id, :attachment => FactoryGirl.attributes_for(:attachment) }.to change(Attachment,:count).by(1)
    end
        
    it "should delete all the events when overwriting attachment" do
      @attachment = FactoryGirl.create(:attachment, :athlete_id => @athlete.id)
      post :create, :attachment => FactoryGirl.attributes_for(:attachment), :athlete_id => @athlete.id  
    end
      
    it "Ensures that the the right xlsx attachment will somewhat alter the event table" do
      expect{ post :create, :athlete_id => @athlete.id, :attachment => FactoryGirl.attributes_for(:attachment) }.to change{Event.all}
    end
  end
end
