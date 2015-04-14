class Beacon < ActiveRecord::Base
  # A beacon has a unique ID

  has_many :temperatures, dependent: :destroy
  belongs_to :venue

  before_save :default_room


  def default_room
    if self.room.nil?
      self.room = Room.create!
    end
  end
end