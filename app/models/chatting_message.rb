class ChattingMessage < ActiveRecord::Base
  belongs_to :whisper, class_name: "Conversation", :foreign_key => 'whisper_id'


  # :nocov:
  def send_push_notification_to_target_user(message, sender_id, receiver_id)
	deep_link = "yero://whispers/" + sender_id.to_s

    data = { :alert_message => message, :type => 2, :badge => "Increment", :deep_link => deep_link}
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




  def self.migrate_grouping_timestamp
  	ChattingMessage.all.order("created_at ASC").each do |cm|
  		if cm.grouping_id.nil?
  			previous_messages = cm.whisper.chatting_messages.where(speaker_id: cm.speaker_id).where("created_at < ?", cm.created_at).order("created_at DESC")
  			if previous_messages.blank?
  				cm.update(grouping_id: cm.created_at.to_i)
  			else
  				cm.update(grouping_id: previous_messages.first.grouping_id)
  			end
  		end
  	end
  end
  # :nocov:

end
