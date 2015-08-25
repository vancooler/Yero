class WhisperToday < ActiveRecord::Base

	def self.all_whispers(user_id)
		black_list = BlockUser.blocked_user_ids(user_id)
		WhisperToday.where(:target_user_id => user_id).where.not(origin_user_id: black_list).where(:declined => false).where(:accepted => false).order("created_at DESC")
	end


	def self.unviewed_whispers_count(user_id)
		black_list = BlockUser.blocked_user_ids(user_id)
		WhisperToday.where(:target_user_id => user_id).where.not(origin_user_id: black_list).where(:viewed => false).count
	end

	def photo_disabled(current_user_id)
		if current_user_id == self.origin_user_id
			user = User.find_by_id(target_user_id)
		elsif current_user_id == self.target_user_id
			user = User.find_by_id(origin_user_id)
		else
			return true
		end

		if user.nil?
			return true
		else
			return user.user_avatars.where(is_active: true).blank?
		end
	end

	def self.to_json(whispers)
		result = Jbuilder.encode do |json|
			json.array! whispers do |a|
				if !a.target_user_id.nil?
					current_user = User.find_by_id(a.target_user_id)
			        if current_user 
			        	if !current_user.timezone_name.blank?
				          hour = a.created_at.in_time_zone(current_user.timezone_name).hour
				          if hour >= 5
				            expire_timestamp = a.created_at.in_time_zone(current_user.timezone_name).tomorrow.beginning_of_day + 5.hours
				          else
				            expire_timestamp = a.created_at.in_time_zone(current_user.timezone_name).beginning_of_day + 5.hours            
				          end
				          json.seconds_left  expire_timestamp.to_i - Time.now.to_i + 60
				          json.expire_timestamp expire_timestamp.to_i
				        else
				          json.seconds_left = 3600*12
				          json.expire_timestamp Time.now.to_i + 3600*12
				        end

						# json.whisper_id a.dynamo_id
						json.timestamp 					a.created_at.to_i
						json.timestamp_read  			a.created_at
						json.viewed 					a.viewed.blank? ? 0 : (a.viewed ? 1 : 0)
						json.accepted 					a.accepted.blank? ? 0 : (a.accepted ? 1 : 0)
						json.declined 					a.declined.blank? ? 0 : (a.declined ? 1 : 0)
						json.intro_message 				a.message.blank? ? '' : a.message
						json.notification_type  		a.whisper_type.to_i
						json.whisper_id  				a.dynamo_id.blank? ? '' : a.dynamo_id

						if !a.origin_user_id.nil?
							origin_user = User.find_by_id(a.origin_user_id)
							if !origin_user.nil? and !current_user.nil?
								json.object_type  'user'
								json.object origin_user.user_object(current_user)
							end
						end
						if !a.venue_id.nil?
							venue = Venue.find_by_id(a.venue_id)
							if !venue.nil? 
								json.object_type  'venue'
								json.object venue.venue_object
							end
						end
					end
				end		  
			end
		end

		result = JSON.parse(result).delete_if(&:empty?)
		return result
	end
end
