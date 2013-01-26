require 'csv'
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


admin = Admin.create(:email => "aimhigh@aimhigh.com", :password => "aimhigh")
puts admin
athlete = Athlete.create(:email => "athlete@athlete.com", :password => "athlete")
puts athlete
# Seed the static session_descriptions table
SessionDescription.delete_all
csv = CSV.open(File.join(Rails.root, 'db/session_desc.csv'))
csv.each do |row|
  if !row[0].nil? then
    SessionDescription.create(:name => row[0], :time => row[2], :description => row[4])
  end
end

FocusArea.delete_all
FocusArea.create(:code => "Max", :name => "Max")
FocusArea.create(:code => "AT", :name => "AT")
FocusArea.create(:code => "Sub-AT", :name => "Sub-AT")
FocusArea.create(:code => "IG", :name => "Intensiv Grundzone")
FocusArea.create(:code => "GZ", :name => "Grundzone")
FocusArea.create(:code => "Restitution", :name => "Restitution")
FocusArea.create(:code => "Power", :name => "Power")
FocusArea.create(:code => "FS", :name => "Funtionel Styrke")

