class WhisperToday < ActiveRecord::Base
	has_many :whisper_replies, :foreign_key => 'whisper_id'
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

	def self.whispers_related(user_id)
		black_list = BlockUser.blocked_user_ids(user_id)
		whispers_1 = WhisperToday.where(:paper_owner_id => user_id).where.not(target_user_id: black_list).where(origin_user_id: user_id).where(:declined => false).where(:accepted => false).order("created_at DESC")
		whispers_2 = WhisperToday.where(:target_user_id => user_id).where.not(origin_user_id: black_list).where(:declined => false).where(:accepted => false).order("created_at DESC")
		return (whispers_1 | whispers_2).sort_by { |hsh| hsh.updated_at }.reverse
	end

	def self.find_pending_whisper(target_user_id, origin_user_id)
		whisper_a = WhisperToday.find_by_origin_user_id_and_target_user_id(origin_user_id, target_user_id)
		whisper_b = WhisperToday.find_by_target_user_id_and_origin_user_id(origin_user_id, target_user_id)
		if !whisper_a.nil?
			return whisper_a
		elsif !whisper_b.nil?
			return whisper_b
		else
			return nil
		end	
	end

	def self.to_json(whispers, current_user)
		result = Jbuilder.encode do |json|
			json.array! whispers do |a|
		        if current_user 
		        	if a.message_b.blank? # whispers without replies
			        	# if !current_user.timezone_name.blank?
				        #   hour = a.created_at.in_time_zone(current_user.timezone_name).hour
				        #   if hour >= 5
				        #     expire_timestamp = a.created_at.in_time_zone(current_user.timezone_name).tomorrow.beginning_of_day + 5.hours
				        #   else
				        #     expire_timestamp = a.created_at.in_time_zone(current_user.timezone_name).beginning_of_day + 5.hours            
				        #   end

				        #   json.expire_timestamp expire_timestamp.to_i
				        # else

				        #   json.expire_timestamp Time.now.to_i + 3600*12
				        # end
				        json.expire_timestamp (a.created_at + 12.hours).to_i
				        json.initial_whisper true
				    else # whispers with replies
				    	json.initial_whisper false
				    end

				    if FriendByWhisper.check_friends(a.target_user_id, a.origin_user_id) 
				    	are_friends = true
				    else
				    	are_friends = false
				    end
					json.timestamp 					a.created_at.to_i
					json.timestamp_read  			a.created_at
					json.viewed 					a.viewed.blank? ? 0 : (a.viewed ? 1 : 0)
					json.accepted 					a.accepted.blank? ? 0 : (a.accepted ? 1 : 0)
					json.declined 					a.declined.blank? ? 0 : (a.declined ? 1 : 0)
					json.notification_type  		a.whisper_type.to_i
					json.whisper_id  				a.dynamo_id.blank? ? '' : a.dynamo_id
					# json.paper_owner_id             a.paper_owner_id.blank? ? 0 : a.paper_owner_id

					if a.paper_owner_id == current_user.id and !a.accepted and !a.declined
						can_reply = true
					else
						can_reply = false
					end

					if a.target_user_id == current_user.id
						json.intro_message 				a.message.blank? ? '' : a.message
						if !a.accepted and !a.declined
							can_handle = true
						else
							can_handle = false
						end
						if !a.origin_user_id.nil?
							origin_user = User.find_by_id(a.origin_user_id)
							if !origin_user.nil? and !current_user.nil?
								json.object_type  'user'
								json.object origin_user.user_object(current_user)
							end
						end
					else
						json.intro_message 				a.message_b.blank? ? '' : a.message_b
						can_handle = false
						if !a.target_user_id.nil?
							origin_user = User.find_by_id(a.target_user_id)
							if !origin_user.nil? and !current_user.nil?
								json.object_type  'user'
								json.object origin_user.user_object(current_user)
							end
						end
					end
					sent = false
					if !origin_user.nil?
						array = WhisperSent.where(['whisper_time > ?', Time.now-12.hours]).where(:origin_user_id => current_user.id).where(:target_user_id => origin_user.id)
						if !array.blank?
							sent = true
						end
					end
					# if are_friends
					# 	json.status 5
					# elsif can_reply and can_handle
					# 	json.status 4
					# elsif can_handle
					# 	json.status 3
					# elsif can_reply
					# 	json.status 2
					# elsif sent
					# 	json.status 1
					# else
					# 	json.status 0
					# end

					actions = Array.new
		            if are_friends
		              actions << "chat"
		            end
		            if can_reply
		              actions << "reply"
		              actions << "delete"
		            end
		            if can_handle
		              actions << "accept"
		              actions << "delete"  
		            end
		            # if !sent and !are_friends and !can_handle and !can_reply 
		            #   actions << "whisper"
		            # end

		            json.actions actions.uniq
							
					if !a.venue_id.nil?
						venue = Venue.find_by_id(a.venue_id)
						if !venue.nil? 
							json.object_type  'venue'
							json.object venue.venue_object
						end
					end


					# reply message array
					messages_array = Array.new
					replies = WhisperReply.where(whisper_id: a.id).order("created_at DESC")
					if replies.count > 0
		              replies.each do |r|
		                new_item = {
		                  speaker_id: r.speaker_id,
		                  timestamp: r.created_at.to_i,
		                  message: r.message.nil? ? '' : r.message
		                }
		                messages_array << new_item
		              end
		            end

		            json.messages_array messages_array
				end
			end
		end

		result = JSON.parse(result).delete_if(&:empty?)
		return result
	end


	def self.expire
		expire_array = WhisperToday.where(['created_at < ?', Time.now-12.hours]).where(:message_b => '')
		whisper_ids = expire_array.map(&:id)
		WhisperReply.where(whisper_id: whisper_ids).delete_all
		expire_array.delete_all
	end
end
