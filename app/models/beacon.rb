class Beacon < ActiveRecord::Base
  # A beacon has a unique ID
  has_many :temperatures
  belongs_to :room

  before_save :default_room


  def default_room
    if self.room.nil?
      self.room = Room.create!
    end
  end
end