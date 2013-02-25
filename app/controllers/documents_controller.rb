class DocumentsController < ApplicationController
	before_filter :find_athlete, :only => [:index, :listdocs, :new, :create, :destroy]
	before_filter :authenticate_admin!, :only => [:index, :new, :create, :destroy]
  before_filter :authenticate_athlete! => :listdocs
	def index
		@documents = @athlete.documents
	end
	def new
    @document = Document.new
    respond_to do |format|
      format.html { render :html => @document}
      format.xml  { render :xml => @document }
    end
  end

  def create
    @document = @athlete.documents.create(params[:document])
    
    respond_to do |format|
      unless @document.save
        flash[:error] = 'File could not be uploaded'
      end
      format.html do
        redirect_to athlete_documents_path
      end
    end
  end

  def destroy
    @document = Document.find(params[:id])
    @document.destroy
    
    respond_to do |format|
      format.html { redirect_to athlete_documents_path }
    end
  end

  def listdocs
    @documents = @athlete.documents
  end
end
