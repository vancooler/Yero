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
      n.expired = 0
    end
    n.save!

    p "n:"
    p n.inspect

    return n
  end


  # expire at 5 am
  # def self.expire(people_array, notification_type)
  #   dynamo_db = AWS::DynamoDB.new
  #   table_name = WhisperNotification.table_prefix + 'WhisperNotification'
  #   table = dynamo_db.tables[table_name]
  #   if !table.schema_loaded?
  #     table.load_schema
  #   end
  #   puts "Read time: "
  #   people_array_string = Array.new
  #   people_array.each do |p|
  #     people_array_string << p.to_s
  #   end
  #   items = table.items.where(:target_id).in(*people_array_string).where(:notification_type).equals(notification_type).where(:expired).equals(0).select(:target_id, :origin_id, :declined, :intro, :venue_id, :notification_type, :viewed, :id, :created_date, :timestamp, :not_viewed_by_sender, :accepted)
    
  #   items.each_slice(25) do |whisper_group|
  #     batch = AWS::DynamoDB::BatchWrite.new
  #     notification_array = Array.new
  #     whisper_group.each do |w|
  #       if !w.blank?
  #         attributes = w.attributes
  #         request = Hash.new()
  #         request["target_id"] = attributes['target_id']
  #         request["timestamp"] = attributes['timestamp']
  #         request["id"] = attributes['id'] if !attributes['id'].nil?
  #         request["origin_id"] = attributes['origin_id'] if !attributes['origin_id'].nil?
  #         request["accepted"] = attributes['accepted'] if !attributes['accepted'].nil?
  #         request["declined"] = attributes['declined'] if !attributes['declined'].nil?
  #         request["created_date"] = attributes['created_date'] if !attributes['created_date'].nil?
  #         request["venue_id"] = attributes['venue_id'] if !attributes['venue_id'].nil?
  #         request["notification_type"] = attributes['notification_type'] if !attributes['notification_type'].nil?
  #         request["intro"] = attributes['intro'] if !attributes['intro'].nil?
  #         request["viewed"] = attributes['viewed'] if !attributes['viewed'].nil?
  #         request["not_viewed_by_sender"] = attributes['not_viewed_by_sender'] if !attributes['not_viewed_by_sender'].nil?
  #         request["expired"] = 1
  #         notification_array << request 
  #       end
  #     end
  #     if notification_array.count > 0
  #       batch.put(table_name, notification_array)
  #       batch.process!
  #     end
  #   end

  # end

  # def self.read_notification(id, user)
  #   item = WhisperNotification.find_by_dynamodb_id(id)
  #   if item.nil?
  #     return false
  #   else
  #     attributes = item.attributes.to_h
  #     notification_type = attributes['notification_type'].to_s
  #     if notification_type != "0"
  #       item.attributes.update do |u|
  #         u.set 'viewed' => 1
  #       end
  #       return true
  #     else
  #       return true
  #     end
  #   end
  # end

  # def self.venue_info(id)
  #   item = WhisperNotification.find_by_dynamodb_id(id)
  #   if item.nil?
  #     return nil
  #   else
  #     attributes = item.attributes.to_h
  #     venue_id = attributes['venue_id'].to_i
  #     if !venue_id.nil? and venue_id > 0
  #       return Venue.find(venue_id)
  #     else
  #       return nil
  #     end
  #   end
  # end

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


  # def self.system_notification(user_id)
  #   dynamo_db = AWS::DynamoDB.new # Make an AWS DynamoDB object
  #   table_name = WhisperNotification.table_prefix + 'WhisperNotification'
  #   table = dynamo_db.tables[table_name] # Choose the table
  #   if !table.schema_loaded?
  #     table.load_schema 
  #   end
  #   # Retrieve the system notifications that were sent by the venue, with notification_type = 1
  #   # Expire rule change!!!
  #   venue_items = table.items.where(:target_id).equals(user_id.to_s).where(:expired).equals(0).where(:notification_type).equals("1").select(:venue_id, :viewed, :id, :created_date, :timestamp, :not_viewed_by_sender, :accepted)
  #   venue = Array.new # Make a new hash object
  #   exist_venue_id = Array.new
  #   venue_items.each do |i| # For each item
      
  #     attributes = i.attributes
  #     venue_id = attributes['venue_id'].to_i # Turn venue id into a integer
  #     h = Hash.new # Make a new hash object
  #     # v = Venue.find(venue_id)
  #     if Venue.exists? id: venue_id
  #       if exist_venue_id.include? venue_id #venue id already in there, then do nothing
  #       else
  #         h['venue_id'] = attributes['venue_id']
  #         h['timestamp'] = attributes['timestamp'].to_i
  #         h['accepted'] = attributes['accepted']
  #         h['viewed'] = attributes['viewed']
  #         h['not_viewed_by_sender'] = attributes['not_viewed_by_sender']
  #         h['created_date'] = attributes['created_date']
  #         h['whisper_id'] = attributes['id']
  #         venue << h # Throw venue_id into the array
  #         exist_venue_id << venue_id
  #       end
  #     end
  #   end
  #   return venue
  # end

  # Retrive whispers
  # def self.find_friends(user_id)
  #   time_0 = Time.now

  #   dynamo_db = AWS::DynamoDB.new # Make an AWS DynamoDB object
  #   table_name = WhisperNotification.table_prefix + 'WhisperNotification'
  #   table = dynamo_db.tables[table_name] # Choose the table
  #   if !table.schema_loaded?
  #     table.load_schema 
  #   end
  #   # Target_id is the receiver of the messages
  #   # Expire rule change!!!
  #   receiver_items = table.items.where(:target_id).equals(user_id.to_s).where(:expired).equals(0).where(:notification_type).equals("2").where(:accepted).equals(0).where(:declined).not_equal_to(1).select(:origin_id, :viewed, :id, :created_date, :timestamp, :not_viewed_by_sender, :accepted, :declined, :intro)
  #   time_1 = Time.now
  #   runtime = time_1 - time_0
  #   puts "Read user time"
  #   puts runtime.inspect
  #   receiver_items_array = Array.new
  #   if receiver_items and receiver_items.count > 0
  #     receiver_items.each do |i|
  #       attributes = i.attributes
  #       sender_id = attributes['origin_id'].to_i
  #       h = Hash.new
  #       if User.exists? id: sender_id
  #         user = User.find(sender_id)
  #         h['target_user'] = user
  #       else
  #         h['target_user'] = ''
  #       end
  #       h['timestamp'] = attributes['timestamp'].to_i

  #       # expire rule change!!
  #       # h['seconds_left'] = attributes['timestamp'].to_i + 4*3600 - Time.now.to_i + 60
  #       # expire_timestamp = UserLocation.tomorrow_close_timestamp(user_id.to_i, attributes['timestamp'])
  #       current_user = User.find_by_id(user_id)
  #       if current_user
  #         hour = DateTime.strptime(attributes['timestamp'].to_s, "%s").in_time_zone(current_user.timezone_name).hour
  #         if hour >= 5
  #           expire_timestamp = DateTime.strptime(attributes['timestamp'].to_s,'%s').in_time_zone(current_user.timezone_name).tomorrow.beginning_of_day + 5.hours
  #         else
  #           expire_timestamp = DateTime.strptime(attributes['timestamp'].to_s,'%s').in_time_zone(current_user.timezone_name).beginning_of_day + 5.hours            
  #         end
  #         h['seconds_left'] = expire_timestamp.to_i - Time.now.to_i + 60
  #         h['expire_timestamp'] = expire_timestamp.to_i
  #       else
  #         h['seconds_left'] = 3600*12
  #         h['expire_timestamp'] = Time.now.to_i + 3600*12
  #       end
  #       h['accepted'] = attributes['accepted'].to_i
  #       h['declined'] = attributes['declined'].to_i
  #       h['viewed'] = attributes['viewed'].to_i
  #       h['whisper_id'] = attributes['id']
  #       h['not_viewed_by_sender'] = attributes['not_viewed_by_sender'].to_i
  #       h['intro'] = attributes['intro']
  #       receiver_items_array << h
  #     end
  #   end
  #   users = Array.new
  #   users = receiver_items_array
  #   users = users.sort_by { |hsh| hsh[:timestamp] }
    
  #   time_2 = Time.now
  #   runtime = time_2 - time_1
  #   puts "Adjust user time"
  #   puts runtime.inspect
  #   return users.reverse
  # end

  # TODO: use it for friends request
  def self.myfriends(user_id)

    current_user = User.find(user_id)
    friends = Array.new
    # Friends by whisper
    friends_by_whisper = FriendByWhisper.friends(user_id)
    blocked_users = BlockUser.blocked_users(user_id)
    friends_by_whisper = friends_by_whisper - blocked_users
    friends_by_whisper.each do |user|
      if user and !user.user_avatars.where(is_active: true).blank?
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

    end
    # Friends by like
    mutual_follow = current_user.friends_by_like
    mutual_follow_array = Array.new
    mutual_follow.each do |user|
      if user and !user.user_avatars.where(is_active: true).blank?
        h = Hash.new
        friend_id = user.id
        h['intro'] = user.introduction_1
        h['target_user_id'] = user.id
        h['target_user'] = user
        timestamp_1 = Follow.where(:follower_type => "User", :follower_id => user.id, :followable_type => "User", :followable_id => current_user.id).first.created_at.to_i
        timestamp_2 = Follow.where(:follower_type => "User", :follower_id => current_user.id, :followable_type => "User", :followable_id => user.id).first.created_at.to_i
        h['timestamp'] = (timestamp_1 > timestamp_2) ? timestamp_1 : timestamp_2
        h['timestamp_read'] = Time.at(h['timestamp']) # TODO: change format
        mutual_follow_array << h  
      end
    end
    
    users = Array.new
    users = friends | mutual_follow_array
    users = users.group_by { |x| x['target_user_id'] }.map {|x,y|y.max_by {|x|x['timestamp']}}

    users = users.sort_by { |hsh| hsh['timestamp'] }

    return users.reverse

  end

  # def self.friends_activity_to_json(friends, current_user)
  #   origin_user_array = Array.new
  #   if friends and friends.count > 0
  #     friends.each do |i|
  #       h = Hash.new
  #       h['activity_type'] = 'Became Friends'
  #       h['object_type'] = 'user'
  #       target_user = User.find_by_id(i["target_user"]["id"].to_i)
  #       if !target_user.nil?
  #         user_object = target_user.user_object(current_user)
  #       end

  #       h['object'] = user_object
  #       h['activity_id'] = (i['id'].blank? ? 'friends-'+current_user.id.to_s+'-'+target_user.id.to_s+'-'+i['timestamp'].to_i.to_s : i['id'])
  #       # h['my_role'] = 'target_user'
  #       h['timestamp'] = i['timestamp']
  #       # a = [h, Time.at(attributes['timestamp'].to_i).utc]
  #       origin_user_array << h
  #     end
  #   end
  #   return origin_user_array
  # end
  

  # def self.chat_action(id, handle_action)
  #   item = WhisperNotification.find_by_dynamodb_id(id)
  #   if item.nil?
  #     return false
  #   else
  #     attributes = item.attributes.to_h
  #     notification_type = attributes['notification_type'].to_s
  #     target_id = attributes['target_id'].to_s
  #     if notification_type == "2" 
  #       Rails.logger.info "ACTION: " + handle_action
  #       item.attributes.update do |u|
  #         if handle_action == 'accept'
  #           Rails.logger.info "ACCEPT!!"
  #           u.set 'accepted' => 1
  #         elsif handle_action == 'decline'
  #           u.set 'accepted' => 2
  #         end
            
  #       end
  #       return true
  #     else
  #       return false
  #     end
  #   end
  # end

  # NOT used
  # def self.my_chatting_requests(target_id)
  #   dynamo_db = AWS::DynamoDB.new
  #   table_name = WhisperNotification.table_prefix + 'WhisperNotification'
  #   table = dynamo_db.tables[table_name]
  #   if !table.schema_loaded?
  #     table.load_schema
  #   end
  #   items = table.items.where(:target_id).equals(target_id.to_s).where(:notification_type).equals("2").where(:accepted).equals(0)
  #   if items and items.count > 0
  #     request_user_array = Array.new
  #     items.each do |i|
  #       attributes = i.attributes.to_h
  #       origin_id = attributes['origin_id'].to_i
  #       h = Hash.new
  #       if origin_id > 0
  #         user = User.find(origin_id)
  #         h['origin_user'] = user
  #         avatar_array = Array.new
  #         avatar_array[0] = {
  #           thumbnail: user.main_avatar.avatar.thumb.url
  #         }
  #         avatar_array[1] = {
  #           avatar: user.main_avatar.nil? ? '' : user.main_avatar.avatar.url,
  #           avatar_id: user.main_avatar.nil? ? '' : user.main_avatar.id,
  #           default: true
  #         }
          
  #         h['avatars'] = avatar_array
  #       else
  #         h['origin_user'] = ''
  #       end
  #       h['since_1970'] = attributes['timestamp'].to_i
  #       h['whisper_id'] = attributes['id']
  #       request_user_array << h
  #     end
  #     request_user_array = request_user_array.sort_by { |hsh| hsh[:since_1970] }
  #     return request_user_array.reverse
  #   else
  #     return nil
  #   end
  # end

  def self.my_chat_request_history(user, page_number, activities_per_page)
    # t0 = Time.now
    # dynamo_db = AWS::DynamoDB.new
    # table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    # table = dynamo_db.tables[table_name]
    # if !table.schema_loaded?
    #   table.load_schema
    # end
    # current_user = user
    # activity_notification_types = ["200", "201"]
    # target_items = table.items.where(:target_id).equals(user.id.to_s).where(:notification_type).equals("2").select(:origin_id, :id, :timestamp)
    # origin_items = table.items.where(:origin_id).equals(user.id.to_s).where(:notification_type).equals("2").select(:target_id, :id, :timestamp)
    # activity_items = table.items.where(:target_id).equals(user.id.to_s).where(:notification_type).in(*activity_notification_types).select(:id, :timestamp, :notification_type)
    # friends = WhisperNotification.myfriends(user.id)
    # is_friends = true
    # friends = WhisperNotification.friends_activity_to_json(friends, user)
    # disabled_avatars = table.items.where(:target_id).equals(user.id.to_s).where(:notification_type).equals("101").select(:id, :timestamp)
    # origin_user_array = Array.new
    # t1 = Time.now
    # t = 0
    # tb = Time.now
    # if target_items
    #   target_items.each do |i|
    #     attributes = i.attributes
    #     origin_id = attributes['origin_id'].to_i
    #     h = Hash.new
    #     h['activity_type'] = 'Received Whisper'
    #     h['object_type'] = 'user'
    #     if origin_id > 0
    #       if User.exists? id: origin_id
    #         user = User.find(origin_id)
    #         h['object'] = user.user_object(current_user)
    #       else
    #         h['object'] = ''
    #       end
    #     else
    #       h['object'] = ''
    #     end
    #     h['activity_id'] = attributes['id']
    #     # h['my_role'] = 'target_user'
    #     h['timestamp'] = attributes['timestamp'].to_i
    #     # a = [h, Time.at(attributes['timestamp'].to_i).utc]
    #     if user and !user.user_avatars.where(is_active: true).blank?
    #       origin_user_array << h
    #     end
    #   end
    # end
    # ta = Time.now
    # puts "Part time"
    # puts (ta-tb).inspect
    # if origin_items
    #   origin_items.each do |i|
    #     tb = Time.now
    #     attributes = i.attributes
    #     target_id = attributes['target_id'].to_i
    #     h = Hash.new
    #     h['activity_type'] = 'Sent Whisper'
    #     h['object_type'] = 'user'
    #     if target_id > 0
    #       if User.exists? id: target_id
    #         user = User.find(target_id)
    #         h['object'] = user.user_object(current_user)
    #       else
    #         h['object'] = ''
    #       end
    #     else
    #       h['object'] = ''
    #     end
    #     h['activity_id'] = attributes['id']
    #     # h['my_role'] = 'origin_user'
    #     h['timestamp'] = attributes['timestamp'].to_i
    #     # a = [h, Time.at(attributes['timestamp'].to_i).utc]
    #     if user and !user.user_avatars.where(is_active: true).blank?
    #       origin_user_array << h
    #     end
    #     ta = Time.now
    #     t += (ta-tb)
    #   end 
    # end
    # if activity_items
    #   activity_items.each do |i|
    #     tb = Time.now
    #     attributes = i.attributes
    #     target_id = attributes['target_id'].to_i
    #     h = Hash.new
    #     h['activity_type'] = ((attributes['notification_type'].to_i == 200) ? 'Joined Network' : 'Offline')
    #     h['activity_id'] = attributes['id']
    #     # h['my_role'] = 'target_user'
    #     h['timestamp'] = attributes['timestamp'].to_i
    #     # a = [h, Time.at(attributes['timestamp'].to_i).utc]
    #     origin_user_array << h
    #     ta = Time.now
    #     t += (ta-tb)
    #   end
    # end
    # if disabled_avatars
    #   disabled_avatars.each do |i|
    #     tb = Time.now
    #     attributes = i.attributes
    #     target_id = attributes['target_id'].to_i
    #     h = Hash.new
    #     h['activity_type'] = 'Profile Avatar Disabled'
    #     h['activity_id'] = attributes['id']
    #     # h['my_role'] = 'target_user'
    #     h['timestamp'] = attributes['timestamp'].to_i
    #     # a = [h, Time.at(attributes['timestamp'].to_i).utc]
    #     origin_user_array << h
    #     ta = Time.now
    #     t += (ta-tb)
    #   end
    # end
    # t2 = Time.now
    # if !friends.empty?
    #   origin_user_array = origin_user_array + friends
    # end


    # use local table to get activity history
    users = RecentActivity.all_activities(user.id)

    if !page_number.nil? and !activities_per_page.nil? and activities_per_page > 0 and page_number >= 0
      users = Kaminari.paginate_array(users).page(page_number).per(activities_per_page) if !users.nil?
    end

    users = RecentActivity.to_json(users)
    # t3 = Time.now
    # puts "gether time: "
    # puts (t1-t0).inspect
    # puts "json time: "
    # puts (t2-t1).inspect
    # puts "reorder & page time: "
    # puts (t3-t2).inspect
    # puts "Activity time: "
    # puts (t3-t0).inspect
    # puts "Special time: "
    # puts (t).inspect

    return users
  end

  # def self.get_info(user)
  #   dynamo_db = AWS::DynamoDB.new
  #   table_name = WhisperNotification.table_prefix + 'WhisperNotification'
  #   table = dynamo_db.tables[table_name]
  #   if !table.schema_loaded?
  #     table.load_schema
  #   end
  #   items = table.items.where(:target_id).equals(user.id.to_s).where(:notification_type).equals('1')
  #   if items and items.count > 0
  #     # * venue name
  #     # * message and date  <— hardcode
  #     # * timestamp
  #     # * whisper_id
  #     # * viewed
  #     request_array = Array.new
  #     items.each do |i|
  #       n = Hash.new
  #       attributes = i.attributes.to_h
  #       venue_id = attributes['venue_id'].to_i
  #       if venue_id > 0
  #         venue = Venue.find(venue_id)
  #         if venue.nil?
  #           n['venue_name'] = ''
  #         else
  #           n['venue_name'] = venue.name
  #         end
  #       else
  #         n['venue_name'] = ''
  #       end
  #       n['message'] = 'HARD CODE MESSAGE'
  #       n['date'] = 'HARD CODE DATE'
  #       n['timestamp'] = attributes['timestamp'].to_i
  #       n['whisper_id'] = attributes['id']
  #       n['viewed'] = attributes['viewed'].to_i
  #       n['notification_type'] = attributes['notification_type'].to_i
  #       request_array << n
  #     end
  #     request_array = request_array.sort_by { |hsh| hsh[:timestamp] }
  #     return request_array.reverse
  #   else
  #     return nil
  #   end
  # end

  # def self.delete_notification(id, user)
  #   item = WhisperNotification.find_by_dynamodb_id(id)
  #   if item.nil?
  #     return false
  #   else
  #     # attributes = item.attributes.to_h
  #     # notification_type = attributes['notification_type'].to_s
  #     # viewed = attributes['viewed']
  #     # if notification_type != "0" and viewed == 0
  #     #   if user.notification_read.nil? or user.notification_read <= 0
  #     #     user.notification_read = 0
  #     #   else
  #     #     user.notification_read = user.notification_read - 1
  #     #   end        
  #     #   user.save
  #     # end
  #     item.delete
  #     return true
  #   end
    
  # end

  # def self.decline_all_chat(user, ids_array)
  #   dynamo_db = AWS::DynamoDB.new
  #   table_name = WhisperNotification.table_prefix + 'WhisperNotification'
  #   table = dynamo_db.tables[table_name]
  #   if !table.schema_loaded?
  #     table.load_schema
  #   end
  #   items = table.items.where(:target_id).equals(user.id.to_s).where(:notification_type).equals("2").where(:accepted).equals(0)
  #   items.each do |item|
  #     attributes = item.attributes.to_h
  #     accepted = attributes['accepted']
  #     id = attributes['id']
  #     # check whether is in the array params
  #     if ids_array.include?(id) 
  #       item.attributes.update do |u|
  #         u.set 'accepted' => 2 
  #         u.set 'declined' => 1         
  #       end
  #     end
  #   end
    
  #   return true
  # end

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
  # def self.whisper_sent(origin_user_id, target_user_id, timestamp)
  #   dynamo_db = AWS::DynamoDB.new
  #   table_name = WhisperNotification.table_prefix + 'WhisperNotification'
  #   table = dynamo_db.tables[table_name]
  #   if !table.schema_loaded?
  #     table.load_schema
  #   end
  #   items = table.items.where(:target_id).equals(target_user_id.to_s).where(:origin_id).equals(origin_user_id.to_s).where(:notification_type).equals("2").where(:timestamp).gte(timestamp - 12*3600)
  #   puts "whisper sent"
  #   puts items.count.inspect
  #   # A whisper lasts 12 hours, so in one day, we can have at most 2 whispers.
  #   if items.nil? or items.count.nil?
  #     return true
  #   elsif items.count >= 2
  #     return false
  #   else
  #     return true
  #   end
      
  #   # if items.count == 1
  #   #   items.each do |i|
  #   #     hash = i.attributes.to_h
  #   #     limit_time = hash["timestamp"].to_i + (12 * 3600)
  #   #     if  Time.now.to_i > limit_time # If it has been 12hrs+ since you last whispered this person 
  #   #       return false # You can whisper again
  #   #     else
  #   #       return true # You can't whisper yet.
  #   #     end
  #   #   end
  #   # elsif items.count == 2 #Reached the max quota of whispers today
  #   #   return true
  #   # end
    
  #   # if items.present? and items.count > 0
  #   #   return true
  #   # else
  #   #   return false
  #   # end
  # end

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
              u.set 'accepted' => 1
              u.set 'viewed' => 1
          end
          item_info = i.attributes.to_h
        elsif state == 'declined'
          puts "updating declined"
          i.attributes.update do |u|
              u.set 'declined' => 1
              u.set 'viewed' => 1
          end
        end
      end
    end
    whisper = WhisperToday.find_by_dynamo_id(whisper_id)
    if !whisper.nil?
      whisper.viewed = true
      whisper.declined = (state == 'declined')
      whisper.accepted = (state == 'accepted')
      whisper.save
    end
    return true
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


  def self.send_whisper(target_id, current_user, venue_id, notification_type, intro, message)
    origin_id = current_user.id.to_s
    # only users with active avatar can send whispers
    if current_user.user_avatars.where(:is_active => true).count <= 0 
      return "No photos"
    elsif BlockUser.check_block(origin_id.to_i, target_id.to_i)
      return "User blocked"
    else
      whispers_sent_today = WhisperToday.where(target_user_id: target_id.to_i, origin_user_id: origin_id.to_i)
      # check if whisper sent today
      if whispers_sent_today.count <= 0
        if Rails.env == 'production'
          n = WhisperNotification.create_in_aws(target_id, origin_id, venue_id, notification_type, intro)
        end
        WhisperToday.create!(:dynamo_id => n.id, :target_user_id => target_id.to_i, :origin_user_id => origin_id.to_i, :whisper_type => notification_type, :message => intro, :venue_id => venue_id.to_i)
        if n and notification_type == "2"
          time = Time.now
          RecentActivity.add_activity(origin_id.to_i, '2-sent', target_id.to_i, nil, "whisper-sent-"+target_id.to_s+"-"+origin_id.to_s+"-"+time.to_i.to_s)
          RecentActivity.add_activity(target_id.to_i, '2-received', origin_id.to_i, nil, "whisper-received-"+origin_id.to_s+"-"+target_id.to_s+"-"+time.to_i.to_s)

          record_found = WhisperSent.where(:origin_user_id => origin_id.to_i).where(:target_user_id => target_id.to_i)
          if record_found.count <= 0
            WhisperSent.create_new_record(origin_id.to_i, target_id.to_i)
          else
            record_found.first.update(:whisper_time => time)
          end
        end
        if Rails.env == 'production'
          n.send_push_notification_to_target_user(message)
        end

        return "true"
      else
        return "Cannot send more today"
      end
      
    end
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

    
  end

  # send enough users notification
  def self.send_enough_users_notification(id)

    data = { :alert => "Enough users have joined your city’s network.", :type => 102}
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

    
  end

  # Send notification when the avatar is disabled by admin
  def self.send_avatar_disabled_notification(id, default)


    data = { :alert => "One of your photos has been flagged as inappropriate and removed", :type => 101, :is_default => default}
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
  end


  def self.unviewd_whisper_number(user_id)
    black_list = BlockUser.blocked_user_ids(user_id.to_i)
    whisper_items = WhisperToday.where(target_user_id: user_id.to_i).where(viewed: false).where.not(origin_user_id: black_list)
    accept_items = FriendByWhisper.where(viewed: false).where(origin_user_id: user_id.to_i).where.not(target_user_id: black_list)
    whisper_number = 0
    accept_number = 0
    
    if whisper_items.present?
      whisper_number = whisper_items.count
    end
    if accept_items.present?
      accept_number = accept_items.count
    end

    badge = {
      whisper_number: whisper_number + accept_number,
      friend_number: accept_number
    }

    puts "BADGEEEEEE"
    puts badge.inspect
    return badge
  end
end