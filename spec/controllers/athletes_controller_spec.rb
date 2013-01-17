require 'spec_helper'

describe AthletesController do
  before do
    controller.stub(:authenticate_admin!).and_return true
    @athlete = FactoryGirl.create(:athlete)
  end
end
