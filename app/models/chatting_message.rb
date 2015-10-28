class ChattingMessage < ActiveRecord::Base
  belongs_to :whisper, class_name: "Conversation", :foreign_key => 'whisper_id'



  def to_json(current_user)
  	message_json = {
  		id: self.id,
		grouping_id: self.grouping_id,
		content_type: self.content_type.nil? ? 'text' : self.content_type,
		image_url: self.image_url.nil? ? '' : self.image_url,
		audio_url: self.audio_url.nil? ? '' : self.audio_url,
		conversation_id: self.whisper.dynamo_id.blank? ? '' : self.whisper.dynamo_id,
		speaker_id: self.speaker_id,
		timestamp: self.created_at.to_i,
		message: self.message.nil? ? '' : self.message,
		read: (self.speaker_id == current_user.id) ? true : self.read			            
  	}
  	return message_json
  end

  # :nocov:
  def send_push_notification_to_target_user(message, sender_id, receiver_id, content_path)
	deep_link = "yero://whispers/" + sender_id.to_s

    data = { :alert_message => message, :type => 2, :content_path => content_path, :'content-available' => 1, :deep_link => deep_link}
    push = Parse::Push.new(data, "User_" + receiver_id.to_s)
    push.type = "ios"
    begin  
      push.save
      result = true  
    rescue  
      p "Push notification error"
      result = false 
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
  # :nocov:

end
