class ActiveInVenue < ActiveRecord::Base
  belongs_to :venue
  belongs_to :beacon
  belongs_to :user


  # keeps track of the latest activity of a user
  def update_activity
    self.last_activity = Time.now
    return self.save!
  end

  def venue_network
    self.venue.venue_network
  end

  def self.enter_venue(venue, user, beacon)
    #remove record in any other venue
    oldArray = ActiveInVenue.where("venue_id != ? and user_id = ?", venue.id, user.id)

    # if oldArray and oldArray.count > 0
    #   if oldArray.count == 1 and !oldArray.first.nil?
    #     oldArray.first.destroy
    #   else
    #     oldArray.destroy_all
    #   end
    # end
    ActiveInVenue.where("venue_id != ? and user_id = ?", venue.id, user.id).delete_all
    
    #update venue last_activity
    pArray = ActiveInVenue.where("venue_id = ? and user_id = ?", venue.id, user.id)
    if !pArray.blank?
      v = pArray.first
      v.beacon = beacon
      result = v.update_activity
    else
      v = ActiveInVenue.new
      v.venue_id = venue.id
      v.user_id = user.id
      v.enter_time = Time.now
      v.beacon_id = beacon.id
      v.last_activity = Time.now
      result = v.save!
    end


    #enter network
    ActiveInVenueNetwork.enter_venue_network(venue.venue_network, user)

    if result
      VenueEntry.unique_enter(venue, user)
    end
    return result
  end

  def self.leave_venue(venue, user)
    # venue_network = venue.venue_network
    # if !venue.nil?
    #   if venue.is_a? Venue
    #     venue_id = venue.id
    #   elsif venue.is_a? Integer
    #     venue_id = venue
    #   else
    #     venue_id = 0
    #   end
    # else
    #   venue_id = 0
    # end

    if !user.nil?
      if user.is_a? User
        user_id = user.id
      end
    end

    #delete venue activity
    ActiveInVenue.where("user_id = ?", user_id).delete_all
    return true
  end

  def self.five_am_cleanup(venue, people_array)
    ActiveInVenue.where(:venue_id => venue.id).where(user_id: people_array).delete_all
  end
end