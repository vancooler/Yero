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
		result = Jbuilder.encode do |json|
			json.array! activities do |a|
				json.activity_id a.id
				case a.activity_type.to_s
				when '200'
					json.activity_type 'Joined Network'
				when '301'
					json.activity_type 'Replied Your Shout'
				when '302'
					json.activity_type 'Replied Same Shout'
				when '310'
				when '311'
				when '312'
				when '313'
				when '314'
				when '315'
				when '316'
				when '317'
				when '318'
					json.activity_type 'Shout Votes'
				when '330'
				when '331'
				when '332'
				when '333'
				when '334'
				when '335'
				when '336'
				when '337'
				when '338'
					json.activity_type 'Shout Comment Votes'
			
				when '201'
					json.activity_type 'Offline'
				when '101'
					json.activity_type 'Profile Avatar Disabled'
				when '3'
					json.activity_type 'Became Friends'
				when '2-sent'
					json.activity_type 'Sent Whisper'
				when '2-received'
					json.activity_type 'Received Whisper'
				end

				json.timestamp a.created_at.to_i
				json.message (a.message.nil? ? '' : a.message)
				if !a.origin_user_id.nil? and !a.target_user_id.nil?
					origin_user = User.find_by_id(a.origin_user_id)
					target_user = User.find_by_id(a.target_user_id)
					if !origin_user.nil? and !target_user.nil?
						json.object_type  'user'
						json.object origin_user.user_object(target_user)
					end
				elsif !a.contentable_type.nil? and !a.contentable_id.nil?
					json.object_type a.contentable_type
					json.object_id a.contentable_id
					if a.contentable_type == "ShoutComment"
						shout_comment = ShoutComment.find_by_id(a.contentable_id)
						if !shout_comment.nil?
							json.parent_type "Shout"
							json.parent_id shout_comment.shout_id
						end
					end
				end
				
			end
		end

		result = JSON.parse(result).delete_if(&:empty?)
		return result
	end

	# migrate messages and deep_links to exist activities
	def self.migrate_message_and_deep_link

	end
end
