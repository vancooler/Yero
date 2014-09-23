class VenueEnteredToday < ActiveRecord::Base
  belongs_to :venue
  belongs_to :user

  #before_save :update_activity

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
      return true # TODO: change to false to make sure only one notification for user in each venue perday
    end

  end



  def self.everyday_cleanup
    #vn = VenueEnteredToday.where("last_activity < ? ", Time.now - 0.1.seconds)
    vn = VenueEnteredToday.all
    if vn and vn.count > 1
      result = vn.destroy_all
    elsif vn and vn.count == 1
      result = vn.first.destroy
    else
      result = false
    end
    return result
  end

end