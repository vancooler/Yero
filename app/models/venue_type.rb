class VenueType < ActiveRecord::Base
  has_many :venues
  validates_presence_of :name
end
