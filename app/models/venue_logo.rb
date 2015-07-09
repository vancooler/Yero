class VenueLogo < ActiveRecord::Base


  # has_many :venue_avatars
  belongs_to :venue
  mount_uploader :avatar, VenueLogoUploader


end