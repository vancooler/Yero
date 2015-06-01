# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"].each do |day|
  if Weekday.find_by_weekday_title(day).blank?
  	w = Weekday.new
  	w.weekday_title = day
  	w.save!
  end
end