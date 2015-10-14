class FavouriteVenue < ActiveRecord::Base
  belongs_to :venue
  belongs_to :user


  def self.add_record(venue, user)
  	fv = FavouriteVenue.find_by_venue_id_and_user_id(venue.id, user.id)
  	if fv.nil?
  		FavouriteVenue.create(venue_id: venue.id, user_id: user.id)
  	end
  end

  def self.remove_record(venue, user)
  	fv = FavouriteVenue.find_by_venue_id_and_user_id(venue.id, user.id)
  	if !fv.nil?
  		fv.destroy
  	end
  end
end