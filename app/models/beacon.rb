class Beacon < ActiveRecord::Base
  # A beacon has a unique ID
  # The beacon name identifies the City_venue_room_#_code
  # Example: Vancouver-Aubar-Dance-01-123123 

  has_many :temperatures
  belongs_to :room

  before_save :default_room


  def default_room
    if self.room.nil?
      self.room = Room.create!
    end
  end
end