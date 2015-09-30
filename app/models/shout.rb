class Shout < ActiveRecord::Base
  has_many :shout_comments, dependent: :destroy
  has_many :shout_votes, dependent: :destroy
  belongs_to :user
  reverse_geocoded_by :latitude, :longitude

  # total upvote of a shout
  def total_upvotes
  	self.shout_votes.where(upvote: true).length - self.shout_votes.where(upvote: false).length
  end


  def change_vote(current_user, upvote)
  	sv = ShoutVote.find_by_shout_id_and_user_id(self.id, current_user.id)
  	if !sv.nil?
  		result = sv.update(upvote: upvote)
  		event = 'change_shout_vote'
  		data = {
  			user_id: current_user.id,
  			vote:    (upvote ? "up" : "down")
  		}

  	else
  		sv = ShoutVote.new(user_id: current_user.id, shout_id: self.id)
  		sv.upvote = upvote
  		result = sv.save
  		event = 'add_shout_vote'
  		data = {
  			user_id: current_user.id,
  			vote:    (upvote ? "up" : "down")
  		}
  	end
  	return {result: result, event: event, data: data}

  end

  # Create a new shout
  def self.create_shout(current_user, body, allow_nearby)
  	shout = Shout.new
  	if current_user.current_venue.nil?
  		shout.latitude = current_user.latitude
  		shout.longitude = current_user.longitude
  	else
  		shout.venue_id = current_user.current_venue.id 
  		shout.latitude = current_user.current_venue.latitude
  		shout.longitude = current_user.current_venue.longitude
  	end
  	shout.body = body
  	shout.allow_nearby = allow_nearby
  	shout.user_id = current_user.id
  	result = shout.save
  	if result
	  	return shout
    else
    	return false
    end
  end

  # collect shouts in a venue or near users
  def self.collect_shouts_nearby(current_user, venue)
  	if venue.nil?
  		shouts = Shout.where(allow_nearby: true).where("created_at >= ?", 5.days.ago).near([current_user.latitude, current_user.longitude], 60, units: :km).order("created_at DESC")
  	else
  		venue_id = venue
  		shouts = Shout.where(venue_id: venue_id).where("created_at >= ?", 5.days.ago).order("created_at DESC")
  	end
  	return shouts
  end


  # return shouts list
  def self.list(current_user, order_by, venue)
  	shouts = Shout.collect_shouts_nearby(current_user, venue)
  	case order_by
  	when 'new'
  		# shouts order by created_at
  	when 'hot'
  		# shouts order by upvote
  		shouts.sort_by{|s| s.total_upvotes}.reverse
  	end

  	return shouts
  end

end