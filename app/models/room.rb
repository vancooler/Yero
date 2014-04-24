class Room < ActiveRecord::Base
  belongs_to :venue
  has_many :beacons
  has_many :participants
end