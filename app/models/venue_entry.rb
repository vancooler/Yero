class VenueEntry< ActiveRecord::Base
  belongs_to :venue
  belongs_to :user

  def self.unique_enter(venue, user)
    ve = VenueEntry.find_by_user_id_and_venue_id(user.id, venue.id)
    if ve.nil?
      VenueEntry.create(user_id: user.id, venue_id: venue.id)
    end
  end

end