class RecentActivity < ActiveRecord::Base
	belongs_to :contentable, polymorphic: true

	def self.all_activities(user_id)
		black_list = BlockUser.blocked_user_ids(user_id)
		# all_activity = RecentActivity.where(:target_user_id => user_id).order("created_at DESC")
		all_activity = RecentActivity.where(target_user_id: user_id).where.not(origin_user_id: black_list).order("created_at DESC")
		return all_activity
	end



	def self.can_add_more(user_id)
		true
	end


	def self.add_activity(user_id, type, origin_user_id, venue_id, dynamo_id, contentable_type=nil, contentable_id=nil, message=nil)
		# if RecentActivity.can_add_more(user_id)
		# else
		# 	RecentActivity.all_activities(user_id).last.destroy	
		# end
		RecentActivity.create!(:target_user_id => user_id, :activity_type => type, :origin_user_id => origin_user_id, :venue_id => venue_id, :dynamo_id => dynamo_id, :contentable_type => contentable_type, :message => message, :contentable_id => contentable_id)
	end


	def self.to_json(activities)
		result = Array.new
		activities.each do |a|
			activity_json = {
				activity_id: a.id,
				timestamp:   a.created_at.to_i,
				message:     (a.message.nil? ? '' : a.message)
			}
			case a.activity_type.to_s
			
			# :nocov:
			when '200'
				activity_json[:activity_type] = 'Joined Network'
				activity_json[:message] = "You joined your city's network until 5AM"
				activity_json[:deep_link] = ""
			when '301'
				activity_json[:activity_type] = 'Replied Your Shout'
				if !a.contentable_type.nil? and !a.contentable_id.nil?
					if a.contentable_type == "Shout"
						deeplink_shout_id = a.contentable_id
					elsif a.contentable_type == "ShoutComment"
						shout_comment = ShoutComment.find_by_id(a.contentable_id)
						if !shout_comment.nil?
							deeplink_shout_id = shout_comment.shout_id
						else
							deeplink_shout_id = 0
						end
					end
					activity_json[:deep_link] = "yero://shouts/"+deeplink_shout_id.to_s
				end
			when '302'
				activity_json[:activity_type] = 'Replied Same Shout'
				if !a.contentable_type.nil? and !a.contentable_id.nil?
					if a.contentable_type == "Shout"
						deeplink_shout_id = a.contentable_id
					elsif a.contentable_type == "ShoutComment"
						shout_comment = ShoutComment.find_by_id(a.contentable_id)
						if !shout_comment.nil?
							deeplink_shout_id = shout_comment.shout_id
						else
							deeplink_shout_id = 0
						end
					end
					activity_json[:deep_link] = "yero://shouts/"+deeplink_shout_id.to_s
				end
			when '310', '311', '312', '313', '314', '315', '316', '317', '318'
				case a.activity_type.to_s
				when '310'
					vote_number = 10
				when '311'
					vote_number = 25
				when '312'
					vote_number = 50
				when '313'
					vote_number = 100
				when '314'
					vote_number = 250
				when '315'
					vote_number = 500
				when '316'
					vote_number = 1000
				when '317'
					vote_number = 2500
				when '318'
					vote_number = 5000
				end
				activity_json[:activity_type] = vote_number.to_s + 'Shout Votes'
				if !a.contentable_type.nil? and !a.contentable_id.nil?
					if a.contentable_type == "Shout"
						deeplink_shout_id = a.contentable_id
					elsif a.contentable_type == "ShoutComment"
						shout_comment = ShoutComment.find_by_id(a.contentable_id)
						if !shout_comment.nil?
							deeplink_shout_id = shout_comment.shout_id
						else
							deeplink_shout_id = 0
						end
					end
					activity_json[:deep_link] = "yero://shouts/"+deeplink_shout_id.to_s
				end
			when '330', '331', '332', '333', '334', '335', '336', '337', '338'
				case a.activity_type.to_s
				when '330'
					vote_number = 10
				when '331'
					vote_number = 25
				when '332'
					vote_number = 50
				when '333'
					vote_number = 100
				when '334'
					vote_number = 250
				when '335'
					vote_number = 500
				when '336'
					vote_number = 1000
				when '337'
					vote_number = 2500
				when '338'
					vote_number = 5000
				end
				activity_json[:activity_type] = vote_number.to_s + 'Shout Comment Votes'
				if !a.contentable_type.nil? and !a.contentable_id.nil?
					if a.contentable_type == "Shout"
						deeplink_shout_id = a.contentable_id
					elsif a.contentable_type == "ShoutComment"
						shout_comment = ShoutComment.find_by_id(a.contentable_id)
						if !shout_comment.nil?
							deeplink_shout_id = shout_comment.shout_id
						else
							deeplink_shout_id = 0
						end
					end
					activity_json[:deep_link] = "yero://shouts/"+deeplink_shout_id.to_s
				end
			when '201'
				activity_json[:activity_type] = 'Offline'
				activity_json[:deep_link] = ""
				activity_json[:message] = "Your city's network is now offline. All users have been disconnected"
			when '101'
				activity_json[:activity_type] = 'Profile Avatar Disabled'
				activity_json[:deep_link] = ""
				activity_json[:message] = "One of your photos has been flagged as inappropriate and removed"
			when '3'
				activity_json[:activity_type] = 'Became Friends'
				activity_json[:deep_link] = ""
				activity_json[:message] = "@username is now your friend"
			when '2-sent'
				activity_json[:activity_type] = 'Sent Whisper'
				activity_json[:deep_link] = ""
				activity_json[:message] = "You sent a whisper"
			when '2-received'
				activity_json[:activity_type] = 'Received Whisper'
				activity_json[:message] = "@username sent you a whisper"
				activity_json[:deep_link] = ""
			when '4'
				activity_json[:activity_type] = "Whisper Expired"
				if !a.origin_user_id.nil? and !a.target_user_id.nil?
					origin_user = User.find_user_by_unique(a.origin_user_id)
					target_user = User.find_user_by_unique(a.target_user_id)
					if !origin_user.nil? and !target_user.nil?
						activity_json[:deep_link] = "yero://people/"+origin_user.id.to_s
					end
				end
			end
			# :nocov:
			if !a.origin_user_id.nil? and !a.target_user_id.nil?
				origin_user = User.find_user_by_unique(a.origin_user_id)
				target_user = User.find_user_by_unique(a.target_user_id)
				op = false
				if a.contentable_type == "ShoutComment"
					shout_comment = ShoutComment.find_by_id(a.contentable_id)
					if !shout_comment.nil? and !shout_comment.shout.nil? and origin_user.id == shout_comment.shout.user_id
						op = true
					end
				end

				if !op and !origin_user.nil? and !target_user.nil?
					if target_user.version.nil? or target_user.version.to_f < 2
						activity_json[:object_type] =  'user'
					else
						activity_json[:object_type] =  'User'
					end
					activity_json[:object] = origin_user.user_object(target_user)
					activity_json[:message] = (activity_json[:message].sub '@username', (origin_user.username.nil? ? origin_user.first_name : '@'+origin_user.username))
				end
				if op
					activity_json[:message] = (activity_json[:message].sub '@username', 'OP')
				end
			elsif !a.contentable_type.nil? and !a.contentable_id.nil?
				activity_json[:object_type] = a.contentable_type
				activity_json[:object_id] = a.contentable_id
				if a.contentable_type == "ShoutComment"
					shout_comment = ShoutComment.find_by_id(a.contentable_id)
					if !shout_comment.nil?
						activity_json[:parent_type] = "Shout"
						activity_json[:parent_id] = shout_comment.shout_id
					end
				end
			end

			result << activity_json
		end
		# result = Jbuilder.encode do |json|
		# 	json.array! activities do |a|
		# 		json.activity_id a.id
		# 		case a.activity_type.to_s
		# 		when '200'
		# 			json.activity_type 'Joined Network'
		# 		when '301'
		# 			json.activity_type 'Replied Your Shout'
		# 		when '302'
		# 			json.activity_type 'Replied Same Shout'
		# 		when '310'
		# 		when '311'
		# 		when '312'
		# 		when '313'
		# 		when '314'
		# 		when '315'
		# 		when '316'
		# 		when '317'
		# 		when '318'
		# 			json.activity_type 'Shout Votes'
		# 		when '330'
		# 		when '331'
		# 		when '332'
		# 		when '333'
		# 		when '334'
		# 		when '335'
		# 		when '336'
		# 		when '337'
		# 		when '338'
		# 			json.activity_type 'Shout Comment Votes'
			
		# 		when '201'
		# 			json.activity_type 'Offline'
		# 		when '101'
		# 			json.activity_type 'Profile Avatar Disabled'
		# 		when '3'
		# 			json.activity_type 'Became Friends'
		# 		when '2-sent'
		# 			json.activity_type 'Sent Whisper'
		# 		when '2-received'
		# 			json.activity_type 'Received Whisper'
		# 		end

		# 		json.timestamp a.created_at.to_i
		# 		json.message (a.message.nil? ? '' : a.message)
		# 		if !a.origin_user_id.nil? and !a.target_user_id.nil?
		# 			origin_user = User.find_user_by_unique(a.origin_user_id)
		# 			target_user = User.find_user_by_unique(a.target_user_id)
		# 			if !origin_user.nil? and !target_user.nil?
		# 				json.object_type  'User'
		# 				json.object origin_user.user_object(target_user)
		# 			end
		# 		elsif !a.contentable_type.nil? and !a.contentable_id.nil?
		# 			json.object_type a.contentable_type
		# 			json.object_id a.contentable_id
		# 			if a.contentable_type == "ShoutComment"
		# 				shout_comment = ShoutComment.find_by_id(a.contentable_id)
		# 				if !shout_comment.nil?
		# 					json.parent_type "Shout"
		# 					json.parent_id shout_comment.shout_id
		# 				end
		# 			end
		# 		end
				
		# 	end
		# end

		# result = JSON.parse(result).delete_if(&:empty?)
		return result
	end

	
end
