# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attachment do |f|
    f.title { Faker::Name.name }
    f.file { Rack::Test::UploadedFile.new(File.join(Rails.root, "/spec/files/stub.xlsx"),"mime/type") }
    f.athlete_id {1}
  end
end
