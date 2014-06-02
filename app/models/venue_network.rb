class VenueNetwork < ActiveRecord::Base
  has_many :venues
  has_many :participants, through: :venues
end