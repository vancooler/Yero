class VenueEnteredToday < ActiveRecord::Base
  belongs_to :venue
  belongs_to :user

  #before_save :update_activity
  # :nocov:
  
  # keeps track of the latest activity of a user
  def self.enter_venue_today(venue, user)

    vnArray = VenueEnteredToday.where("venue_id = ? and user_id = ?", venue.id, user.id)
    if vnArray and vnArray.count == 0
      #if not there create a new record
      vn = VenueEnteredToday.new
      vn.venue = venue
      vn.user = user
      vn.enter_time = Time.now
      vn.save!
      return true
    elsif vnArray and vnArray.count > 0
      return false
    end

  end
  # :nocov:

  def self.five_am_cleanup(venue)
    #vn = VenueEnteredToday.where("last_activity < ? ", Time.now - 0.1.seconds)
    VenueEnteredToday.where(:venue_id => venue.id).delete_all
    return true
  end

end