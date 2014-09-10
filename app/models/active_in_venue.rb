class ActiveInVenue < ActiveRecord::Base
  belongs_to :venue
  belongs_to :user


  # keeps track of the latest activity of a user
  def update_activity
    self.last_activity = Time.now
    self.save!
  end

  def venue_network
    self.venue.venue_network
  end

  def self.enter_venue(venue, user)
    #remove record in any other venue
    oldArray = ActiveInVenue.where("venue_id != ? and user_id = ?", venue.id, user.id)
    if oldArray and oldArray.count > 0
      if oldArray.count == 1
        oldArray.first.destroy
      else
        oldArray.destroy_all
      end
    end
    
    #update venue last_activity
    pArray = ActiveInVenue.where("venue_id = ? and user_id = ?", venue.id, user.id)
    if pArray and pArray.count > 0
      v = pArray.first
      v.update_activity
    else
      v = ActiveInVenue.new
      v.venue = venue
      v.user = user
      v.enter_time = Time.now
      v.last_activity = Time.now
      v.save!
    end

    #update user last_active
    user.last_active = Time.now
    user.last_activity = Time.now
    user.save!

    #enter network
    ActiveInVenueNetwork.enter_venue_network(venue.venue_network, user)

    return p
  end

  def self.leave_venue(venue, user)
    venue_network = venue.venue_network

    #change venue network activity status
    # ActiveInVenueNetwork.leave_venue_network(venue.venue_network, user)

    #delete venue activity
    v = ActiveInVenue.where("venue_id = ? and user_id = ?", venue.id, user.id)
    if v and v.count == 1
      result = v.first.destroy
    else
      result = false
    end
    return result
  end

  def self.clean_up
    aivs = ActiveInVenue.all
    aivs.each do |aiv|
      ActiveInVenue.leave_venue(aiv.venue, aiv.user)
    end
  end
end