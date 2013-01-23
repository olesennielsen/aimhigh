describe AttachmentUploader do
  include CarrierWave::Test::Matchers

  before do
    AttachmentUploader.enable_processing = true
    @attachment = FactoryGirl.create(:attachment)
    @uploader = AttachmentUploader.new(@attachment, :file)    
  end

  after do
    AttachmentUploader.enable_processing = false
    @uploader.remove!
  end

  context 'file extensions' do
    it "not allow exe files" do
      expect {@uploader.store!(File.open(File.join(Rails.root, '/spec/files/stub.exe')))}.to raise_error   
    end
    
    it "Do not allow excel files: xls (too old format)" do
      expect {@uploader.store!(File.open(File.join(Rails.root, '/spec/files/stub.xls')))}.to raise_error
    end
      
    it "allow excel files: xlsx" do
       expect {@uploader.store!(File.open(File.join(Rails.root, '/spec/files/stub.xlsx')))}.to_not raise_error     
     end
     
  end

end