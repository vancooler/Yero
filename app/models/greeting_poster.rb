class GreetingPoster < ActiveRecord::Base


  # has_many :venue_avatars
  belongs_to :greeting_message

end