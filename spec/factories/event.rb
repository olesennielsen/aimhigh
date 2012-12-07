# spec/factories/event.rb
require 'faker'

FactoryGirl.define do
  factory :event do |f|
    f.title { Faker::Name.title }
    f.starts_at { DateTime.now }
    f.ends_at { DateTime.now + 2.hours }
    f.all_day { false }
    f.description { Faker::Lorem.characters(200) }
    f.attachment_id { 1 }
  end
end
