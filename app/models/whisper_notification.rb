class WhisperNotification < AWS::Record::HashModel
  string_attr :target_id
  string_attr :origin_id

  integer_attr :timestamp
  integer_attr :expired
  string_attr :created_date
  string_attr :venue_id
  string_attr :intro
  string_attr :notification_type

              # '1' => enter venue greeting
              # '2' => chat whisper request
              # '3' => accept whisper request
              # 100 level means system notifications
              # '100' => network open
              # '101' => avatar disable
              # '102' => enough users now
              # 200 level means system activity records
              # '200' => join network
              # '201' => leave network
  boolean_attr :viewed                 #0->1
  boolean_attr :not_viewed_by_sender   #1->0
  integer_attr :accepted
              # 0 => nothing
              # 1 => accepted
              # 2 => declined
  integer_attr :declined
              # 0 => nothing
              # 1 => accepted
              # 2 => declined

  def self.table_prefix
    dynamo_db_table_prefix = ''
    if !ENV['DYNAMODB_PREFIX'].blank?
      dynamo_db_table_prefix = ENV['DYNAMODB_PREFIX']
    end
    return dynamo_db_table_prefix
  end

  #create user's Notification log in AWS DynamoDB
  def self.create_in_aws(target_id, origin_id, venue_id, notification_type, intro)

    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    n = WhisperNotification.shard(table_name).new
    n.target_id = target_id
    n.origin_id = origin_id
    n.venue_id = venue_id
    n.notification_type = notification_type
    n.intro = intro
    n.timestamp = Time.now
    n.created_date = Date.today.to_s
    n.viewed = false
    n.not_viewed_by_sender = true
    n.accepted = false
    if notification_type.to_i == 2
      n.expired = false
    end
    n.save!

    p "n:"
    p n.inspect

    return n
  end


  # expire at 5 am
  def self.expire(people_array, notification_type)
    dynamo_db = AWS::DynamoDB.new
    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    table = dynamo_db.tables[table_name]
    if !table.schema_loaded?
      table.load_schema
    end
    puts "Read time: "
    people_array_string = Array.new
    people_array.each do |p|
      people_array_string << p.to_s
    end
    items = table.items.where(:target_id).in(*people_array_string).where(:notification_type).equals(notification_type).select(:target_id, :origin_id, :declined, :intro, :venue_id, :notification_type, :viewed, :id, :created_date, :timestamp, :not_viewed_by_sender, :accepted)
    
    items.each_slice(25) do |whisper_group|
      batch = AWS::DynamoDB::BatchWrite.new
      notification_array = Array.new
      whisper_group.each do |w|
        if !w.blank?
          attributes = w.attributes
          request = Hash.new()
          request["target_id"] = attributes['target_id']
          request["timestamp"] = attributes['timestamp']
          request["id"] = attributes['id'] if !attributes['id'].nil?
          request["origin_id"] = attributes['origin_id'] if !attributes['origin_id'].nil?
          request["accepted"] = attributes['accepted'] if !attributes['accepted'].nil?
          request["declined"] = attributes['declined'] if !attributes['declined'].nil?
          request["created_date"] = attributes['created_date'] if !attributes['created_date'].nil?
          request["venue_id"] = attributes['venue_id'] if !attributes['venue_id'].nil?
          request["notification_type"] = attributes['notification_type'] if !attributes['notification_type'].nil?
          request["intro"] = attributes['intro'] if !attributes['intro'].nil?
          request["viewed"] = attributes['viewed'] if !attributes['viewed'].nil?
          request["not_viewed_by_sender"] = attributes['not_viewed_by_sender'] if !attributes['not_viewed_by_sender'].nil?
          request["expired"] = 1
          notification_array << request 
        end
      end
      if notification_array.count > 0
        batch.put(table_name, notification_array)
        batch.process!
      end
    end

  end

  def self.read_notification(id, user)
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
      else
        return true
      end
    end
  end

  def self.venue_info(id)
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
    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    table = dynamo_db.tables[table_name]
    if !table.schema_loaded?
      table.load_schema
    end
    items = table.items.where(:id).equals(id.to_s)
    if items and items.count > 0
      return items.first
    else
      return nil
    end
  end


  def self.system_notification(user_id)
    dynamo_db = AWS::DynamoDB.new # Make an AWS DynamoDB object
    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    table = dynamo_db.tables[table_name] # Choose the table
    if !table.schema_loaded?
      table.load_schema 
    end
    # Retrieve the system notifications that were sent by the venue, with notification_type = 1
    # Expire rule change!!!
    venue_items = table.items.where(:target_id).equals(user_id.to_s).where(:expired).equals(0).where(:notification_type).equals("1").select(:venue_id, :viewed, :id, :created_date, :timestamp, :not_viewed_by_sender, :accepted)
    venue = Array.new # Make a new hash object
    exist_venue_id = Array.new
    venue_items.each do |i| # For each item
      
      attributes = i.attributes
      venue_id = attributes['venue_id'].to_i # Turn venue id into a integer
      h = Hash.new # Make a new hash object
      # v = Venue.find(venue_id)
      if Venue.exists? id: venue_id
        if exist_venue_id.include? venue_id #venue id already in there, then do nothing
        else
          h['venue_id'] = attributes['venue_id']
          h['timestamp'] = attributes['timestamp'].to_i
          h['accepted'] = attributes['accepted']
          h['viewed'] = attributes['viewed']
          h['not_viewed_by_sender'] = attributes['not_viewed_by_sender']
          h['created_date'] = attributes['created_date']
          h['whisper_id'] = attributes['id']
          venue << h # Throw venue_id into the array
          exist_venue_id << venue_id
        end
      end
    end
    return venue
  end

  # Retrive whispers
  def self.find_friends(user_id)
    time_0 = Time.now

    dynamo_db = AWS::DynamoDB.new # Make an AWS DynamoDB object
    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    table = dynamo_db.tables[table_name] # Choose the table
    if !table.schema_loaded?
      table.load_schema 
    end
    # Target_id is the receiver of the messages
    # Expire rule change!!!
    receiver_items = table.items.where(:target_id).equals(user_id.to_s).where(:expired).equals(0).where(:notification_type).equals("2").where(:accepted).equals(0).where(:declined).not_equal_to(1).select(:origin_id, :viewed, :id, :created_date, :timestamp, :not_viewed_by_sender, :accepted, :declined, :intro)
    time_1 = Time.now
    runtime = time_1 - time_0
    puts "Read user time"
    puts runtime.inspect
    receiver_items_array = Array.new
    if receiver_items and receiver_items.count > 0
      receiver_items.each do |i|
        attributes = i.attributes
        sender_id = attributes['origin_id'].to_i
        h = Hash.new
        if User.exists? id: sender_id
          user = User.find(sender_id)
          h['target_user'] = user
          if user.main_avatar
            h['target_user_thumb'] = user.main_avatar.avatar.thumb.url
            h['target_user_main'] = user.main_avatar.avatar.url
            if user.secondary_avatars
              h['target_user_secondary1'] = user.user_avatars.count > 1 ? user.secondary_avatars.first.avatar.url : ""
              h['target_user_secondary2'] = user.user_avatars.count > 2 ? user.secondary_avatars.last.avatar.url : ""
            end
          end
        else
          h['target_user'] = ''
        end
        h['timestamp'] = attributes['timestamp'].to_i

        # expire rule change!!
        # h['seconds_left'] = attributes['timestamp'].to_i + 4*3600 - Time.now.to_i + 60
        # expire_timestamp = UserLocation.tomorrow_close_timestamp(user_id.to_i, attributes['timestamp'])
        current_user = User.find_by_id(user_id)
        if current_user
          hour = DateTime.strptime(attributes['timestamp'].to_s, "%s").in_time_zone(current_user.timezone_name).hour
          if hour >= 5
            expire_timestamp = DateTime.strptime(attributes['timestamp'].to_s,'%s').in_time_zone(current_user.timezone_name).tomorrow.beginning_of_day + 5.hours
          else
            expire_timestamp = DateTime.strptime(attributes['timestamp'].to_s,'%s').in_time_zone(current_user.timezone_name).beginning_of_day + 5.hours            
          end
          h['seconds_left'] = expire_timestamp.to_i - Time.now.to_i + 60
          h['expire_timestamp'] = expire_timestamp.to_i
        else
          h['seconds_left'] = 3600*12
          h['expire_timestamp'] = Time.now.to_i + 3600*12
        end
        h['accepted'] = attributes['accepted'].to_i
        h['declined'] = attributes['declined'].to_i
        h['viewed'] = attributes['viewed'].to_i
        h['whisper_id'] = attributes['id']
        h['not_viewed_by_sender'] = attributes['not_viewed_by_sender'].to_i
        h['intro'] = attributes['intro']
        receiver_items_array << h
      end
    end
    users = Array.new
    users = receiver_items_array
    users = users.sort_by { |hsh| hsh[:timestamp] }
    
    time_2 = Time.now
    runtime = time_2 - time_1
    puts "Adjust user time"
    puts runtime.inspect
    return users.reverse
  end

  # TODO: use it for friends request
  def self.myfriends(user_id)
    # t0 = Time.now
    # dynamo_db = AWS::DynamoDB.new # Make an AWS DynamoDB object
    # table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    # table = dynamo_db.tables[table_name] # Choose the table
    # if !table.schema_loaded?
    #   table.load_schema 
    # end
    # current_user = User.find(user_id)
    # friends_accepted = table.items.where(:origin_id).equals(user_id.to_s).where(:notification_type).equals("3").select(:target_id, :id, :timestamp)
    # friends_whispered = table.items.where(:target_id).equals(user_id.to_s).where(:notification_type).equals("3").select(:origin_id, :id, :timestamp)
    # t1 = Time.now
    # first_friends_array = Array.new
    # second_friends_array = Array.new
    # first_friends_id_array = Array.new
    # second_friends_id_array = Array.new
    # if friends_accepted and friends_accepted.count > 0
    #   friends_accepted.each do |friend|
    #     attributes = friend.attributes
    #     friend_id = attributes['target_id'].to_i
    #     h = Hash.new
    #     p 'in the loop'
    #     p friend_id
    #     if first_friends_id_array.include? friend_id
    #       p 'in the array'
    #     else
    #       first_friends_id_array << friend_id
    #       if friend_id > 0
    #         if User.exists? id: friend_id
    #           user = User.find(friend_id)
    #           h['target_user_id'] = user.id          
    #           h['intro'] = user.introduction_1
    #           h['target_user'] = user
    #           # if user.main_avatar
    #           #   h['target_user_thumb'] = user.main_avatar.avatar.thumb.url
    #           #   h['target_user_main'] = user.main_avatar.avatar.url
    #           #   if user.secondary_avatars
    #           #     h['target_user_secondary1'] = user.user_avatars.count > 1 ? user.secondary_avatars.first.avatar.url : ""
    #           #     h['target_user_secondary2'] = user.user_avatars.count > 2 ? user.secondary_avatars.last.avatar.url : ""
    #           #   end
    #           # end
    #         else
    #           h['target_user'] = ''
    #         end
    #       else
    #           h['target_user'] = ''
    #       end
    #       h['id'] = attributes['id']
    #       h['timestamp'] = attributes['timestamp'].to_i
    #       h['timestamp_read'] = Time.at(attributes['timestamp']) # TODO: change format
    #       first_friends_array << h  
    #     end 
    #   end
    # end

    # if friends_whispered and friends_whispered.count > 0
    #   friends_whispered.each do |friend|
    #     attributes = friend.attributes
    #     friend_id = attributes['origin_id'].to_i
    #     h = Hash.new
    #     p 'in the loop'
    #     p friend_id
    #     if second_friends_id_array.include? friend_id
    #       p 'in the array'
    #     else
    #       second_friends_id_array << friend_id
    #       if friend_id > 0
    #         if User.exists? id: friend_id
    #           user = User.find(friend_id)
    #           h['target_user_id'] = user.id
    #           h['intro'] = user.introduction_1
    #           h['target_user'] = user
    #           # if user.main_avatar
    #           #   h['target_user_thumb'] = user.main_avatar.avatar.thumb.url
    #           #   h['target_user_main'] = user.main_avatar.avatar.url
    #           #   if user.secondary_avatars
    #           #     h['target_user_secondary1'] = user.user_avatars.count > 1 ? user.secondary_avatars.first.avatar.url : ""
    #           #     h['target_user_secondary2'] = user.user_avatars.count > 2 ? user.secondary_avatars.last.avatar.url : ""
    #           #   end
    #           # end
    #         else
    #           h['target_user'] = ''
    #         end
    #       else
    #           h['target_user'] = ''
    #       end
    #       h['id'] = attributes['id']
    #       h['timestamp'] = attributes['timestamp'].to_i
    #       h['timestamp_read'] = Time.at(attributes['timestamp']) # TODO: change format
    #       second_friends_array << h  
    #     end 
    #   end
    # end
    # t2 = Time.now

    current_user = User.find(user_id)
    friends = Array.new
    # Friends by whisper
    friends_by_whisper = FriendByWhisper.friends(user_id)
    friends_by_whisper.each do |user|
      h = Hash.new
      friend_id = user.id
      h['intro'] = user.introduction_1
      h['target_user_id'] = user.id
      h['target_user'] = user
      timestamp = FriendByWhisper.find_time(user.id, user_id).to_i
      h['timestamp'] = timestamp
      h['timestamp_read'] = Time.at(timestamp) # TODO: change format
      friends << h  

    end
    # Friends by like
    mutual_follow = current_user.friends_by_like
    mutual_follow_array = Array.new
    mutual_follow.each do |user|
      h = Hash.new
      friend_id = user.id
          h['intro'] = user.introduction_1
          h['target_user_id'] = user.id
          h['target_user'] = user
          # if user.main_avatar
          #   h['target_user_thumb'] = user.main_avatar.avatar.thumb.url
          #   h['target_user_main'] = user.main_avatar.avatar.url
          #   if user.secondary_avatars
          #     h['target_user_secondary1'] = user.user_avatars.count > 1 ? user.secondary_avatars.first.avatar.url : ""
          #     h['target_user_secondary2'] = user.user_avatars.count > 2 ? user.secondary_avatars.last.avatar.url : ""
          #   end
          # end
          
          timestamp_1 = Follow.where(:follower_type => "User", :follower_id => user.id, :followable_type => "User", :followable_id => current_user.id).first.created_at.to_i
          timestamp_2 = Follow.where(:follower_type => "User", :follower_id => current_user.id, :followable_type => "User", :followable_id => user.id).first.created_at.to_i
          h['timestamp'] = (timestamp_1 > timestamp_2) ? timestamp_1 : timestamp_2
          h['timestamp_read'] = Time.at(h['timestamp']) # TODO: change format
          mutual_follow_array << h  

    end
    
    users = Array.new
    users = friends | mutual_follow_array
    users = users.group_by { |x| x['target_user_id'] }.map {|x,y|y.max_by {|x|x['timestamp']}}

    users = users.sort_by { |hsh| hsh['timestamp'] }

    return users.reverse

  end

  def self.friends_activity_to_json(friends, current_user)
    origin_user_array = Array.new
    if friends and friends.count > 0
      friends.each do |i|
        h = Hash.new
        h['activity_type'] = 'Became Friends'
        h['object_type'] = 'user'
        target_user = User.find_by_id(i["target_user"]["id"].to_i)
        if !target_user.nil?
          user_object = target_user.user_object(current_user)
        end

        h['object'] = user_object
        h['activity_id'] = (i['id'].blank? ? 'friends-'+current_user.id.to_s+'-'+target_user.id.to_s+'-'+i['timestamp'].to_i.to_s : i['id'])
        # h['my_role'] = 'target_user'
        h['timestamp'] = i['timestamp']
        # a = [h, Time.at(attributes['timestamp'].to_i).utc]
        origin_user_array << h
      end
    end
    return origin_user_array
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

  # NOT used
  def self.my_chatting_requests(target_id)
    dynamo_db = AWS::DynamoDB.new
    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    table = dynamo_db.tables[table_name]
    if !table.schema_loaded?
      table.load_schema
    end
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

  def self.my_chat_request_history(user, page_number, whispers_per_page)
    t0 = Time.now
    dynamo_db = AWS::DynamoDB.new
    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    table = dynamo_db.tables[table_name]
    if !table.schema_loaded?
      table.load_schema
    end
    current_user = user
    activity_notification_types = ["200", "201"]
    target_items = table.items.where(:target_id).equals(user.id.to_s).where(:notification_type).equals("2").select(:origin_id, :id, :timestamp)
    origin_items = table.items.where(:origin_id).equals(user.id.to_s).where(:notification_type).equals("2").select(:target_id, :id, :timestamp)
    activity_items = table.items.where(:target_id).equals(user.id.to_s).where(:notification_type).in(*activity_notification_types).select(:id, :timestamp, :notification_type)
    friends = WhisperNotification.myfriends(user.id)
    is_friends = true
    friends = WhisperNotification.friends_activity_to_json(friends, user)
    disabled_avatars = table.items.where(:target_id).equals(user.id.to_s).where(:notification_type).equals("101").select(:id, :timestamp)
    origin_user_array = Array.new
    t1 = Time.now
    t = 0
    if target_items and target_items.count > 0
      target_items.each do |i|
        tb = Time.now
        attributes = i.attributes
        origin_id = attributes['origin_id'].to_i
        h = Hash.new
        h['activity_type'] = 'Received Whisper'
        h['object_type'] = 'user'
        if origin_id > 0
          if User.exists? id: origin_id
            user = User.find(origin_id)
            h['object'] = user.user_object(current_user)
          else
            h['object'] = ''
          end
        else
          h['object'] = ''
        end
        ta = Time.now
        t += (ta-tb)
        h['activity_id'] = attributes['id']
        # h['my_role'] = 'target_user'
        h['timestamp'] = attributes['timestamp'].to_i
        # a = [h, Time.at(attributes['timestamp'].to_i).utc]
        origin_user_array << h
      end
    end
    if origin_items and origin_items.count > 0
      origin_items.each do |i|
        tb = Time.now
        attributes = i.attributes
        target_id = attributes['target_id'].to_i
        h = Hash.new
        h['activity_type'] = 'Sent Whisper'
        h['object_type'] = 'user'
        if target_id > 0
          if User.exists? id: target_id
            user = User.find(target_id)
            h['object'] = user.user_object(current_user)
          else
            h['object'] = ''
          end
        else
          h['object'] = ''
        end
        ta = Time.now
        t += (ta-tb)
        h['activity_id'] = attributes['id']
        # h['my_role'] = 'origin_user'
        h['timestamp'] = attributes['timestamp'].to_i
        # a = [h, Time.at(attributes['timestamp'].to_i).utc]
        origin_user_array << h
      end 
    end
    if activity_items and activity_items.count > 0
      activity_items.each do |i|
        tb = Time.now
        attributes = i.attributes
        target_id = attributes['target_id'].to_i
        h = Hash.new
        h['activity_type'] = ((attributes['notification_type'].to_i == 200) ? 'Joined Network' : 'Offline')
        h['activity_id'] = attributes['id']
        # h['my_role'] = 'target_user'
        h['timestamp'] = attributes['timestamp'].to_i
        # a = [h, Time.at(attributes['timestamp'].to_i).utc]
        ta = Time.now
        t += (ta-tb)
        origin_user_array << h
      end
    end
    if disabled_avatars and disabled_avatars.count > 0
      disabled_avatars.each do |i|
        tb = Time.now
        attributes = i.attributes
        target_id = attributes['target_id'].to_i
        h = Hash.new
        h['activity_type'] = 'Profile Avatar Disabled'
        h['activity_id'] = attributes['id']
        # h['my_role'] = 'target_user'
        h['timestamp'] = attributes['timestamp'].to_i
        # a = [h, Time.at(attributes['timestamp'].to_i).utc]
        origin_user_array << h
        ta = Time.now
        t += (ta-tb)
      end
    end
    if !friends.empty?
      origin_user_array = origin_user_array + friends
    end
    users = origin_user_array.sort_by { |hsh| hsh['timestamp'] }
    users = users.reverse!
    if !page_number.nil? and !whispers_per_page.nil? and whispers_per_page > 0 and page_number >= 0
      users = Kaminari.paginate_array(users).page(page_number).per(whispers_per_page) if !users.nil?
    end
    t2 = Time.now
    puts "gether time: "
    puts (t1-t0).inspect
    puts "json time: "
    puts (t2-t1).inspect
    puts "Activity time: "
    puts (t2-t0).inspect
    puts "Special time: "
    puts t.inspect

    return users
  end

  def self.get_info(user)
    dynamo_db = AWS::DynamoDB.new
    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    table = dynamo_db.tables[table_name]
    if !table.schema_loaded?
      table.load_schema
    end
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
    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    table = dynamo_db.tables[table_name]
    if !table.schema_loaded?
      table.load_schema
    end
    items = table.items.where(:target_id).equals(user.id.to_s).where(:notification_type).equals("2").where(:accepted).equals(0)
    items.each do |item|
      attributes = item.attributes.to_h
      accepted = attributes['accepted']
      id = attributes['id']
      # check whether is in the array params
      if ids_array.include?(id) 
        item.attributes.update do |u|
          u.set 'accepted' => 2 
          u.set 'declined' => 1         
        end
      end
    end
    
    return true
  end

  # Function that gets all the users received whisper from current user
  def self.collect_whispers(current_user)
    array = WhisperSent.where(['whisper_time > ?', Time.now-12.hours]).where(:origin_user_id => current_user.id).map(&:target_user_id)
    # dynamo_db = AWS::DynamoDB.new
    # table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    # table = dynamo_db.tables[table_name]
    # if !table.schema_loaded?
    #   table.load_schema
    # end
    # timestamp = Time.now.to_i
    
    # items = table.items.where(:origin_id).equals(current_user.id.to_s).where(:notification_type).equals("2").where(:timestamp).gte(timestamp - 12*3600).select(:target_id)
    
    # return_array = Array.new
    # items.each do |p|
    #   attributes = p.attributes
    #   target_id = attributes['target_id'].to_i
    #   return_array << target_id
    # end
    
    return array.uniq
  end

  # Function signifies whether the user has sent a whisper to the target user
  def self.whisper_sent(origin_user_id, target_user_id, timestamp)
    dynamo_db = AWS::DynamoDB.new
    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    table = dynamo_db.tables[table_name]
    if !table.schema_loaded?
      table.load_schema
    end
    items = table.items.where(:target_id).equals(target_user_id.to_s).where(:origin_id).equals(origin_user_id.to_s).where(:notification_type).equals("2").where(:timestamp).gte(timestamp - 12*3600)
    puts "whisper sent"
    puts items.count.inspect
    # A whisper lasts 12 hours, so in one day, we can have at most 2 whispers.
    if items.nil? or items.count.nil?
      return true
    elsif items.count >= 2
      return false
    else
      return true
    end
      
    # if items.count == 1
    #   items.each do |i|
    #     hash = i.attributes.to_h
    #     limit_time = hash["timestamp"].to_i + (12 * 3600)
    #     if  Time.now.to_i > limit_time # If it has been 12hrs+ since you last whispered this person 
    #       return false # You can whisper again
    #     else
    #       return true # You can't whisper yet.
    #     end
    #   end
    # elsif items.count == 2 #Reached the max quota of whispers today
    #   return true
    # end
    
    # if items.present? and items.count > 0
    #   return true
    # else
    #   return false
    # end
  end

  def self.find_whisper(whisper_id, state)
    dynamo_db = AWS::DynamoDB.new
    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    table = dynamo_db.tables[table_name]
    if !table.schema_loaded?
      table.load_schema
    end
    item = table.items.where(:id).equals(whisper_id.to_s)
    if item.count == 1
      item.each do |i|
        if state == 'accepted'
          i.attributes.update do |u|
              hash = i.attributes.to_h
              # UserFriends.create_in_aws(hash["target_id"], hash["origin_id"])
              # UserFriends.create_in_aws(hash["origin_id"], hash["target_id"])
              u.set 'accepted' => 1
              u.set 'viewed' => 1
          end
          item_info = i.attributes.to_h
          return item_info
        elsif state == 'declined'
          puts "updating declined"
          i.attributes.update do |u|
              u.set 'declined' => 1
              u.set 'viewed' => 1
          end
          return true
        end
      end
    end
    return false
  end

  # decline whispers in array -> TODO: performance change one by one to batch
  def self.delete_whispers(whisper_array)
    dynamo_db = AWS::DynamoDB.new
    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    table = dynamo_db.tables[table_name]
    if !table.schema_loaded?
      table.load_schema
    end
    whisper_array.each do |id|
      item = WhisperNotification.find_by_dynamodb_id(id.to_s)
      item.attributes.update do |u|
          u.set 'declined' => 1
      end
    end
    return true
  end

  def self.accept_friend_viewed_by_sender(id)
    dynamo_db = AWS::DynamoDB.new
    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    table = dynamo_db.tables[table_name]
    if !table.schema_loaded?
      table.load_schema
    end
    items = table.items.where(:target_id).equals(id.to_s).where(:notification_type).equals("3").where(:viewed).equals(0)
    if items.count > 0
      items.each do |i|
        i.attributes.update do |u|
            u.set 'viewed' => 1
        end
        item_info = i.attributes.to_h
      end
    end
    return true
  end


  def send_push_notification_to_target_user(message)
    data = { :alert => message, :type => self.notification_type.to_i, :badge => "Increment"}
    push = Parse::Push.new(data, "User_" + self.target_id.to_s)
    push.type = "ios"
    begin  
      push.save
      result = true  
    rescue  
      p "Push notification error"
      result = false 
    end 
    return result 


    # #this shall be refactored once we have more phones to test with
    # app_local_path = Rails.root

    # # if self.origin_id != "0"
    # #   origin_user = User.find(self.origin_id) 
    # #   origin_user_key = origin_user.key
    # # else
    # #   origin_user_key = "SYSTEM"
    # # end
    # target_user = User.find(self.target_id) 
    # p "Target user: "
    # p target_user.inspect
    # if !ENV['DYNAMODB_PREFIX'].blank?
    #   apn = Houston::Client.development
    #   apn.certificate = File.read("#{app_local_path}/apple_push_notification_sandbox.pem")
    # else
    #   apn = Houston::Client.production
    #   apn.certificate = File.read("#{app_local_path}/apple_push_notification.pem")
    # end

    # # An example of the token sent back when a device registers for notifications
    # token = User.find(self.target_id).apn_token # "<443e69367fbbbce9c722fdf392f72af2111bde5626a916007d97382687d4b029>"
    # p 'the token'
    # p token.inspect
    # # Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
    # notification = Houston::Notification.new(device: token)
    # # p "notification before message"
    # # p notification.inspect
    # notification.alert = message # "Hi #{target_user.first_name || "Whisper User"}, You got a Whisper!"
    

    # notification.badge = 1
    # notification.sound = "sosumi.aiff"
    # notification.category = "INVITE_CATEGORY"
    # notification.content_available = true

    # notification.custom_data = {
    #   type: self.notification_type.to_i,
    #   friend_or_whisper: (self.notification_type.to_i == 3 ? "friend" : "whisper")
    # }

    # # And... sent! That's all it takes.

    # if !token.nil? and !token.empty?
    #   begin  
    #     p "Notification object"
    #     p notification.inspect
    #     apn.push(notification)
    #     return true  
    #   rescue  
    #     p "Notification object error"
    #     p notification.inspect
    #     return false 
    #   end  
    # else
    #   return false
    # end
  end


  # send network open notification
  def self.send_nightopen_notification(id)
    data = { :alert => "Your city's network is now online.", :type => 100}
    push = Parse::Push.new(data, "User_" + id.to_s)
    push.type = "ios"
    begin  
      push.save
      result = true  
    rescue  
      p "Push notification error"
      result = false 
    end 
    return result 

    # app_local_path = Rails.root
    # if !ENV['DYNAMODB_PREFIX'].blank?
    #   apn = Houston::Client.development
    #   apn.certificate = File.read("#{app_local_path}/apple_push_notification_sandbox.pem")
    # else
    #   apn = Houston::Client.production
    #   apn.certificate = File.read("#{app_local_path}/apple_push_notification.pem")
    # end

    # # An example of the token sent back when a device registers for notifications
    # token = User.find(id).apn_token # "<443e69367fbbbce9c722fdf392f72af2111bde5626a916007d97382687d4b029>"
   
    # # Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
    # notification = Houston::Notification.new(device: token)
    # notification.alert = "Your city's network is now online."
    
    # # Notifications can also change the badge count, have a custom sound, have a category identifier, indicate available Newsstand content, or pass along arbitrary data.
    # notification.sound = "sosumi.aiff"
    # notification.category = "INVITE_CATEGORY"
    # notification.content_available = true
    # notification.custom_data = {         
    #       type: 100
    # }

    # # And... sent! That's all it takes.
    # if !token.nil? and !token.empty?
    #   puts token
    #   apn.push(notification)
    # end
  end

  # send enough users notification
  def self.send_enough_users_notification(id)

    data = { :alert => "There are now enough users. See who else is online.", :type => 102}
    push = Parse::Push.new(data, "User_" + id.to_s)
    push.type = "ios"
    begin  
      push.save
      result = true  
    rescue  
      p "Push notification error"
      result = false 
    end 
    return result 

    # app_local_path = Rails.root
    # if !ENV['DYNAMODB_PREFIX'].blank?
    #   apn = Houston::Client.development
    #   apn.certificate = File.read("#{app_local_path}/apple_push_notification_sandbox.pem")
    # else
    #   apn = Houston::Client.production
    #   apn.certificate = File.read("#{app_local_path}/apple_push_notification.pem")
    # end

    # # An example of the token sent back when a device registers for notifications
    # token = User.find(id).apn_token # "<443e69367fbbbce9c722fdf392f72af2111bde5626a916007d97382687d4b029>"
   
    # # Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
    # notification = Houston::Notification.new(device: token)
    # notification.alert = "There are now enough users. See who else is online."
    
    # # Notifications can also change the badge count, have a custom sound, have a category identifier, indicate available Newsstand content, or pass along arbitrary data.
    # notification.sound = "sosumi.aiff"
    # notification.category = "INVITE_CATEGORY"
    # notification.content_available = true
    # notification.custom_data = {         
    #       type: 102
    # }

    # # And... sent! That's all it takes.
    # if !token.nil? and !token.empty?
    #   puts token
    #   apn.push(notification)
    # end
  end

  # Send notification when the avatar is disabled by admin
  def self.send_avatar_disabled_notification(id, default)


    data = { :alert => "Your main avatar looks not so good... Please use another one as your main avatar.", :type => 101, :is_default => default}
    push = Parse::Push.new(data, "User_" + id.to_s)
    push.type = "ios"
    begin  
      push.save
      result = true  
    rescue  
      p "Push notification error"
      result = false 
    end 
    return result 


    # app_local_path = Rails.root
    # if !ENV['DYNAMODB_PREFIX'].blank?
    #   apn = Houston::Client.development
    #   apn.certificate = File.read("#{app_local_path}/apple_push_notification_sandbox.pem")
    # else
    #   apn = Houston::Client.production
    #   apn.certificate = File.read("#{app_local_path}/apple_push_notification.pem")
    # end

    # # An example of the token sent back when a device registers for notifications
    # token = User.find(id).apn_token # "<443e69367fbbbce9c722fdf392f72af2111bde5626a916007d97382687d4b029>"
   
    # # Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
    # notification = Houston::Notification.new(device: token)
    # notification.alert = "Your main avatar looks not so good... Please use another one as your main avatar."
    
    # # Notifications can also change the badge count, have a custom sound, have a category identifier, indicate available Newsstand content, or pass along arbitrary data.
    # notification.sound = "sosumi.aiff"
    # notification.category = "INVITE_CATEGORY"
    # notification.content_available = true
    # notification.custom_data = {   
    #       type: 101,      
    #       is_default: default
    # }

    # # And... sent! That's all it takes.
    # if !token.nil? and !token.empty?
    #   apn.push(notification)
    # end
  end


  def self.unviewd_whisper_number(user_id)
    dynamo_db = AWS::DynamoDB.new
    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    table = dynamo_db.tables[table_name]
    if !table.schema_loaded?
      table.load_schema
    end

    chat_items = table.items.where(:target_id).equals(user_id.to_s).where(:notification_type).equals("2").where(:viewed).equals(0)
    greeting_items = table.items.where(:target_id).equals(user_id.to_s).where(:notification_type).equals("1").where(:viewed).equals(0)
    accept_items = table.items.where(:target_id).equals(user_id.to_s).where(:notification_type).equals("2").where(:accepted).equals(1).where(:viewed).equals(0)

    chat_request_number = 0
    venue_greeting_number = 0
    accept_number = 0
    if chat_items.present?
      chat_request_number = chat_items.count
    end
    if greeting_items.present?
      venue_greeting_number = greeting_items.count
    end
    if accept_items.present?
      accept_number = accept_items.count
    end

    badge = {
      whisper_number: chat_request_number + venue_greeting_number,
      friend_number: accept_number
    }

    return badge
  end
end