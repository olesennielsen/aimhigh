require 'csv'
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


Admin.create(:email => "aimhigh@aimhigh.com", :password => "aimhigh")
Athlete.create(:email => "athlete@athlete.com", :password => "athlete")

# Seed the static session_descriptions table
SessionDescription.delete_all
csv = CSV.open(File.join(Rails.root, 'db/session_desc.csv'))
csv.each do |row|
  if !row[0].nil? then
    SessionDescription.create(:name => row[0], :time => row[2], :description => row[4])
  end
end
