class Shout < ActiveRecord::Base
  has_many :shout_comments, dependent: :destroy
  has_many :shout_votes, dependent: :destroy
  has_many :shout_report_histories, as: :reportable, dependent: :destroy
  has_many :recent_activities, as: :contentable, dependent: :destroy
  belongs_to :shout_banner_image
  belongs_to :user
  belongs_to :venue
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
  	self.shout_votes.count
  end

  # total upvote of a shout
  def total_upvotes
  	self.shout_votes.where(upvote: true).length - self.shout_votes.where(upvote: false).length
  end


  def change_vote(current_user, upvote)
  	sv = ShoutVote.find_by_shout_id_and_user_id(self.id, current_user.id)
  	if !sv.nil?
  		old_upvote = sv.upvote
  		result = sv.update(upvote: (upvote.to_i == 0 ? nil : (upvote.to_i>0)))
  		offset = 0
  		if old_upvote.nil?
  			offset = upvote.to_i
  		elsif old_upvote
  			if upvote.to_i < 1
	  			offset = -1
	  		end
	  	else
	  		if upvote.to_i > -1
	  			offset = 1
	  		end
  		end
  		if self.user_id != current_user.id
  			self.user.update(point: self.user.point + offset*2)
  		end

  		if old_upvote.nil? and upvote.to_i != 0
  			current_user.update(point: current_user.point+1)
  		elsif !old_upvote.nil? and upvote.to_i == 0
    			current_user.update(point: current_user.point-1)
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
  			if (upvote.to_s == '1') 
  				if self.user_id != current_user.id
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
  	if current_upvotes <= -5
  		self.destroy_single
  	else
	  	user_ids = self.permitted_users_id
	  	shout_id = self.id
	  	
	  	# pusher
  		# users in shout_id channel
  		channel = 'public-shout-' + shout_id.to_s
  		if Rails.env == 'production'
  			# :nocov:
  			Pusher.trigger(channel, 'vote_shout_event', {total_upvotes: current_upvotes, shout_id: self.id})
  			# :nocov:
  		end
  		# users can access this shout
  		user_channels = Array.new
  		# :nocov:
  		user_ids.each do |id|
  			channel = 'private-user-' + id.to_s
  			user_channels << channel
  		end
  		if !user_channels.empty?
  			if Rails.env == 'production'
  				user_channels.in_groups_of(10, false) do |channels|
  					Pusher.trigger(channels, 'vote_shout_event', {total_upvotes: current_upvotes, shout_id: self.id})
  				end
  			end
  		end
  		# :nocov:
  	end

    # pusher to update votes
    if Rails.env == 'production' 
      # :nocov:
      if current_user.pusher_private_online
        channel = 'private-user-' + current_user.id.to_s
        Pusher.trigger(channel, 'update_point_event', {point: current_user.points_to_display})
      end
      if self.user.pusher_private_online
        channel = 'private-user-' + self.user.id.to_s
        Pusher.trigger(channel, 'update_point_event', {point: self.user.points_to_display})
      end
      # :nocov:
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
			RecentActivity.delay.add_activity(op_user_id, type.to_s, nil, nil, "shout-votes-"+self.total_votes.to_s+"-"+op_user_id.to_s+"-"+current_time.to_i.to_s, "Shout", self.id, 'You received ' + self.total_votes.to_s + ' votes on your shout "'+self.body.truncate(23, separator: /\s/)+'"')
			WhisperNotification.delay.send_notification_330_level(op_user_id, type, self.total_votes, self.id)
		end	
	end 
  end
  # :nocov:

  # Create a new shout
  def self.create_shout(current_user, body, exclusive, anonymous, image_url, image_thumb_url, audio_url)
  	shout = Shout.new
  	# venue = Venue.find_venue_by_unique(venue_id)
    if !current_user.current_venue.nil?
      shout.latitude = current_user.current_venue.latitude
      shout.longitude = current_user.current_venue.longitude
      shout.venue_id = current_user.current_venue.id 
    else
      shout.latitude = current_user.latitude
      shout.longitude = current_user.longitude
    end
    if !exclusive
      shout.allow_nearby = true
  	else
	  	shout.allow_nearby = false
  	end
    shout.city = current_user.current_city
    shout.neighbourhood = current_user.current_sublocality
    # shout.content_type = content_type
    shout.image_url = image_url
    shout.image_thumb_url = image_thumb_url
    shout.audio_url = audio_url
  	shout.body = (body.nil? ? '' : body.rstrip)
  	shout.user_id = current_user.id
  	shout.anonymous = anonymous

    # banner image link
    if ShoutBannerImage.all.count > 0
      shout.shout_banner_image_id = ShoutBannerImage.all.sample.id
    end
  	result = shout.save
  	if result
  		current_user.update(point: current_user.point+4)
      channel = 'private-user-' + current_user.id.to_s
      if Rails.env == 'production' and current_user.pusher_private_online
        # :nocov:
        Pusher.trigger(channel, 'update_point_event', {point: current_user.points_to_display})
        # :nocov:
      end
  		# pusher
  		user_ids = shout.permitted_users_id
	  	shout_id = shout.id
	  	shout.change_vote(current_user, 1)
	  	attachments = Array.new
      if !shout.image_url.blank?
        image = {
          attachment_type: "image",
          image_url:       shout.image_url.nil? ? '' : shout.image_url,
          image_thumb_url: shout.image_thumb_url.nil? ? '' : shout.image_thumb_url,
        }
        attachments << image
      end
      if !shout.audio_url.blank?
        audio = {
          attachment_type: "audio",
          audio_url:       shout.audio_url.nil? ? '' : shout.audio_url
        }
        attachments << audio
      end
  		shout_json = {
  			id: 			           shout.id,
        body: 			         shout.body,
        anonymous:           shout.anonymous,
        exclusive:           !shout.allow_nearby,
        latitude: 		       shout.latitude,
        longitude:           shout.longitude,
        locality:            shout.city.nil? ? '' : shout.city,
        replied:             false,
        shout_banner_image_url: ((shout.shout_banner_image.nil? or shout.shout_banner_image.avatar.nil? or shout.shout_banner_image.avatar.url.nil?) ? '' : shout.shout_banner_image.avatar.url), 
        # content_type:        shout.content_type.nil? ? 'text' : shout.content_type,
        # audio_url:           shout.audio_url.nil? ? '' : shout.audio_url,
        # image_url:           shout.image_url.nil? ? '' : shout.image_url,
        attachments:         attachments,
        subLocality:         shout.neighbourhood.nil? ? '' : shout.neighbourhood,
        timestamp:           shout.created_at.to_i,
        expire_timestamp:    shout.created_at.to_i+7*24*3600,
        total_upvotes: 	     1,
        actions:             ["undo_upvote", "downvote"],
        network_gimbal_key:  ((shout.venue.nil? or shout.venue.gimbal_name.empty?) ? '' : shout.venue.gimbal_name),
        count:               0,
        author_id:           shout.user_id,
        author_username: 		 (User.find_by_id(shout.user_id).nil? ? "" : User.find_by_id(shout.user_id).username)
		  }
  		# users can access this shout
  		user_channels = Array.new
  		# :nocov:
  		user_ids.each do |id|
  			channel = 'private-user-' + id.to_s
  			user_channels << channel
  		end
  		if !user_channels.empty?
  			if Rails.env == 'production'
  				user_channels.in_groups_of(10, false) do |channels|
  					Pusher.trigger(channels, 'create_shout_event', {shout: shout_json})
  				end
  			end
  		end
  		# :nocov:
	  	return shout_json
    else
    	# :nocov:
    	return false
    	# :nocov:
    end
  end

  # collect shouts in a venue or near users
  def self.collect_shouts_nearby(current_user, venue, city, my_shouts, my_comments, latitude, longitude)
  	black_list = BlockUser.blocked_user_ids(current_user.id)
  	content_black_list = ShoutReportHistory.where(reporter_id: current_user.id).where(reportable_type: 'Shout').map(&:reportable_id)
  	if !my_comments.nil? and my_comments
  		comments = ShoutComment.where(user_id: current_user.id).map(&:shout_id)
  		shouts = Shout.where(id: comments).where.not(user_id: current_user.id).includes(:venue, :shout_banner_image)
  		
  	elsif !my_shouts.nil? and my_shouts
  		shouts = Shout.where(user_id: current_user.id).includes(:venue, :shout_banner_image)
  	else
	  	if venue.nil? and city.nil?
	  		current_venue = current_user.current_venue
	  		if !current_venue.nil?
	  			same_venue_shouts = Shout.where.not(id: content_black_list).where.not(user_id: black_list).where(venue_id: current_venue.id).where("created_at >= ?", 7.days.ago).includes(:venue, :shout_banner_image)
	  		else
	  			same_venue_shouts = []
	  		end
	  		shouts = Shout.where.not(id: content_black_list).where.not(user_id: black_list).where(allow_nearby: true).where("created_at >= ?", 7.days.ago).near([latitude, longitude], 30, units: :km).includes(:venue, :shout_banner_image)
	  		shouts = shouts | same_venue_shouts
  		elsif venue.nil? and !city.nil?
        current_venue = current_user.current_venue
        if !current_venue.nil?
          same_venue_shouts = Shout.where.not(id: content_black_list).where.not(user_id: black_list).where(venue_id: current_venue.id).where("created_at >= ?", 7.days.ago).includes(:venue, :shout_banner_image)
        else
          same_venue_shouts = []
        end
        shouts = Shout.where.not(id: content_black_list).where.not(user_id: black_list).where(allow_nearby: true).where("created_at >= ?", 7.days.ago).where(city: city).includes(:venue, :shout_banner_image)
        shouts = shouts | same_venue_shouts
	  	elsif !venue.nil? and city.nil?
	  		# venue_id = venue
        venue = Venue.find_venue_by_unique(venue)
        user_number = venue.venue_entries.count
        unlock_number = (venue.unlock_number.nil? ? 0 : venue.unlock_number)
        if !(!venue.venue_type.nil? and !venue.venue_type.name.nil? and venue.venue_type.name == "Campus") or user_number >= unlock_number
          venue_id = venue.id
  	  		shouts = Shout.where.not(id: content_black_list).where.not(user_id: black_list).where(venue_id: venue_id).where("created_at >= ?", 7.days.ago).includes(:venue, :shout_banner_image)
        else
          shouts = (user_number * 100 / unlock_number).to_i
        end
	  	end
	  end
  	return shouts
  end

  def self.shouts_in_venue(current_user, venue_id)
  	black_list = BlockUser.blocked_user_ids(current_user.id)
  	content_black_list = ShoutReportHistory.where(reporter_id: current_user.id).where(reportable_type: 'Shout').map(&:reportable_id)
	shouts = Shout.where.not(id: content_black_list).where.not(user_id: black_list).where(venue_id: venue_id).where("created_at >= ?", 7.days.ago)
	shouts = shouts.sort_by{|s| s.created_at}.reverse
	return shouts
  end


  # return shouts list
  def self.list(current_user, order_by, venue, city, my_shouts, my_comments, page, per_page, nearby)
  	result = Hash.new
  	time_0 = Time.now
  	query_venue = Venue.find_venue_by_unique(venue)
  	if query_venue.nil?
  		venue = nil
  	else
  		venue = query_venue.id
  	end
    puts "~~~~~~~~1"
    puts "~~~~~~~~2" + nearby.to_s
    if !nearby
      if current_user.current_venue.nil?
        puts "~~~~~~~~2 non-current"
        if !page.nil? and !per_page.nil? and per_page > 0 and page >= 0
          pagination = Hash.new
          pagination['page'] = page - 1
          pagination['per_page'] = per_page
          pagination['total_count'] = 0
          result['pagination'] = pagination
        end
        shouts = []
        result['shouts'] = shouts
        return result
      else
        venue = current_user.current_venue.id
        puts "~~~~~~~~2" + (venue.nil? ? 'nil-venue' : venue.to_s)
        puts "~~~~~~~~2" + (city.nil? ? 'nil' : city.to_s)
      end
    end
    puts "~~~~~~~~2"
  	shouts = Shout.collect_shouts_nearby(current_user, venue, city, my_shouts, my_comments, current_user.latitude, current_user.longitude)
    puts "~~~~~~~~3"

    if shouts.is_a? Integer
      result['percentage'] = shouts
      return result
    else
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
  end

  # convert to json structure
  def self.shouts_json(current_user, shouts)
  	shout_upvoted_ids = ShoutVote.where(user_id: current_user.id).where(upvote: true).map(&:shout_id)
  	shout_downvoted_ids = ShoutVote.where(user_id: current_user.id).where(upvote: false).map(&:shout_id)
    replied_shouts_ids = ShoutComment.where(user_id: current_user.id).map(&:shout_id)

    # # not using Jbuilder
    result = Array.new
    shouts.each do |shout|
      attachments = Array.new
      if !shout.image_url.blank?
        image = {
          attachment_type: "image",
          image_url:       shout.image_url.nil? ? '' : shout.image_url,
          image_thumb_url: shout.image_thumb_url.nil? ? '' : shout.image_thumb_url
        }
        attachments << image
      end
      if !shout.audio_url.blank?
        audio = {
          attachment_type: "audio",
          audio_url:       shout.audio_url.nil? ? '' : shout.audio_url
        }
        attachments << audio
      end
      actions = ["downvote", "upvote"]
      if shout_upvoted_ids.include? shout.id
          actions = ["undo_upvote", "downvote"]
      end
      if shout_downvoted_ids.include? shout.id
          actions = ["undo_downvote", "upvote"]
      end

      shout_json = {
        id:                  shout.id,
        body:                shout.body,
        anonymous:           shout.anonymous,
        exclusive:           !shout.allow_nearby,
        latitude:            shout.latitude,
        longitude:           shout.longitude,
        locality:            shout.city.nil? ? '' : shout.city,
        replied:             (replied_shouts_ids.include? shout.id),
        attachments:         attachments,
        subLocality:         shout.neighbourhood.nil? ? '' : shout.neighbourhood,
        shout_banner_image_url: ((shout.shout_banner_image.nil? or shout.shout_banner_image.avatar.nil? or shout.shout_banner_image.avatar.url.nil?) ? '' : shout.shout_banner_image.avatar.url),
        timestamp:           shout.created_at.to_i,
        expire_timestamp:    shout.created_at.to_i+7*24*3600,
        total_upvotes:       shout.total_upvotes,
        actions:             actions,
        network_gimbal_key:  ((shout.venue.nil? or shout.venue.gimbal_name.empty?) ? '' : shout.venue.gimbal_name),
        count:               ShoutComment.list(current_user, shout.id, nil, nil)['shout_comments'].length,
        author_id:           shout.user_id,
        author_username:     (User.find_by_id(shout.user_id).nil? ? "" : User.find_by_id(shout.user_id).username)
      }
      result << shout_json
    end

    return result     
  end

  # report a shout
  def report(user, type)
  	history = ShoutReportHistory.where(reportable_type: 'Shout', reportable_id: self.id, shout_report_type_id: type)
  	if history.blank?
  		frequency = 1
  	else
  		frequency = history.first.frequency + 1
  	end

  	srh = ShoutReportHistory.create(reportable_type: 'Shout', reportable_id: self.id, reporter_id: user.id, shout_report_type_id: type, frequency: frequency)
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
		return_user_ids = return_user_ids | User.where.not(id: self.user_id).near([self.latitude, self.longitude], 30, units: :km).map(&:id)
	end
	black_list = BlockUser.blocked_user_ids(self.user_id)
  	content_black_list = ShoutReportHistory.where(reportable_id: self.id).where(reportable_type: 'Shout').map(&:reporter_id)
  	return_user_ids = return_user_ids - black_list - content_black_list

  	# only user pusher for online users
  	online_users_ids = User.where(id: return_user_ids).where(pusher_private_online: true).map(&:id)
  	return online_users_ids
  end

  def self.deleted_ids
    puts "wwww"
  	array = DeletedObject.where(deleted_object_type: "Shout").where("created_at >= ?", 7.days.ago).map(&:deleted_object_id)
    puts "wwwww"
    return array
  end

  # destroy a single shout
  def destroy_single
  	user_ids = self.permitted_users_id
  	shout_id = self.id
  	# delete
	
    if self.destroy
      DeletedObject.create!(deleted_object_id: shout_id, deleted_object_type: "Shout")

	  	# pusher
  		# users in shout_id channel
  		channel = 'public-shout-' + shout_id.to_s
  		if Rails.env == 'production'
  			# :nocov:
  			Pusher.trigger(channel, 'delete_shout_event', {shout_id: shout_id})
  			# :nocov:
  		end
  		# users can access this shout
  		user_channels = Array.new
  		# :nocov:
  		user_ids.each do |id|
  			channel = 'private-user-' + id.to_s
  			user_channels << channel
  		end
  		if !user_channels.empty?
  			if Rails.env == 'production'
  				user_channels.in_groups_of(10, false) do |channels| 
  					Pusher.trigger(channels, 'delete_shout_event', {shout_id: shout_id})
  				end
  			end
  		end
  		# :nocov:
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
  		shout = Shout.create_shout(rand_user, (0...8).map { (65 + rand(26)).chr }.join, false, false, nil, nil, nil, nil, nil)
      shout = Shout.find(shout[:id])
      (1..i%8).each do |k|
        upvote = [1, 1, -1]
        offset_3 = rand(User.count)
        rand_user_3 = User.offset(offset_3).first
  			shout.change_vote(rand_user_3, upvote.sample)
  		end
  		comments_count = i/100*100 + 1
  		(1..comments_count).each do |j|
  			offset_2 = rand(User.count)
  			rand_user_2 = User.offset(offset_2).first
  			shout_comment = ShoutComment.create_shout_comment(rand_user_2, (0...8).map { (65 + rand(26)).chr }.join, shout.id, nil, nil, nil)
        shout_comment = ShoutComment.find(shout_comment[:id])
  			# upvotes
  			(1..i%8).each do |k|
  				upvote = [1, 1, -1]
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

  def self.pressure_test(user)
    Shout.random_generate
    time_1 = Time.now
    (1..10).each do |i|
      Shout.list(user, 'hot', nil, nil, nil, 1, 1000)
    end
    time_2 = Time.now
    puts "pressure_test: " + (time_2 - time_1).inspect

    ShoutCommentVote.delete_all
    ShoutComment.delete_all
    ShoutVote.delete_all
    Shout.delete_all
    RecentActivity.delete_all
  end

  # :nocov:

end