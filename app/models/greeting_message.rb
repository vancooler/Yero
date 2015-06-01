class GreetingMessage < ActiveRecord::Base


  # has_many :venue_avatars
  belongs_to :weekday
  belongs_to :venue

end