class ChattingMessage < ActiveRecord::Base
  belongs_to :whisper, class_name: "Conversation", :foreign_key => 'whisper_id'


  # :nocov:
  def send_push_notification_to_target_user(message, sender_id, receiver_id)
	deep_link = "yero://whispers/" + sender_id.to_s

    data = { :alert => message, :type => 2, :badge => "Increment", :deep_link => deep_link}
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
  # :nocov:

end
