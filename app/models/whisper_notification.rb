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
  integer_attr :accepted
              # 0 => nothing
              # 1 => accepted
              # 2 => declined


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
        return true
        # number of notification to read for this user: -1
        # if user.notification_read.nil? or user.notification_read <= 0
        #   user.notification_read = 0
        # else
        #   user.notification_read = user.notification_read - 1
        # end
        # return user.save
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

  def self.find_friends(user_id)
    dynamo_db = AWS::DynamoDB.new # Make an AWS DynamoDB object
    table = dynamo_db.tables['WhisperNotification'] # Choose the 'WhisperNotification' table
    table.load_schema 
    # :notification_type. '1' => enter venue greeting, '2' => chat request
    # :accepted. 0 => nothing, 1 => accepted, 2 => declined
    # sender_items = select items where target_id equals the user_id and where the notification_type is a chat request that has been accepted
    # target_id is the user id that receives the request
    target_items = table.items.where(:target_id).equals(user_id.to_s).where(:notification_type).equals("2").where(:accepted).equals(1)
    # receiver_items = select items where origin_id equals user_id and where the notification_type is a chat request that has been accepted
    # origin_id is the user id that sent the request
    origin_items = table.items.where(:origin_id).equals(user_id.to_s).where(:notification_type).equals("2").where(:accepted).equals(1)
    target_user_array = Array.new
    origin_user_array = Array.new
    if target_items and target_items.count > 0
      target_items.each do |i|
        attributes = i.attributes.to_h
        origin_id = attributes['origin_id'].to_i
        h = Hash.new
        if origin_id > 0
          user = User.find(origin_id)
          h['origin_user'] = user
          h['origin_user_thumb'] = user.main_avatar.avatar.thumb.url
        else
          h['origin_user'] = ''
        end
        h['timestamp'] = attributes['timestamp'].to_i
        h['whisper_id'] = attributes['id']
        h['accepted'] = attributes['accepted'].to_i
        h['my_role'] = 'target_user'
        target_user_array << h
      end
      # return target_user_array
    end
    # if origin_items and origin_items.count > 0
    #   origin_items.each do |i|
    #     attributes = i.attributes.to_h
    #     target_id = attributes['target_id'].to_i
    #     h = Hash.new
    #     if target_id > 0
    #       user = User.find(target_id)
    #       h['target_user'] = user
    #       h['target_user_thumb'] = user.main_avatar.avatar.thumb.url
    #     else
    #       h['target_user'] = ''
    #     end
    #     h['timestamp'] = attributes['timestamp'].to_i
    #     h['whisper_id'] = attributes['id']
    #     h['accepted'] = attributes['accepted'].to_i
    #     h['my_role'] = 'origin_user'
    #     origin_user_array << h
    #   end
    #   # return origin_user_array
    # end
    users = Array.new
    users = target_user_array + origin_user_array
    users = users.sort_by { |hsh| hsh[:timestamp] }

    return users.reverse
  end

  def self.system_notification(user_id)
    dynamo_db = AWS::DynamoDB.new # Make an AWS DynamoDB object
    table = dynamo_db.tables['WhisperNotification'] # Choose the 'WhisperNotification' table
    table.load_schema 
    # Retrieve the system notifications that were sent by the venue, with notification_type = 1
    venue_items = table.items.where(:target_id).equals(user_id.to_s).where(:notification_type).equals("1")
    venue = Array.new # Make a new hash object
    venue_items.each do |i| # For each item
      attributes = i.attributes.to_h # Turn each item into a hash
      venue_id = attributes['venue_id'].to_i # Turn venue id into a integer
      h = Hash.new # Make a new hash object
      if venue_id > 0 
        if venue.include? venue_id #venue id already in there, then do nothing
        else
          venue.push(venue_id) # Throw venue_id into the array
        end
      end
    end
    return venue
  end

  def self.chat_action(id, handle_action)
    item = WhisperNotification.find_by_dynamodb_id(id)
    if item.nil?
      return false
    else
      attributes = item.attributes.to_h
      notification_type = attributes['notification_type'].to_s
      target_id = attributes['target_id'].to_s
      if notification_type == "2" 
        Rails.logger.info "ACTION: " + handle_action
        item.attributes.update do |u|
          if handle_action == 'accept'
            Rails.logger.info "ACCEPT!!"
            u.set 'accepted' => 1
          elsif handle_action == 'decline'
            u.set 'accepted' => 2
          end
            
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
    items = table.items.where(:target_id).equals(target_id.to_s).where(:notification_type).equals("2").where(:accepted).equals(0)
    if items and items.count > 0
      request_user_array = Array.new
      items.each do |i|
        attributes = i.attributes.to_h
        origin_id = attributes['origin_id'].to_i
        h = Hash.new
        if origin_id > 0
          user = User.find(origin_id)
          h['origin_user'] = user
          avatar_array = Array.new
          avatar_array[0] = {
            thumbnail: user.main_avatar.avatar.thumb.url
          }
          avatar_array[1] = {
            avatar: user.main_avatar.nil? ? '' : user.main_avatar.avatar.url,
            avatar_id: user.main_avatar.nil? ? '' : user.main_avatar.id,
            default: true
          }
          
          h['avatars'] = avatar_array
        else
          h['origin_user'] = ''
        end
        h['since_1970'] = attributes['timestamp'].to_i
        h['whisper_id'] = attributes['id']
        request_user_array << h
      end
      request_user_array = request_user_array.sort_by { |hsh| hsh[:since_1970] }
      return request_user_array.reverse
    else
      return nil
    end
  end

  def self.my_chat_request_history(user)
    dynamo_db = AWS::DynamoDB.new
    table = dynamo_db.tables['WhisperNotification']
    table.load_schema
    target_items = table.items.where(:target_id).equals(user.id.to_s).where(:notification_type).equals("2")
    origin_items = table.items.where(:origin_id).equals(user.id.to_s).where(:notification_type).equals("2")
    target_user_array = Array.new
    origin_user_array = Array.new
    if target_items and target_items.count > 0
      target_items.each do |i|
        attributes = i.attributes.to_h
        origin_id = attributes['origin_id'].to_i
        h = Hash.new
        if origin_id > 0
          user = User.find(origin_id)
          h['origin_user'] = user
          h['origin_user_thumb'] = user.main_avatar.avatar.thumb.url
        else
          h['origin_user'] = ''
        end
        h['timestamp'] = attributes['timestamp'].to_i
        h['whisper_id'] = attributes['id']
        h['accepted'] = attributes['accepted'].to_i
        h['my_role'] = 'target_user'
        target_user_array << h
      end
      # return target_user_array
    end
    if origin_items and origin_items.count > 0
      origin_items.each do |i|
        attributes = i.attributes.to_h
        target_id = attributes['target_id'].to_i
        h = Hash.new
        if target_id > 0
          user = User.find(target_id)
          h['target_user'] = user
          h['target_user_thumb'] = user.main_avatar.avatar.thumb.url
        else
          h['target_user'] = ''
        end
        h['timestamp'] = attributes['timestamp'].to_i
        h['whisper_id'] = attributes['id']
        h['accepted'] = attributes['accepted'].to_i
        h['my_role'] = 'origin_user'
        origin_user_array << h
      end
      # return origin_user_array
    end
    users = Array.new
    users = target_user_array + origin_user_array
    users = users.sort_by { |hsh| hsh[:timestamp] }
    return users.reverse
  end

  def self.get_info(user)
    dynamo_db = AWS::DynamoDB.new
    table = dynamo_db.tables['WhisperNotification']
    table.load_schema
    items = table.items.where(:target_id).equals(user.id.to_s).where(:notification_type).equals('1')
    if items and items.count > 0
      # * venue name
      # * message and date  <— hardcode
      # * timestamp
      # * whisper_id
      # * viewed
      request_array = Array.new
      items.each do |i|
        n = Hash.new
        attributes = i.attributes.to_h
        venue_id = attributes['venue_id'].to_i
        if venue_id > 0
          venue = Venue.find(venue_id)
          if venue.nil?
            n['venue_name'] = ''
          else
            n['venue_name'] = venue.name
          end
        else
          n['venue_name'] = ''
        end
        n['message'] = 'HARD CODE MESSAGE'
        n['date'] = 'HARD CODE DATE'
        n['timestamp'] = attributes['timestamp'].to_i
        n['whisper_id'] = attributes['id']
        n['viewed'] = attributes['viewed'].to_i
        n['notification_type'] = attributes['notification_type'].to_i
        request_array << n
      end
      request_array = request_array.sort_by { |hsh| hsh[:timestamp] }
      return request_array.reverse
    else
      return nil
    end
  end

  def self.delete_notification(id, user)
    item = WhisperNotification.find_by_dynamodb_id(id)
    if item.nil?
      return false
    else
      # attributes = item.attributes.to_h
      # notification_type = attributes['notification_type'].to_s
      # viewed = attributes['viewed']
      # if notification_type != "0" and viewed == 0
      #   if user.notification_read.nil? or user.notification_read <= 0
      #     user.notification_read = 0
      #   else
      #     user.notification_read = user.notification_read - 1
      #   end        
      #   user.save
      # end
      item.delete
      return true
    end
    
  end

  def self.decline_all_chat(user, ids_array)
    dynamo_db = AWS::DynamoDB.new
    table = dynamo_db.tables['WhisperNotification']
    table.load_schema
    items = table.items.where(:target_id).equals(user.id.to_s).where(:notification_type).equals("2").where(:accepted).equals(0)
    items.each do |item|
      attributes = item.attributes.to_h
      accepted = attributes['accepted']
      id = attributes['id']
      # check whether is in the array params
      if ids_array.include?(id) 
        item.attributes.update do |u|
          u.set 'accepted' => 2          
        end
      end
    end
    
    return true
  end

  # Function signifies whether the user has sent a whisper to the target user
  def self.whisper_sent(origin_user, target_user)
    dynamo_db = AWS::DynamoDB.new
    table = dynamo_db.tables['WhisperNotification']
    table.load_schema
    items = table.items.where(:target_id).equals(target_user.id.to_s).where(:origin_id).equals(origin_user.id.to_s).where(:notification_type).equals("2")
    if items.present? and items.count > 0
      return true
    else
      return false
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
    
    #get badge number
    dynamo_db = AWS::DynamoDB.new
    table = dynamo_db.tables['WhisperNotification']
    table.load_schema
    chat_items = table.items.where(:target_id).equals(target_user.id.to_s).where(:notification_type).equals("2").where(:viewed).equals(0)
    greeting_items = table.items.where(:target_id).equals(target_user.id.to_s).where(:notification_type).equals("1").where(:viewed).equals(0)
    chat_request_number = 0
    venue_greeting_number = 0
    if chat_items.present?
      chat_request_number = chat_items.count
    end
    if greeting_items.present?
      venue_greeting_number = greeting_items.count
    end

    # Notifications can also change the badge count, have a custom sound, have a category identifier, indicate available Newsstand content, or pass along arbitrary data.
    notification.badge = (chat_request_number+venue_greeting_number)
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
          type: self.notification_type.to_i,
          chat_request_number: chat_request_number,
          venue_greeting_number: venue_greeting_number
      }
    # And... sent! That's all it takes.
    apn.push(notification)

  end

end