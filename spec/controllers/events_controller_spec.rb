require 'spec_helper'

describe EventsController do
  before do
    controller.stub(:authenticate_admin!).and_return true
    @athlete = FactoryGirl.create(:athlete)
    @attachment = FactoryGirl.create(:attachment, :athlete_id => @athlete.id)
    @event = FactoryGirl.create(:event, :attachment_id => @attachment.id)
  end

  describe "GET index" do
    it "assigns all events between the start and end to @events" do
      get :index, :athlete_id => @athlete.id, :start => DateTime.now - 1.days, :end => DateTime.now, :format => :js
      response.body.should  eq([@event].to_json)
    end
  end
  
  describe "GET show" do
    it "show the right event" do
      get :show, :athlete_id => @athlete.id, :id => @event.id
      expect(assigns(:event)).to eq(@event) 
    end  
  end

end
