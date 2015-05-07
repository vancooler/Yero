class VenueNetwork < ActiveRecord::Base
  # The structure of a Venue Network is as follows
  #
  #                  VenueNetwork (ie. Vancouver)
  #                             | 1..n
  #                       Venues (ie. Aubar)
  #                             | 1..n
  #                       ____Rooms___
  #                      | 1..n      | 1..n
  #                Participants   Beacons
  #
  # Each room has 1 or more beacons
  # Each Participant belongs to a room, and subsequently to a VenueNetwork

  has_many :venues, dependent: :destroy
  # has_many :participants, through: :venues
  # validates_presence_of :city, :area, :name  #cant use this for automated beacon initialization
  validates_uniqueness_of :name
end