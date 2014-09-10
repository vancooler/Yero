class ActiveInVenueNetwork < ActiveRecord::Base
  belongs_to :venue_network
  belongs_to :user

  #before_save :update_activity

  # keeps track of the latest activity of a user
  def update_activity
    self.last_activity = Time.now
  end

  def self.enter_venue_network(venue_network, user)

    #deactive record in any other venue network
    # oldArray = ActiveInVenueNetwork.where("venue_network_id != ? and user_id = ? and active_status = ?", venue_network.id, user.id, 1)
    # if oldArray and oldArray.count > 0
    #   oldArray.each do |oldvn|
    #     oldvn.active_status = 0
    #     oldvn.save!
    #   end
    # end

    vnArray = ActiveInVenueNetwork.where("venue_network_id = ? and user_id = ?", venue_network.id, user.id)
    if vnArray and vnArray.count == 0
      vn = ActiveInVenueNetwork.new
      vn.venue_network = venue_network
      vn.user = user
      vn.enter_time = Time.now
      vn.last_activity = Time.now
      vn.active_status = 1
      vn.save!
    elsif vnArray and vnArray.count == 1
      vn = vnArray.first
      vn.active_status = 1
      vn.last_activity = Time.now
      vn.save!  
    end

    return vn
  end

  def self.leave_venue_network(venue_network, user)
    vns = ActiveInVenueNetwork.where("venue_network_id = ? and user_id = ? and active_status = ?", venue_network.id, user.id, 1)
    if vns and vns.count > 0
      vns.each do |vn|
        vn.active_status = 0
        vn.save!
      end
    end
  end

  def self.everyday_cleanup
    vn = ActiveInVenueNetwork.where("last_activity < ? ", Time.now - 0.1.seconds)
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