class Traffic < ActiveRecord::Base
  # This is won't be used until later when we want to track
  # the traffic in a given room of a Venue

  belongs_to :room
  belongs_to :beacon
  belongs_to :user
end