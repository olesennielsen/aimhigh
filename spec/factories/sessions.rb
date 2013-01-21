# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :session do
    title "Fake::Name.name"
    session_description_id Random.rand(5..50)
    focus "Max"
  end
end
