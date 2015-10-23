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
              # 300 level means related to shout
              # '301' => someone replied to your shout
              # '302' => someone replied to the same shout
              # '303' => your shout was removed by admin
              # '304' => your shout comment was removed by admin
              # '310' => you received 10 votes on your shout
              # '311' => you received 25 votes on your shout
              # '312' => you received 50 votes on your shout
              # '313' => you received 100 votes on your shout
              # '314' => you received 250 votes on your shout
              # '315' => you received 500 votes on your shout
              # '316' => you received 1000 votes on your shout
              # '317' => you received 2500 votes on your shout
              # '318' => you received 5000 votes on your shout
              # '330' => you received 10 votes on your shout comment
              # '331' => you received 25 votes on your shout comment
              # '332' => you received 50 votes on your shout comment
              # '333' => you received 100 votes on your shout comment
              # '334' => you received 250 votes on your shout comment
              # '335' => you received 500 votes on your shout comment
              # '336' => you received 1000 votes on your shout comment
              # '337' => you received 2500 votes on your shout comment
              # '338' => you received 5000 votes on your shout comment
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

  # :nocov:
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
  # :nocov:



  # :nocov:
  # Find a record in dynamoDB with dynamodb's uuid
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
  # :nocov:


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
  #       current_user = User.find_user_by_unique(user_id)
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
  #         h['seconds_left'] = 3600*24
  #         h['expire_timestamp'] = Time.now.to_i + 3600*24
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
        h['viewed'] = FriendByWhisper.find_friendship(user.id, user_id).nil? ? true : FriendByWhisper.find_friendship(user.id, user_id).viewed
        h['timestamp'] = timestamp
        h['timestamp_read'] = Time.at(timestamp) # TODO: change format
        friends << h  
      end

    end
    # Friends by like
    mutual_follow = current_user.friends_by_like
    mutual_follow_array = Array.new
    # :nocov:
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
    # :nocov:
    
    users = Array.new
    users = friends | mutual_follow_array
    users = users.group_by { |x| x['target_user_id'] }.map {|x,y|y.max_by {|x|x['timestamp']}}

    users = users.sort_by { |hsh| hsh['timestamp'] }

    return users.reverse

  end


  # Activity history
  def self.my_chat_request_history(user, page_number, activities_per_page)
    
    # use local table to get activity history
    users = RecentActivity.all_activities(user.id)

    if !page_number.nil? and !activities_per_page.nil? and activities_per_page > 0 and page_number >= 0
      users = Kaminari.paginate_array(users).page(page_number).per(activities_per_page) if !users.nil?
    end

    users = RecentActivity.to_json(users)
    
    return users
  end

  

  # Function that gets all the users received whisper from current user
  def self.collect_whispers(current_user)
    # array = WhisperToday.where.not(paper_owner_id: current_user.id).where(origin_user_id: current_user.id).map(&:target_user_id)
    array = WhisperSent.where(['whisper_time > ?', Time.now-12.hours]).where(:origin_user_id => current_user.id).map(&:target_user_id)

    return array.uniq
  end

  def self.collect_whispers_can_reply(current_user)
    array_a = WhisperToday.where(paper_owner_id: current_user.id).where(origin_user_id: current_user.id).where(accepted: false).where(declined: false).map(&:target_user_id)
    array_b = WhisperToday.where(paper_owner_id: current_user.id).where(target_user_id: current_user.id).where(accepted: false).where(declined: false).map(&:origin_user_id)
    
    return (array_a | array_b)
  end

  def self.collect_conversations_can_reply(current_user)
    conversation_ids = WhisperToday.where("whisper_todays.origin_user_id = ?", current_user.id).joins(:whisper_replies).group("whisper_todays.id").having("count(whisper_replies.id) > ?",1).map(&:id)
    conversations_1 = WhisperToday.where(id: conversation_ids).map(&:target_user_id)
    conversations_2 = WhisperToday.where("target_user_id = ?", current_user.id).map(&:origin_user_id)
    return (conversations_1 | conversations_2)
  end

  def self.collect_whispers_can_accept_delete(current_user)
    array = WhisperToday.where(target_user_id: current_user.id).where(accepted: false).where(declined: false).map(&:origin_user_id)
    
    return array.uniq
  end


  # Handle a whisper accept/decline
  def self.find_whisper(whisper_id, state)
    if Rails.env == 'production'
      # :nocov:
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
      # :nocov:
    end
    whisper = WhisperToday.find_by_dynamo_id(whisper_id)
    puts "WHISPER:"
    puts whisper.inspect
    if !whisper.nil?
      whisper.viewed = true
      whisper.declined = (state == 'declined')
      whisper.accepted = (state == 'accepted')
      whisper.save
    end
    return true
  end

  # :nocov:
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

      item = WhisperToday.find_by_dynamo_id(id)
      WhisperReply.delay.archive_history(item)
    end
    return true
  end
  # :nocov:

  # :nocov:
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
  # :nocov:


  def self.send_whisper(target_id, current_user, venue_id, notification_type, intro, message)
    origin_id = current_user.id.to_s
    # only users with active avatar can send whispers
    if current_user.user_avatars.where(:is_active => true).count <= 0 
      return "Please upload a profile photo first"
    elsif BlockUser.check_block(origin_id.to_i, target_id.to_i)
      return "User blocked"
    elsif FriendByWhisper.check_friends(current_user.id, target_id.to_i) 
      return 'You are already friends'
    else
      # whispers_sent_today = WhisperToday.where(target_user_id: target_id.to_i, origin_user_id: origin_id.to_i)
      pending_whisper = WhisperToday.find_pending_whisper(target_id.to_i, origin_id.to_i)
      # check if whisper sent today
      if pending_whisper.nil?
        whisper_just_sent = WhisperSent.where(['whisper_time > ?', Time.now-12.hours]).where(:origin_user_id => current_user.id).where(:target_user_id => target_id.to_i)
        if whisper_just_sent.blank?
          if Rails.env == 'production'
            n = WhisperNotification.create_in_aws(target_id, origin_id, venue_id, notification_type, intro)
          else
            n = WhisperNotification.new
            n.id = 'aaa'+current_user.id.to_s
          end
          whisper = WhisperToday.create!(:paper_owner_id => target_id.to_i, :dynamo_id => n.id, :target_user_id => target_id.to_i, :origin_user_id => origin_id.to_i, :whisper_type => notification_type, :message => intro, :message_b => '', :venue_id => venue_id.to_i)
          WhisperReply.create!(:speaker_id => current_user.id, :whisper_id => whisper.id, :message => intro)
          if n and notification_type == "2"
            time = Time.now
            RecentActivity.add_activity(origin_id.to_i, '2-sent', target_id.to_i, nil, "whisper-sent-"+target_id.to_s+"-"+origin_id.to_s+"-"+time.to_i.to_s, nil, nil, nil)
            RecentActivity.add_activity(target_id.to_i, '2-received', origin_id.to_i, nil, "whisper-received-"+origin_id.to_s+"-"+target_id.to_s+"-"+time.to_i.to_s, nil, nil, nil)

            record_found = WhisperSent.where(:origin_user_id => origin_id.to_i).where(:target_user_id => target_id.to_i)
            if record_found.count <= 0
              WhisperSent.create_new_record(origin_id.to_i, target_id.to_i)
            else
              record_found.first.update(:whisper_time => time)
            end
          end
          if Rails.env == 'production'
            n.send_push_notification_to_target_user(message, origin_id.to_i)
          end

          return "true"
        else
          return "Cannot send more whispers"
        end
      else
        if pending_whisper.paper_owner_id != current_user.id
          return "Cannot send more whispers"
        elsif pending_whisper.paper_owner_id == origin_id.to_i
          if Rails.env == 'production'
            n = WhisperNotification.create_in_aws(target_id, origin_id, venue_id, notification_type, intro)
          else
            n = WhisperNotification.new
            n.id = 'aaa'+current_user.id.to_s
          end
          # WhisperToday.create!(:paper_owner_id => target_id.to_i, :dynamo_id => n.id, :target_user_id => target_id.to_i, :origin_user_id => origin_id.to_i, :whisper_type => notification_type, :message => intro, :venue_id => venue_id.to_i)
          paper_owner_id = pending_whisper.paper_owner_id
          if pending_whisper.target_user_id == origin_id.to_i
            pending_whisper.paper_owner_id = pending_whisper.origin_user_id
            pending_whisper.message_b = intro
            pending_whisper.viewed = false
          elsif pending_whisper.origin_user_id == origin_id.to_i
            pending_whisper.paper_owner_id = pending_whisper.target_user_id
            pending_whisper.message = intro
            pending_whisper.viewed = false
          end
          pending_whisper.save!
          WhisperReply.create!(:speaker_id => current_user.id, :whisper_id => pending_whisper.id, :message => intro)
          if n and notification_type == "2"
            time = Time.now
            RecentActivity.add_activity(origin_id.to_i, '2-sent', target_id.to_i, nil, "whisper-sent-"+target_id.to_s+"-"+origin_id.to_s+"-"+time.to_i.to_s, nil, nil, nil)
            RecentActivity.add_activity(target_id.to_i, '2-received', origin_id.to_i, nil, "whisper-received-"+origin_id.to_s+"-"+target_id.to_s+"-"+time.to_i.to_s, nil, nil, nil)
          end
          if Rails.env == 'production'
            n.send_push_notification_to_target_user(message, paper_owner_id)
          end

          return "true"
        end
      end
      
    end
  end



  def self.send_message(target_id, current_user, venue_id, notification_type, intro, message)
    origin_id = current_user.id.to_s
    final_result = Hash.new
    # only users with active avatar can send whispers
    if current_user.user_avatars.where(:is_active => true).count <= 0 
      final_result['message'] = "Please upload a profile photo first"
    elsif BlockUser.check_block(origin_id.to_i, target_id.to_i)
      final_result['message'] = "User blocked"
    else
      conversation = WhisperToday.find_conversation(target_id.to_i, origin_id.to_i)
      # check if whisper sent today
      if conversation.nil?
        whisper_just_sent = WhisperSent.where(['whisper_time > ?', Time.now-12.hours]).where(:origin_user_id => current_user.id).where(:target_user_id => target_id.to_i)
        if whisper_just_sent.blank?
          if Rails.env == 'production'
            # :nocov:
            n = WhisperNotification.create_in_aws(target_id, origin_id, venue_id, notification_type, intro)
            # :nocov:
          else
            n = WhisperNotification.new
            n.id = 'aaa'+current_user.id.to_s
          end
          whisper = WhisperToday.create!(:paper_owner_id => target_id.to_i, :dynamo_id => n.id, :target_user_id => target_id.to_i, :origin_user_id => origin_id.to_i, :whisper_type => notification_type, :message => intro, :message_b => '', :venue_id => venue_id.to_i)
          chat_message = WhisperReply.create!(:speaker_id => current_user.id, :whisper_id => whisper.id, :message => intro)
          if n and notification_type == "2"
            time = Time.now

            record_found = WhisperSent.where(:origin_user_id => origin_id.to_i).where(:target_user_id => target_id.to_i)
            if record_found.count <= 0
              WhisperSent.create_new_record(origin_id.to_i, target_id.to_i)
            else
              record_found.first.update(:whisper_time => time)
            end
          end
          if chat_message and Rails.env == 'production'
            # :nocov:
            target_user = User.find_user_by_unique(target_id)
            if target_user and target_user.pusher_private_online
              channel = 'private-user-' + target_id.to_s
              message_json = {
                speaker_id: chat_message.speaker_id,
                id:         chat_message.id,
                conversation_id: (chat_message.whisper.dynamo_id.nil? ? '' : chat_message.whisper.dynamo_id), 
                timestamp:  chat_message.created_at.to_i,
                message:    chat_message.message.nil? ? '' : chat_message.message,
                read:       chat_message.read
              }
              Pusher.delay.trigger(channel, 'send_message_event', {message: message_json})
            else
              chat_message.send_push_notification_to_target_user(message, origin_id.to_i, target_id.to_i)
            end
            # :nocov:
          end

          final_result['message'] = "true"
          final_result['whisper'] = whisper
        else
          final_result['message'] = "Cannot send more whispers"
        end
      else
        if conversation.whisper_replies.count < 2 and current_user.id == conversation.origin_user_id
          final_result['message'] = "Cannot send more whispers"
        else
          if conversation.target_user_id == origin_id.to_i
            conversation.message_b = intro
          elsif conversation.origin_user_id == origin_id.to_i
            conversation.message = intro
          end
          conversation.target_user_archieve = false
          conversation.origin_user_archieve = false
          conversation.save!
          chat_message = WhisperReply.create!(:speaker_id => current_user.id, :whisper_id => conversation.id, :message => intro)
          
          if chat_message and Rails.env == 'production'
            # :nocov:
            target_user = User.find_user_by_unique(target_id)
            if target_user and target_user.pusher_private_online
              channel = 'private-user-' + target_id.to_s
              message_json = {
                speaker_id: chat_message.speaker_id,
                id:         chat_message.id,
                conversation_id: (chat_message.whisper.dynamo_id.nil? ? '' : chat_message.whisper.dynamo_id), 
                timestamp:  chat_message.created_at.to_i,
                message:    chat_message.message.nil? ? '' : chat_message.message,
                read:       chat_message.read
              }
              Pusher.delay.trigger(channel, 'send_message_event', {message: message_json})
            else
              chat_message.send_push_notification_to_target_user(message, origin_id.to_i, target_id.to_i)
            end
            # :nocov:
          end

          final_result['message'] = "true"
          final_result['whisper'] = conversation
        end
      end
      
    end
    return final_result
  end

  # :nocov:
  def send_push_notification_to_target_user(message, paper_owner_id)
    # deep_link = (self.target_id.to_i == 3) ? 
    if self.notification_type.to_i == 3
      deep_link = "yero://friends/" + self.origin_id.to_s
    else

      deep_link = "yero://whispers/" + paper_owner_id.to_s
    end

    data = { :alert => message, :type => self.notification_type.to_i, :badge => "Increment", :deep_link => deep_link}
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
  # :nocov:

  # :nocov:
  # send network open notification -> NOT used
  def self.send_nightopen_notification(id)
    data = { :alert => "Your city's network is now online", :type => 100}
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
  # :nocov:


  # :nocov:
  def self.send_notification_301(id, username, shout_id)
    deep_link = deep_link = "yero://shouts/" + shout_id.to_s
    data = { :alert => "@"+username+" replied to your shout", :type => 301, :deep_link => deep_link}
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
  # :nocov:

  # :nocov:
  def self.send_notification_302(ids, username, shout_id)
    deep_link = deep_link = "yero://shouts/" + shout_id.to_s
    data = { :alert => "@"+username+" replied to the same shout", :type => 302, :deep_link => deep_link}
    channel_array = Array.new
    ids.each do |id|
      channel_array << "User_" + id.to_s
    end
    push = Parse::Push.new(data, channel_array)
    push.channels = channel_array
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

  # :nocov:
  def self.send_notification_shout_remove(id, type)
    data = { :alert => "A " + ((type==303) ? "shout" : "reply") + " you posted has been flagged as inappropriate and removed", :type => type}
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
  # :nocov:


  # :nocov:
  def self.send_notification_330_level(id, type, total_votes, shout_id)
    deep_link = "yero://shouts/" + shout_id
    data = { :alert => "You received " + total_votes.to_s + " votes on your" + ((type > 329) ? "reply!" : "shout!"), :type => type, :deep_link => deep_link}
  
    push = Parse::Push.new(data, "User_"+id.to_s)
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

  # :nocov:
  # send enough users notification
  def self.send_enough_users_notification(id)

    data = { :alert => "Enough users have joined your city’s network", :type => 102, :deep_link => 'yero://people'}
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
  # :nocov:

  
  # :nocov:
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
  # :nocov:


  def self.unviewd_whisper_number(user_id)
    black_list = BlockUser.blocked_user_ids(user_id.to_i)
    whisper_items = WhisperToday.where(paper_owner_id: user_id.to_i).where(viewed: false).where.not(origin_user_id: black_list)
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