class WhisperNotification < AWS::Record::HashModel
  string_attr :target_id
  string_attr :origin_id

  integer_attr :timestamp
  string_attr :created_date
  string_attr :venue_id
  string_attr :notification_type
              # '0' => welcome
              # '1' => enter venue greeting
              # '2' => chat request
              # '3' => lottery
  boolean_attr :viewed
  boolean_attr :accepted


  #create user's Notification log in AWS DynamoDB
  def self.create_in_aws(target_id, origin_id, venue_id, notification_type)

    n = WhisperNotification.new
    n.target_id = target_id
    n.origin_id = origin_id
    n.venue_id = venue_id
    n.notification_type = notification_type
    n.timestamp = Time.now
    n.created_date = Date.today.to_s
    n.viewed = false
    n.accepted = false
    n.save!

    return n
  end

  def self.read_notification(id, user)
    # mark as 'viewed' in aws dynamoDB notification table
    # dynamo_db = AWS::DynamoDB.new
    # table = dynamo_db.tables['WhisperNotification']
    # table.load_schema
    # item = table.items.where(:id).equals(id.to_s).first
    item = WhisperNotification.find_by_dynamodb_id(id)
    if item.nil?
      return false
    else
      attributes = item.attributes.to_h
      notification_type = attributes['notification_type'].to_s
      if notification_type != "0"
        item.attributes.update do |u|
          u.set 'viewed' => 1
        end
      
        # number of notification to read for this user: -1
        if user.notification_read.nil? or user.notification_read <= 0
          user.notification_read = 0
        else
          user.notification_read = user.notification_read - 1
        end
        return user.save
      else
        return true
      end
    end
  end

  def self.venue_info(id)
    # dynamo_db = AWS::DynamoDB.new
    # table = dynamo_db.tables['WhisperNotification']
    # table.load_schema
    # item = table.items.where(:id).equals(id.to_s).first
    item = WhisperNotification.find_by_dynamodb_id(id)
    if item.nil?
      return nil
    else
      attributes = item.attributes.to_h
      venue_id = attributes['venue_id'].to_i
      if !venue_id.nil? and venue_id > 0
        return Venue.find(venue_id)
      else
        return nil
      end
    end
  end

  def self.find_by_dynamodb_id(id)
    dynamo_db = AWS::DynamoDB.new
    table = dynamo_db.tables['WhisperNotification']
    table.load_schema
    items = table.items.where(:id).equals(id.to_s)
    if items and items.count > 0
      return items.first
    else
      return nil
    end
  end

  def self.chat_accept(id)
    item = WhisperNotification.find_by_dynamodb_id(id)
    if item.nil?
      return false
    else
      attributes = item.attributes.to_h
      notification_type = attributes['notification_type'].to_s
      target_id = attributes['target_id'].to_s
      if notification_type == "2" 
        item.attributes.update do |u|
          u.set 'accepted' => 1
        end
        return true
      else
        return false
      end
    end
  end

  def self.my_chatting_requests(target_id)
    dynamo_db = AWS::DynamoDB.new
    table = dynamo_db.tables['WhisperNotification']
    table.load_schema
    items = table.items.where(:target_id).equals(target_id.to_s).where(:notification_type).equals("2")
    if items and items.count > 0
      request_user_array = Array.new
      items.each do |i|
        attributes = i.attributes.to_h
        origin_id = attributes['origin_id'].to_i
        user = User.find(origin_id)
        request_user_array << user if !user.nil?
      end
      return request_user_array
    else
      return nil
    end
  end

  def self.delete_notification(id, user)
    item = WhisperNotification.find_by_dynamodb_id(id)
    if item.nil?
      return false
    else
      attributes = item.attributes.to_h
      notification_type = attributes['notification_type'].to_s
      notification_read = attributes['notification_read'].to_i
      if notification_type != "0" and notification_read == 0
        if user.notification_read.nil? or user.notification_read <= 0
          user.notification_read = 0
        else
          user.notification_read = user.notification_read - 1
        end        
        user.save
      end
      item.delete
      return true
    end
    
  end

  def send_push_notification_to_target_user(message)
    #this shall be refactored once we have more phones to test with
    app_local_path = Rails.root

    if self.origin_id != "0"
      origin_user = User.find(self.origin_id) 
      origin_user_key = origin_user.key
    else
      origin_user_key = "SYSTEM"
    end
    target_user = User.find(self.target_id) 

    apn = Houston::Client.development
    apn.certificate = File.read("#{app_local_path}/apple_push_notification.pem")

    # An example of the token sent back when a device registers for notifications
    token = User.find(self.target_id).apn_token # "<443e69367fbbbce9c722fdf392f72af2111bde5626a916007d97382687d4b029>"
    # Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
    notification = Houston::Notification.new(device: token)
    notification.alert = message # "Hi #{target_user.first_name || "Whisper User"}, You got a Whisper!"

    # Notifications can also change the badge count, have a custom sound, have a category identifier, indicate available Newsstand content, or pass along arbitrary data.
    notification.badge = target_user.notification_read
    notification.sound = "sosumi.aiff"
    notification.category = "INVITE_CATEGORY"
    notification.content_available = true
    notification.custom_data = {
          whisper_id: self.id,
          origin_user: origin_user_key,
          target_user: target_user.key,
          timestamp: self.timestamp,
          target_apn: token,
          viewed: self.viewed,
          accepted: self.accepted,
          type: self.notification_type
          notification_badge: target_user.notification_read
      }
    # And... sent! That's all it takes.
    apn.push(notification)

  end

end