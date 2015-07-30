class RecentActivity < ActiveRecord::Base

	def self.all_activities(user_id)
		RecentActivity.where(:target_user_id => user_id).order("created_at DESC")
	end



	def self.can_add_more(user_id)
		RecentActivity.where(:target_user_id => user_id).count < 50
	end


	def self.add_activity(user_id, type, origin_user_id, venue_id, dynamo_id)
		if RecentActivity.can_add_more(user_id)
		else
			RecentActivity.all_activities(user_id).last.destroy	
		end
		RecentActivity.create!(:target_user_id => user_id, :activity_type => type, :origin_user_id => origin_user_id, :venue_id => venue_id, :dynamo_id => dynamo_id)
	end


	def self.to_json(activities)
		result = Jbuilder.encode do |json|
			json.array! activities do |a|
				json.activity_id a.id
				case a.activity_type.to_s
				when '200'
					json.activity_type 'Joined Network'
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
				json.timestamp a.created_at
				if !a.origin_user_id.nil? and !a.target_user_id.nil?
					origin_user = User.find_by_id(a.origin_user_id)
					target_user = User.find_by_id(a.target_user_id)
					if !origin_user.nil? and !target_user.nil?
						json.object_type  'user'
						json.object origin_user.user_object(target_user)
					end
				end
				
			end
		end

		result = JSON.parse(result).delete_if(&:empty?)
		return result
	end
end
