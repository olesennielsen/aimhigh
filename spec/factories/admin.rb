# spec/factories/admin.rb
require 'faker'

FactoryGirl.define do
  factory :admin do |f|
    f.email { Faker::Internet.email }
    f.password { "qwerty" }
  end
end
