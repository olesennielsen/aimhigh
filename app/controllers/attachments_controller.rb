class AttachmentsController < ApplicationController
  before_filter :find_athlete, :only => [:index, :show, :new, :edit, :create, :destroy]
  before_filter :authenticate_admin!

  def index
    @attachment = @athlete.attachment
  end

  def new
    @attachment = Attachment.new
    respond_to do |format|
      format.html { render :html => @attachment}
      format.xml  { render :xml => @attachment }
    end
  end

  def create
    @attachment = @athlete.create_attachment(params[:attachment])
    respond_to do |format|
      unless @attachment.save
        flash[:error] = 'File could not be uploaded'
      end
      format.html do
        redirect_to athlete_attachments_path
      end
    end
  end

  def destroy
    @attachment = Attachment.find(params[:id])
    @attachment.destroy
    
    respond_to do |format|
      format.html { redirect_to athlete_attachments_path }
    end
  end
end

 