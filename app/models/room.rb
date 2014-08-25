class Room < ActiveRecord::Base
  belongs_to :venue
  has_many :beacons, dependent: :destroy
  has_many :participants, dependent: :destroy
end