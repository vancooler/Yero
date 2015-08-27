class ActiveInVenueNetwork < ActiveRecord::Base
  belongs_to :venue_network
  belongs_to :user


  def self.enter_venue_network(venue_network, user)

    vnArray = ActiveInVenueNetwork.where("user_id = ?", user.id)
    if !vnArray.nil? and vnArray.count == 0
      #if not there create a new record
      vn = ActiveInVenueNetwork.new
      vn.venue_network = venue_network
      vn.user = user
      vn.enter_time = Time.now
      vn.last_activity = Time.now
      vn.active_status = 1
      vn.save!
    elsif !vnArray.nil? and vnArray.count == 1
      #if already in some venue network, just update it
      vn = vnArray.first
      vn.venue_network = venue_network
      vn.active_status = 1
      vn.last_activity = Time.now
      vn.save!  
    end

    return vn
  end


  def self.five_am_cleanup(venue_network)
    ActiveInVenueNetwork.where(:venue_network_id => venue_network.id).delete_all

    # cleanup active_in_venue records in this venue_network
    venues = Venue.where(:venue_network_id => venue_network.id)
    venues.each do |v|
      ActiveInVenue.five_am_cleanup(v)
      VenueEnteredToday.five_am_cleanup(v)
    end
    return true
  end

end