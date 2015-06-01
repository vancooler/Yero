class GreetingMessage < ActiveRecord::Base


  # has_many :venue_avatars
  belongs_to :weekday
  belongs_to :venue
  # accepts_nested_attributes_for :greeting_avatars, allow_destroy: true


end