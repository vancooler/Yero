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
  		shout.allow_nearby = true
  	else
  		shout.venue_id = current_user.current_venue.id 
  		shout.latitude = current_user.current_venue.latitude
  		shout.longitude = current_user.current_venue.longitude
	  	shout.allow_nearby = allow_nearby
  	end
  	shout.body = body
  	shout.user_id = current_user.id
  	result = shout.save
  	if result
	  	return shout
    else
    	# :nocov:
    	return false
    	# :nocov:
    end
  end

  # collect shouts in a venue or near users
  def self.collect_shouts_nearby(current_user, venue)
  	if venue.nil?
  		current_venue = current_user.current_venue
  		if !current_venue.nil?
  			same_venue_shouts = Shout.where(venue_id: current_venue.id).where("created_at >= ?", 5.days.ago)
  		else
  			same_venue_shouts = []
  		end
  		shouts = Shout.where(allow_nearby: true).where("created_at >= ?", 5.days.ago).near([current_user.latitude, current_user.longitude], 60, units: :km)
  		shouts = shouts | same_venue_shouts
  		
  	else
  		venue_id = venue
  		shouts = Shout.where(venue_id: venue_id).where("created_at >= ?", 5.days.ago)
  	end
  	return shouts
  end


  # return shouts list
  def self.list(current_user, order_by, venue)
  	shouts = Shout.collect_shouts_nearby(current_user, venue)
  	case order_by
  	when 'new'
  		# shouts order by created_at
  		shouts = shouts.sort_by{|s| s.created_at}.reverse
  	when 'hot'
  		# shouts order by upvote
  		shouts = shouts.sort_by(&:total_upvotes).reverse
  	end

  	return Shout.shouts_json(current_user, shouts)
  end

  def self.shouts_json(current_user, shouts)
  	shout_upvoted_ids = ShoutVote.where(user_id: current_user.id).where(upvote: true).map(&:shout_id)
  	shout_downvoted_ids = ShoutVote.where(user_id: current_user.id).where(upvote: false).map(&:shout_id)
  	result = Jbuilder.encode do |json|
      json.array! shouts do |shout|
        json.id 			shout.id
        json.body 			shout.body
        json.latitude 		shout.latitude
        json.longitude 		shout.longitude
        json.timestamp 		shout.created_at.to_i
        json.total_votes 	shout.total_upvotes
        json.upvoted 		(shout_upvoted_ids.include? shout.id)
        json.downvoted 		(shout_downvoted_ids.include? shout.id)
        json.replies_count 	shout.shout_comments.length
        json.author_id 		shout.user_id
      end         
    end
    result = JSON.parse(result).delete_if(&:empty?)
    return result 
  end

end