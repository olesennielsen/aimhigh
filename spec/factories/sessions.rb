# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :session do
    title "Fake::Name.name"
    description "Fake::Lorem.sentence"
    focus "Max"
  end
end
