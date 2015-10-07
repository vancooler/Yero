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

  # total vote of a shout
  def total_votes
  	self.shout_votes.length
  end

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

			# push notification to author
			self.votes_notification
  		end
  		event = 'add_shout_vote'
  		data = {
  			user_id: current_user.id,
  			vote:    (upvote ? "up" : "down")
  		}
  	end
  	current_upvotes = self.total_upvotes
  	user_ids = self.permitted_users_id
  	shout_id = self.id
  	
  	# pusher
	# users in shout_id channel
	channel = 'public-shout-' + shout_id.to_s
	if Rails.env == 'production'
		# :nocov:
		Pusher.delay.trigger(channel, 'Shout upvotes changed', {total_upvotes: current_upvotes, shout_id: self.id})
		# :nocov:
	end
	# users can access this shout
	user_channels = Array.new
	user_ids.each do |id|
		channel = 'private-user-' + id.to_s
		user_channels << channel
	end
	if !user_channels.empty?
		if Rails.env == 'production'
			# :nocov:
			Pusher.delay.trigger(user_channels, 'Shout upvotes changed', {total_upvotes: current_upvotes, shout_id: self.id})
			# :nocov:
		end
	end
  	return {result: result, event: event, data: data}

  end


  # activity and notification related to total votes
  # :nocov:
  def votes_notification
  	type = 0
	case self.total_votes
	when 10
		type = 310
	when 25
		type = 311
	when 50
		type = 312
	when 100
		type = 313
	when 250
		type = 314
	when 500
		type = 315
	when 1000
		type = 316
	when 2500
		type = 317
	when 5000
		type = 318
	end
	if type > 0
		op_user_id = self.user_id
		# create activity 
		current_time = Time.now
		if Rails.env == 'production'
			RecentActivity.delay.add_activity(op_user_id, type.to_s, nil, nil, "shout-votes-"+self.total_votes.to_s+"-"+op_user_id.to_s+"-"+current_time.to_i.to_s, "yero://shouts/"+self.id.to_s, 'You received ' + self.total_votes.to_s + ' votes on your shout "'+self.body.truncate(23, separator: /\s/)+'"')
			WhisperNotification.delay.send_notification_330_level(op_user_id, type, self.total_votes, self.id)
		end	
	end 
  end
  # :nocov:

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
  		# pusher
  		user_ids = shout.permitted_users_id
	  	shout_id = shout.id
	  	
		# users can access this shout
		user_channels = Array.new
		user_ids.each do |id|
			channel = 'private-user-' + id.to_s
			user_channels << channel
		end
		if !user_channels.empty?
			shout_json = {
				id: 			shout.id,
		        body: 			shout.body,
		        latitude: 		shout.latitude,
		        longitude: 		shout.longitude,
		        timestamp: 		shout.created_at.to_i,
		        total_upvotes: 	0,
		        upvoted: 		false,
		        downvoted: 		false,
		        replies_count: 	0,
		        author_id: 		shout.user_id
			}
			if Rails.env == 'production'
				# :nocov:
				Pusher.delay.trigger(user_channels, 'Create shout', {shout: shout_json})
				# :nocov:
			end
		end
	  	return shout
    else
    	# :nocov:
    	return false
    	# :nocov:
    end
  end

  # collect shouts in a venue or near users
  def self.collect_shouts_nearby(current_user, venue, my_shouts, my_comments)
  	black_list = BlockUser.blocked_user_ids(current_user.id)
  	content_black_list = ShoutReportHistory.where(reporter_id: current_user.id).where(reportable_type: 'shout').map(&:reportable_id)
  	if !my_comments.nil? and (my_comments.to_s == '1' or my_comments.to_s == 'true')
  		comments = ShoutComment.where(user_id: current_user.id).map(&:shout_id)
  		shouts = Shout.where(id: comments)
  		
  	elsif !my_shouts.nil? and (my_shouts.to_s == '1' or my_shouts.to_s == 'true')
  		shouts = Shout.where(user_id: current_user.id)
  	else
	  	if venue.nil?
	  		current_venue = current_user.current_venue
	  		if !current_venue.nil?
	  			same_venue_shouts = Shout.where.not(id: content_black_list).where.not(user_id: black_list).where(venue_id: current_venue.id).where("created_at >= ?", 7.days.ago)
	  		else
	  			same_venue_shouts = []
	  		end
	  		shouts = Shout.where.not(id: content_black_list).where.not(user_id: black_list).where(allow_nearby: true).where("created_at >= ?", 7.days.ago).near([current_user.latitude, current_user.longitude], 60, units: :km)
	  		shouts = shouts | same_venue_shouts
	  		
	  	else
	  		venue_id = venue
	  		shouts = Shout.where.not(id: content_black_list).where.not(user_id: black_list).where(venue_id: venue_id).where("created_at >= ?", 7.days.ago)
	  	end
	end
  	return shouts
  end


  # return shouts list
  def self.list(current_user, order_by, venue, my_shouts, my_comments, page, per_page)
  	result = Hash.new
  	time_0 = Time.now
  	shouts = Shout.collect_shouts_nearby(current_user, venue, my_shouts, my_comments)
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
        json.total_upvotes 	shout.total_upvotes
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

  # collect user ids that can access this shout
  def permitted_users_id
	return_user_ids = Array.new
	if !self.venue_id.nil?
	  return_user_ids = ActiveInVenue.where(venue_id: self.venue_id).where.not(user_id: self.user_id).map(&:user_id)
    end
	if self.allow_nearby
		return_user_ids = return_user_ids | User.where.not(id: self.user_id).near([self.latitude, self.longitude], 60, units: :km).map(&:id)
	end
	black_list = BlockUser.blocked_user_ids(self.user_id)
  	content_black_list = ShoutReportHistory.where(reportable_id: self.id).where(reportable_type: 'shout').map(&:reporter_id)
  	return_user_ids = return_user_ids - black_list - content_black_list

  	return return_user_ids
  end

  def in_shout_users_id
  	
  end

  # destroy a single shout
  def destroy_single
  	user_ids = self.permitted_users_id
  	shout_id = self.id
  	# delete
	
    if self.destroy

	  	# pusher
		# users in shout_id channel
		channel = 'public-shout-' + shout_id.to_s
		if Rails.env == 'production'
			# :nocov:
			Pusher.delay.trigger(channel, 'Delete shout', {shout_id: shout_id})
			# :nocov:
		end
		# users can access this shout
		user_channels = Array.new
		user_ids.each do |id|
			channel = 'private-user-' + id.to_s
			user_channels << channel
		end
		if !user_channels.empty?
			if Rails.env == 'production'
				# :nocov:
				Pusher.delay.trigger(user_channels, 'Delete shout', {shout_id: shout_id})
				# :nocov:
			end
		end
		return true
	else
		# :nocov:
		return false
		# :nocov:
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