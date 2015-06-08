class GreetingPoster < ActiveRecord::Base


  # has_many :venue_avatars
  belongs_to :greeting_message
  mount_uploader :avatar, GreetingPosterUploader


end