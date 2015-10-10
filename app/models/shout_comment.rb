class ShoutComment < ActiveRecord::Base
  belongs_to :shout
  has_many :shout_comment_votes, dependent: :destroy
  belongs_to :user
  has_many :shout_report_histories, as: :reportable, dependent: :destroy
  has_many :recent_activities, as: :contentable, dependent: :destroy


  def total_votes
  	self.shout_comment_votes.length
  end

  def total_upvotes
  	self.shout_comment_votes.where(upvote: true).length - self.shout_comment_votes.where(upvote: false).length
  end


  def change_vote(current_user, upvote)
  	scv = ShoutCommentVote.find_by_shout_comment_id_and_user_id(self.id, current_user.id)
  	if !scv.nil?
  		old_upvote = scv.upvote
  		result = scv.update(upvote: upvote)
  		if result and old_upvote and !(upvote.to_s == "true" or upvote.to_s == '1') 
  			if self.user_id != current_user.id
				self.user.update(point: self.user.point-2)
				if current_user.id == self.shout.user.id
					self.user.update(point: self.user.point-2)
				end
			end
  		end
  		if result and !old_upvote and (upvote.to_s == "true" or upvote.to_s == '1') 
  			if self.user_id != current_user.id
				self.user.update(point: self.user.point+2)
				if current_user.id == self.shout.user.id
					self.user.update(point: self.user.point+2)
				end
			end
  		end
  		event = 'change_comment_vote'
  		data = {
  			user_id: current_user.id,
  			vote:    (upvote ? "up" : "down")
  		}

  	else
  		scv = ShoutCommentVote.new(user_id: current_user.id, shout_comment_id: self.id)
  		scv.upvote = upvote
  		result = scv.save
  		if result
  			# update points
  			if (upvote.to_s == "true" or upvote.to_s == '1') 
  				if self.user_id != current_user.id
  					self.user.update(point: self.user.point+2)
  					if current_user.id == self.shout.user.id
  						self.user.update(point: self.user.point+2)
  					end
  				end
  			end
			current_user.update(point: current_user.point+1)


			# push notification to author
			self.votes_notification
  		end

  		event = 'add_comment_vote'
  		data = {
  			user_id: current_user.id,
  			vote:    (upvote ? "up" : "down")
  		}
  	end
  	current_upvotes = self.total_upvotes
  	if current_upvotes <= -5
  		self.destroy_single
  	else
	  	user_ids = self.shout.permitted_users_id
	  	shout_id = self.shout.id
	  	
	  	# pusher
		# users in shout_id channel
		channel = 'public-shout-' + shout_id.to_s
		if Rails.env == 'production'
			# :nocov:
			Pusher.delay.trigger(channel, 'Shout comment upvotes changed', {total_upvotes: current_upvotes, shout_comment_id: self.id})
			# :nocov:
		end
	end
	
  	return {result: result, event: event, data: data}

  end


  # activity and notifications related to total votes
  # :nocov:
  def votes_notification
  	type = 0
	case self.total_votes
	when 10
		type = 330
	when 25
		type = 331
	when 50
		type = 332
	when 100
		type = 333
	when 250
		type = 334
	when 500
		type = 335
	when 1000
		type = 336
	when 2500
		type = 337
	when 5000
		type = 338
	end
	if type > 0
		op_user_id = self.user_id
		# create activity 
		current_time = Time.now
		if Rails.env == 'production'
			RecentActivity.delay.add_activity(op_user_id, type.to_s, nil, nil, "shout-comment-votes-"+self.total_votes.to_s+"-"+op_user_id.to_s+"-"+current_time.to_i.to_s, "ShoutComment", self.id, 'You received ' + self.total_votes.to_s + ' votes on your reply "'+self.body.truncate(23, separator: /\s/)+'"')
			WhisperNotification.delay.send_notification_330_level(op_user_id, type, self.total_votes, self.shout.id)
		end	
	end 
  	
  end
  # :nocov:

  # Create a new shout
  def self.create_shout_comment(current_user, body, shout_id)
  	shout_comment = ShoutComment.new
	shout_comment.latitude = current_user.latitude
	shout_comment.longitude = current_user.longitude
  	shout_comment.body = body
  	shout_comment.shout_id = shout_id.to_i
  	shout_comment.user_id = current_user.id
  	result = shout_comment.save
  	if result
  		current_user.update(point: current_user.point+2)
  		user_ids = shout_comment.shout.permitted_users_id
	  	shout_id = shout_comment.shout.id
	  	
	  	channel = 'public-shout-' + shout_id.to_s
		shout_comment_json = {
			id: 			shout_comment.id,
	        body: 			shout_comment.body,
	        latitude: 		shout_comment.latitude,
	        longitude: 		shout_comment.longitude,
	        timestamp: 		shout_comment.created_at.to_i,
	        total_upvotes: 	0,
	        voted: 			'',
	        shout_id: 		shout_comment.shout_id,
	        author_id: 		shout_comment.user_id
		}
		if Rails.env == "production"
			# :nocov:	
			Pusher.delay.trigger(channel, 'Create shout comment', {shout_comment: shout_comment_json})
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
				Pusher.delay.trigger(user_channels, 'Shout comment +1', {shout_id: shout_id})
				# :nocov:
			end
		end


		# notification to OP and other repliers
		# OP
		op_user_id = shout_comment.shout.user_id
		black_list = BlockUser.blocked_user_ids(current_user.id)
		# create activity 
		current_time = Time.now
		if !black_list.include? op_user_id
			if Rails.env == 'production'
				# :nocov:
				RecentActivity.delay.add_activity(op_user_id, '301', current_user.id, nil, "your-shout-comment-"+op_user_id.to_s+"-"+current_user.id.to_s+"-"+current_time.to_i.to_s, "ShoutComment", shout_comment.id, current_user.username + ' replied to your shout "'+shout_comment.shout.body.truncate(23, separator: /\s/)+'"')
				WhisperNotification.delay.send_notification_301(op_user_id, current_user.username, shout_id)
				# :nocov:
			end	
		end
		# other repliers
		other_repliers_user_ids = ShoutComment.where(shout_id: shout_comment.shout_id).where.not(user_id: current_user.id).where.not(user_id: black_list).map(&:user_id).uniq
		if !other_repliers_user_ids.empty?
			# create activities
			if Rails.env == 'production'
				# :nocov:
				shout_comment.delay.create_activities_to_other_repliers(current_user, current_time, other_repliers_user_ids)

				WhisperNotification.delay.send_notification_302(other_repliers_user_ids, current_user.username, shout_id)
				# :nocov:
			end	
		end
	  	return shout_comment
    else
    	# :nocov:
    	return false
    	# :nocov:
    end
  end


  # :nocov:
  # Function to create activities for a batch of users
  def create_activities_to_other_repliers(current_user, current_time, other_repliers_user_ids)
  	other_repliers_user_ids.each do |user_id|
		RecentActivity.add_activity(user_id, '302', current_user.id, nil, "same-shout-comment-"+user_id.to_s+"-"+current_user.id.to_s+"-"+current_time.to_i.to_s, "ShoutComment", self.id, current_user.username + ' replied to the shout "'+self.shout.body.truncate(23, separator: /\s/)+'"')
	end
  end
  # :nocov:


  # return shouts list
  def self.list(current_user, shout_id, page, per_page)
  	result = Hash.new
  	time_0 = Time.now
  	black_list = BlockUser.blocked_user_ids(current_user.id)
  	content_black_list = ShoutReportHistory.where(reporter_id: current_user.id).where(reportable_type: 'ShoutComment').map(&:reportable_id)
  	shout_comments = ShoutComment.where(shout_id: shout_id).where.not(id: content_black_list).where.not(user_id: black_list).order("created_at DESC")
  	if !page.nil? and !per_page.nil? and per_page > 0 and page >= 0
        pagination = Hash.new
        pagination['page'] = page - 1
        pagination['per_page'] = per_page
        pagination['total_count'] = shout_comments.length
        result['pagination'] = pagination
        shout_comments = Kaminari.paginate_array(shout_comments).page(page).per(per_page) if !shout_comments.nil?
    end
  	time_1 = Time.now
  	final_result = ShoutComment.shout_comments_json(current_user, shout_comments)
  	time_2 = Time.now

  	puts "TOTAL: " + final_result.count.to_s
  	puts "TIME: "
  	puts (time_1-time_0).inspect
  	puts (time_2-time_1).inspect

  	result['shout_comments'] = final_result
  	return result
  end

  # convert to json structure
  def self.shout_comments_json(current_user, shout_comments)
  	shout_comment_upvoted_ids = ShoutCommentVote.where(user_id: current_user.id).where(upvote: true).map(&:shout_comment_id)
  	shout_comment_downvoted_ids = ShoutCommentVote.where(user_id: current_user.id).where(upvote: false).map(&:shout_comment_id)
  	return_shout_comments = Jbuilder.encode do |json|
      json.array! shout_comments do |shout_comment|
        json.id 			shout_comment.id
        json.shout_id 		shout_comment.shout_id
        json.body 			shout_comment.body
        json.latitude 		shout_comment.latitude
        json.longitude 		shout_comment.longitude
        json.timestamp 		shout_comment.created_at.to_i
        json.total_upvotes 	shout_comment.total_upvotes
        json.upvoted 		(shout_comment_upvoted_ids.include? shout_comment.id)
        json.downvoted 		(shout_comment_downvoted_ids.include? shout_comment.id)
        json.voted			((shout_comment_upvoted_ids.include? shout_comment.id) ? "up" : ((shout_comment_downvoted_ids.include? shout_comment.id) ? "down" : ""))
        json.author_id 		shout_comment.user_id
      end         
    end
    return_shout_comments = JSON.parse(return_shout_comments).delete_if(&:empty?)
    return return_shout_comments 
  end

  # report a comment
  def report(user, type)
  	history = ShoutReportHistory.where(reportable_type: 'ShoutComment', reportable_id: self.id, shout_report_type_id: type)
  	if history.blank?
  		frequency = 1
  	else
  		frequency = history.first.frequency + 1
  	end

  	srh = ShoutReportHistory.create(reportable_type: 'ShoutComment', reportable_id: self.id, reporter_id: user.id, shout_report_type_id: type, frequency: frequency)
  	if srh
  		history.update_all(frequency: frequency)
  	end
  end

  # destroy a single shout comment
  def destroy_single
  	user_ids = self.shout.permitted_users_id
  	shout_comment_id = self.id
  	shout_id = self.shout.id
  	# delete
    if self.destroy

	  	# pusher
		# users in shout_id channel
		channel = 'public-shout-' + shout_id.to_s
		if Rails.env == "production"
			# :nocov:	
			Pusher.delay.trigger(channel, 'Delete shout comment', {shout_comment_id: shout_comment_id})
			# :nocov:
		end
		# users can access this shout
		user_channels = Array.new
		user_ids.each do |id|
			channel = 'private-user-' + id.to_s
			user_channels << channel
		end
		if !user_channels.empty?
			if Rails.env == "production"
				# :nocov:	
				Pusher.delay.trigger(user_channels, 'Shout comment -1', {shout_id: shout_id})
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

end