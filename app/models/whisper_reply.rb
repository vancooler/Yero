class WhisperReply < ActiveRecord::Base
  belongs_to :whisper, class_name: "WhisperToday", :foreign_key => 'whisper_id'

  # :nocov:
  def self.archive_history(whisper)
  	replies = whisper.whisper_replies.order("created_at DESC")

  	if replies.blank?

  	else
  		dynamo_db = AWS::DynamoDB.new
	    table_name = WhisperNotification.table_prefix + 'WhisperReplyHistory'
	    table = dynamo_db.tables[table_name]
	    if !table.schema_loaded?
	      table.load_schema
	    end

	    replies.each do |reply|
            target_id = (reply.whisper.origin_user_id == reply.speaker_id ? reply.whisper.target_user_id : reply.whisper.origin_user_id)
	    	item = table.items.put(:origin_id => reply.speaker_id, :timestamp => reply.created_at.to_i, :target_id => target_id, :message => reply.message, :whisper_dynamo_id => reply.whisper.dynamo_id)
	        # batch = AWS::DynamoDB::BatchWrite.new
	        # replies_array = Array.new
	        # replies_group.each do |reply|
	        #   if !reply.blank?
	        #     request = Hash.new()
	        #     request["origin_id"] = reply.speaker_id
	        #     request["timestamp"] = reply.created_at.to_i
	        #     request["whisper_dynamo_id"] = reply.whisper.dynamo_id
	        #     request["target_id"] = (reply.whisper.origin_user_id == reply.speaker_id ? reply.whisper.target_user_id : reply.whisper.origin_user_id)
	        #     request["message"] = reply.message
	        #     replies_array << request
	        #   end
	        # end
	        # if replies_array.count > 0
	        #   table_name = WhisperNotification.table_prefix + 'WhisperNotification'
	        #   batch.put(table_name, replies_array)
	        #   batch.process!
	        # end
	    end
	    
	end

	WhisperReply.where(:whisper_id => whisper.id).delete_all
	whisper.delete
  end
  # :nocov:


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
