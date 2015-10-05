class Shout < ActiveRecord::Base
  has_many :shout_comments, dependent: :destroy
  has_many :shout_votes, dependent: :destroy
  has_many :shout_report_histories, dependent: :destroy, as: :reportable
  belongs_to :user
  reverse_geocoded_by :latitude, :longitude


# 
# Point system:

# 2/post

# 4/upvote for OP
# 2/upvote for others
# 0/self

# Voter 1 for up/down



  # total upvote of a shout
  def total_upvotes
  	self.shout_votes.where(upvote: true).length - self.shout_votes.where(upvote: false).length
  end


  def change_vote(current_user, upvote)
  	sv = ShoutVote.find_by_shout_id_and_user_id(self.id, current_user.id)
  	if !sv.nil?
  		old_upvote = sv.upvote
  		result = sv.update(upvote: upvote)
  		if result and old_upvote and !(upvote.to_s == "true" or upvote.to_s == '1') 
  			if self.user_id != current_user.id
				self.user.update(point: self.user.point-2)
			end
  		end
  		if result and !old_upvote and (upvote.to_s == "true" or upvote.to_s == '1') 
  			if self.user_id != current_user.id
				self.user.update(point: self.user.point+2)
			end
  		end
  		event = 'change_shout_vote'
  		data = {
  			user_id: current_user.id,
  			vote:    (upvote ? "up" : "down")
  		}

  	else
  		sv = ShoutVote.new(user_id: current_user.id, shout_id: self.id)
  		sv.upvote = upvote
  		result = sv.save
  		if result
  			# update points
  			if (upvote.to_s == "true" or upvote.to_s == '1') 
  				if self.user_id != current_user.id
  					puts "REALLY?"
  					puts upvote.to_s
  					self.user.update(point: self.user.point+2)
  				end
  			end
			current_user.update(point: current_user.point+1)
  		end
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
  		current_user.update(point: current_user.point+2)
	  	return shout
    else
    	# :nocov:
    	return false
    	# :nocov:
    end
  end

  # collect shouts in a venue or near users
  def self.collect_shouts_nearby(current_user, venue)
  	black_list = BlockUser.blocked_user_ids(current_user.id)
  	content_black_list = ShoutReportHistory.where(reporter_id: current_user.id).where(reportable_type: 'shout').map(&:reportable_id)
  	if venue.nil?
  		current_venue = current_user.current_venue
  		if !current_venue.nil?
  			same_venue_shouts = Shout.where.not(id: content_black_list).where.not(user_id: black_list).where(venue_id: current_venue.id).where("created_at >= ?", 7.days.ago)
  		else
  			same_venue_shouts = []
  		end
  		shouts = Shout.where.not(id: content_black_list).where.not(user_id: black_list).where(allow_nearby: true).where("created_at >= ?", 7.days.ago).near([current_user.latitude, current_user.longitude], 90000, units: :km)
  		shouts = shouts | same_venue_shouts
  		
  	else
  		venue_id = venue
  		shouts = Shout.where.not(id: content_black_list).where.not(user_id: black_list).where(venue_id: venue_id).where("created_at >= ?", 7.days.ago)
  	end
  	return shouts
  end


  # return shouts list
  def self.list(current_user, order_by, venue, page, per_page)
  	result = Hash.new
  	time_0 = Time.now
  	shouts = Shout.collect_shouts_nearby(current_user, venue)
  	case order_by
  	when 'new'
  		# shouts order by created_at
  		shouts = shouts.sort_by{|s| s.created_at}.reverse
  	when 'hot'
  		# shouts order by upvote
  		shouts = shouts.sort_by(&:total_upvotes).reverse
  	end
  	if !page.nil? and !per_page.nil? and per_page > 0 and page >= 0
        pagination = Hash.new
        pagination['page'] = page - 1
        pagination['per_page'] = per_page
        pagination['total_count'] = shouts.length
        result['pagination'] = pagination
        shouts = Kaminari.paginate_array(shouts).page(page).per(per_page) if !shouts.nil?
    end

  	time_1 = Time.now
  	final_result = Shout.shouts_json(current_user, shouts)
  	time_2 = Time.now

  	puts "TOTAL: " + final_result.count.to_s
  	puts "TIME: "
  	puts (time_1-time_0).inspect
  	puts (time_2-time_1).inspect
  	result['shouts'] = final_result
  	return result
  end

  # convert to json structure
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

  # report a shout
  def report(user, type)
  	history = ShoutReportHistory.where(reportable_type: 'shout', reportable_id: self.id, shout_report_type_id: type)
  	if history.blank?
  		frequency = 1
  	else
  		frequency = history.first.frequency + 1
  	end

  	srh = ShoutReportHistory.create(reportable_type: 'shout', reportable_id: self.id, reporter_id: user.id, shout_report_type_id: type, frequency: frequency)
  	if srh
  		history.update_all(frequency: frequency)
  	end
  end

  # :nocov:
  def self.random_generate

  	(1..100).each do |i|
  		offset = rand(User.count)
		rand_user = User.offset(offset).first
		shout = Shout.create_shout(rand_user, (0...8).map { (65 + rand(26)).chr }.join, true)
		(1..i%8).each do |k|
			upvote = [true, true, false]
			offset_3 = rand(User.count)
			rand_user_3 = User.offset(offset_3).first
			shout.change_vote(rand_user_3, upvote.sample)
		end
		comments_count = i/100*100 + 1
		(1..comments_count).each do |j|
			offset_2 = rand(User.count)
			rand_user_2 = User.offset(offset_2).first
			shout_comment = ShoutComment.create_shout_comment(rand_user_2, (0...8).map { (65 + rand(26)).chr }.join, shout.id)
			# upvotes
			(1..i%8).each do |k|
				upvote = [true, true, false]
				offset_3 = rand(User.count)
				rand_user_3 = User.offset(offset_3).first
				shout_comment.change_vote(rand_user_3, upvote.sample)

			end
		end
	end
  end

  def self.random_report
	(1..100).each do |i|
		if (i%30 == 5)
	  		offset = rand(User.count)
			rand_user = User.offset(offset).first
			rand_type = ShoutReportType.all.map(&:id).sample
			shout = Shout.find(i)
			shout.report(rand_user, rand_type)
			shout_comment = ShoutComment.find(i+4)
			shout_comment.report(rand_user, rand_type)
		end
	end
  end
  # :nocov:

end