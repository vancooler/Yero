class ChattingMessage < ActiveRecord::Base
  belongs_to :whisper, class_name: "Conversation", :foreign_key => 'whisper_id'



  def to_json(current_user)
  	message_json = {
  		id: self.client_side_id,
		grouping_id: self.grouping_id,
		content_type: self.content_type.nil? ? 'text' : self.content_type,
		image_url: self.image_url.nil? ? '' : self.image_url,
		audio_url: self.audio_url.nil? ? '' : self.audio_url,
		conversation_id: self.whisper.dynamo_id.blank? ? '' : self.whisper.dynamo_id,
		speaker_id: self.speaker_id,
		timestamp: ChattingMessage.createdTimestamp(self.created_at),
		message: self.message.nil? ? '' : self.message,
		read: (self.speaker_id == current_user.id) ? true : self.read			            
  	}
  	return message_json
  end

  # :nocov:
  def send_push_notification_to_target_user(message, sender_id, receiver_id, content_path)
  	conversation = self.whisper
  	receiver = User.find_user_by_unique(receiver_id)

	deep_link = "yero://whispers/" + sender_id.to_s
    data = { :alert_message => message, :type => 2, :content_path => content_path, :'content-available' => 1, :deep_link => deep_link}

    if receiver.id == conversation.target_user_id
    	last_alert_time = conversation.last_target_user_push_time
    elsif receiver.id == conversation.origin_user_id
    	last_alert_time = conversation.last_origin_user_push_time
    end
  	current_push = Time.now.to_i
  	# initial or 1 hour later or message has been read
  	if conversation.chatting_messages.where.not(speaker_id: receiver.id).blank?
  		data[:alert] = message
  		data[:badge] = "Increment"
  	elsif last_alert_time.nil?
  		data[:alert] = message
  		data[:badge] = "Increment"
  	elsif !(!receiver.nil? and !receiver.last_active.nil? and receiver.last_active.to_i <= last_alert_time)
  		data[:alert] = message
  		data[:badge] = "Increment"
  	elsif last_alert_time + 3600 < current_push
  		data[:alert] = message
  		data[:badge] = "Increment"
  	end


  	# Scenarios getting alert and increment:
  	# 1. initial whisper
  	# 2. last alert notification was cleared
  	# 3. last alert notification was 1 hour ago


    push = Parse::Push.new(data, "User_" + receiver_id.to_s)
    push.type = "ios"
    begin  
      push.save
      result = true  
    rescue  
      p "Push notification error"
      result = false 
    end 

    # update last push alert time
    if result and !data[:badge].nil? and data[:badge] == "Increment"
    	if receiver.id == conversation.target_user_id
	    	conversation.last_target_user_push_time = Time.now.to_i
	    elsif receiver.id == conversation.origin_user_id
	    	conversation.last_origin_user_push_time = Time.now.to_i
	    end
	    conversation.save
    end
    return result 
  end



  # migrate grouping id for legacy chatting messages
  def self.migrate_grouping_timestamp
  	ChattingMessage.all.order("created_at ASC").each do |cm|
  		if cm.grouping_id.nil? or true
  			previous_messages = cm.whisper.chatting_messages.where("created_at < ?", cm.created_at).order("created_at DESC")
  			if previous_messages.blank?
  				cm.update(grouping_id: cm.created_at.to_i)
  			else
  				last_grouping_id = previous_messages.first.grouping_id
  				if !last_grouping_id.nil? and cm.created_at.to_i <= last_grouping_id + 15*60
	  				cm.update(grouping_id: last_grouping_id)
	  			else
	  				cm.update(grouping_id: cm.created_at.to_i)
	  			end
  			end
  		end
  	end
  end

  def self.createdTimestamp(datetime)
  	ns = datetime.strftime('%N')
  	if ns.length < 9
  	    ns += (0...(9-ns.length)).map {'0'}.join
  	end
  	return ns.to_i/1000000000.0 + datetime.to_i
  end

  def self.float_to_timestamp(timestamp)
  	time_array = timestamp.to_s.split(".")
    if time_array.count > 1
      ns = time_array[1]
      if ns.length < 6
  	    ns += (0...(6-ns.length)).map {'0'}.join
	  end
      timestamp_with_ns = Time.at(timestamp.to_i, ns.to_i)
    else
      timestamp_with_ns = Time.at(timestamp)
    end
    return timestamp_with_ns
  end

  def self.migrate_client_side_id
  	ChattingMessage.all.order("created_at ASC").each do |cm|
  		if cm.client_side_id.nil? 
  			client_side_id = ChattingMessage.generate_client_side_id(cm.whisper.dynamo_id, cm.speaker_id, cm.created_at)
			cm.update(client_side_id: client_side_id)
  		end
  	end
  end
  # :nocov:

  def self.generate_client_side_id(whisper_id, speaker_id, timestamp)
  	return whisper_id.to_s + '_' + speaker_id.to_s + '_' + ChattingMessage.createdTimestamp(timestamp).to_s
  end
end
