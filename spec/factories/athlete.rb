# spec/factories/athlete.rb
require 'faker'

FactoryGirl.define do
  factory :athlete do |f|
    f.email { Faker::Internet.email }
    f.password { "qwerty" }
  end
end
