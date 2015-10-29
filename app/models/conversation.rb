class Conversation < ActiveRecord::Base
	has_many :chatting_messages, :foreign_key => 'whisper_id'
	
	def photo_disabled(current_user_id)
		if current_user_id == self.origin_user_id
			user = User.find_user_by_unique(target_user_id)
		elsif current_user_id == self.target_user_id
			user = User.find_user_by_unique(origin_user_id)
		else
			# :nocov:
			return true
			# :nocov:
		end

		if user.nil?
			# :nocov:
			return true
			# :nocov:
		else
			return user.user_avatars.where(is_active: true).blank?
		end
	end

	def self.find_pending_whisper(target_user_id, origin_user_id)
		whisper_a = Conversation.find_by_origin_user_id_and_target_user_id(origin_user_id, target_user_id)
		whisper_b = Conversation.find_by_target_user_id_and_origin_user_id(origin_user_id, target_user_id)
		if !whisper_a.nil?
			return whisper_a
		elsif !whisper_b.nil?
			return whisper_b
		else
			return nil
		end	
	end

	def self.pending_whispers(user_id)
		whisper_a = Conversation.where(origin_user_id: user_id).map(&:target_user_id)
		whisper_b = Conversation.where(target_user_id: user_id).map(&:origin_user_id)
		return (whisper_a | whisper_b)
	end

	def self.conversations_related(user_id)
		black_list = BlockUser.blocked_user_ids(user_id)
		whispers_1 = Conversation.where(:origin_user_id => user_id).where(origin_user_archieve: false).where.not(target_user_id: black_list).order("created_at DESC")
		whispers_2 = Conversation.where(:target_user_id => user_id).where(target_user_archieve: false).where.not(origin_user_id: black_list).order("created_at DESC")
		return (whispers_1 | whispers_2).sort_by { |hsh| hsh.updated_at }.reverse
	end

	def self.find_conversation(target_user_id, origin_user_id)
		whisper_a = Conversation.find_by_origin_user_id_and_target_user_id(origin_user_id, target_user_id)
		whisper_b = Conversation.find_by_target_user_id_and_origin_user_id(origin_user_id, target_user_id)
		if !whisper_a.nil?
			return whisper_a
		elsif !whisper_b.nil?
			return whisper_b
		else
			return nil
		end
	end

	def self.conversations_to_json(whispers, current_user)
		result = Jbuilder.encode do |json|
			json.array! whispers do |a|
		        if current_user 
		        	if a.chatting_messages.length < 2 # whispers without replies
				        json.expire_timestamp (a.created_at + 12.hours).to_i
				        json.initial_whisper true
				        if current_user.id == a.target_user_id and a.chatting_messages.length == 1
				        	can_reply = true
				        else
							can_reply = false
						end
				    else # whispers with replies
				    	json.initial_whisper false
						can_reply = true
				    end

					json.timestamp 					a.updated_at.to_i
					json.notification_type  		a.whisper_type.to_i
					json.conversation_id  				a.dynamo_id.blank? ? '' : a.dynamo_id


					if a.target_user_id == current_user.id
						if !a.origin_user_id.nil?
							origin_user = User.find_user_by_unique(a.origin_user_id)
							if !origin_user.nil? and !current_user.nil?
								json.object_type  'user'
								json.object origin_user.user_object(current_user)
							end
						end
					else
						if !a.target_user_id.nil?
							origin_user = User.find_user_by_unique(a.target_user_id)
							if !origin_user.nil? and !current_user.nil?
								json.object_type  'user'
								json.object origin_user.user_object(current_user)
							end
						end
					end

					actions = Array.new
		            
		            if can_reply
		              actions << "chat"
		            end
	                actions << "delete"
		            
		            json.actions actions.uniq

					# reply message array
					messages_array = Array.new
					replies = ChattingMessage.where(whisper_id: a.id).order("created_at DESC")
					if replies.count > 0
						last_message = replies.first
					  	new_item = last_message.to_json(current_user)
		              	json.last_message new_item
		            
		            end
		            json.unread_message_count ChattingMessage.where(whisper_id: a.id).where.not(speaker_id: current_user.id).where(read: false).length
				end
			end
		end

		result = JSON.parse(result).delete_if(&:empty?)
		return result
	end


	def chatting_replies(current_user, page_number, per_page, read_messages)
		messages_array = Array.new
		if read_messages
	        ChattingMessage.where(whisper_id: self.id).where.not(speaker_id: current_user.id).update_all(read: true)
	    end
		replies = ChattingMessage.where(whisper_id: self.id).order("created_at DESC")

		result = Hash.new
		if !page_number.nil? and !per_page.nil? and per_page > 0 and page_number >= 0
	        pagination = Hash.new
	        pagination['page'] = page_number - 1
	        pagination['per_page'] = per_page
	        pagination['total_count'] = replies.length
	        result['pagination'] = pagination
	        replies = Kaminari.paginate_array(replies).page(page_number).per(per_page) if !replies.nil?
	    end
		if replies.count > 0
          	replies.each do |r|
	            new_item = r.to_json(current_user)
	            messages_array << new_item
          	end
        end

        result['messages'] = messages_array


        return result

	end

	def archive_conversation(current_user)
		Conversation.record_timestamps = false
		if self.target_user_id == current_user.id
			self.update(target_user_archieve: true)
		elsif self.origin_user_id == current_user.id
			self.update(origin_user_archieve: true)
		end
		Conversation.record_timestamps = true
	end


	def self.expire
		# introduction whispers
		expire_array = Conversation.where('conversations.created_at < ?', Time.now-12.hours).joins(:chatting_messages).group("conversations.id").having("count(chatting_messages.id) < ?",2)
		whisper_ids = expire_array.map(&:id)
		ChattingMessage.where(whisper_id: whisper_ids).delete_all
		Conversation.where(id: whisper_ids).delete_all
		
	end
end
