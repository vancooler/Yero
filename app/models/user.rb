class User < ActiveRecord::Base
  has_many :traffics
  has_many :winners
  has_many :pokes, foreign_key: "pokee_id"
  has_many :favourite_venues
  has_many :venues, through: :favourite_venues
  has_many :user_avatars, dependent: :destroy
  accepts_nested_attributes_for :user_avatars, allow_destroy: true
  has_one  :participant
  has_many :activities, dependent: :destroy
  has_many :locations
  has_one :read_notification, dependent: :destroy
  has_one :active_in_venue, dependent: :destroy
  has_one :active_in_venue_network, dependent: :destroy
  has_many :user_notification_preference, dependent: :destroy
  has_many :shouts
  has_many :shout_comments
  has_many :shout_votes
  has_many :shout_comment_votes
  has_many :shout_report_histories

  # Like feature
  acts_as_follower
  acts_as_followable


  reverse_geocoded_by :latitude, :longitude

  # mount_uploader :avatar, AvatarUploader
  before_save   :update_activity

  validates :email, :birthday, :first_name, :gender, presence: true
  validates :email, :email => true

  scope :sort_by_last_active, -> { 
    where.not(last_active: nil).
    order("last_active desc") 
  }
  has_secure_password



  # user's profile photo
  def main_avatar
    user_avatars.find_by(order: 0)
  end

  # Boolean: Checks if you are in the same venue as the other person
  # 
  #     @params:
  # 
  #         - user_id -> the other person's user id
  def same_venue_as?(user_id)
    if self.current_venue.nil?
      return false
    else 
      fellow_participant = User.find_by_id(user_id)
      if !fellow_participant.nil? 

        if fellow_participant.current_venue.nil? 
          return false
        end
        return self.current_venue.id == fellow_participant.current_venue.id

      else
        false
      end
    end
  end

  # Checks if you are in a different venue as the other person
  # 
  #     @params:
  # 
  #         - user_id -> the other person's user id
  def different_venue_as?(user_id)
    
    fellow_participant = User.find_by_id(user_id)
    if !fellow_participant.nil? 
      if fellow_participant.current_venue.nil? 
        return false
      elsif self.current_venue.nil?
        return false
      else
        return self.current_venue.id != fellow_participant.current_venue.id
      end
    else
      false
    end

  end


  ##########################################################################
  #
  # return photos that are not profile photo
  #
  ##########################################################################

  def secondary_avatars
    user_avatars.where.not(order: 0)
  end

  ##########################################################################
  #
  # Return the current user's current venue connection
  #
  ##########################################################################
  def current_venue
    return nil unless self.has_activity_today?
    return self.active_in_venue.venue
  end

  ##########################################################################
  #
  # Return the current user's current beacon connection
  #
  ##########################################################################
  def current_beacon
    return nil unless self.has_activity_today?
    return self.active_in_venue.beacon
  end

  ##########################################################################
  #
  # Return the current user's current venue network connection
  #
  ##########################################################################
  def current_venue_network
    if self.active_in_venue_network.nil?
      return nil
    else
      return self.active_in_venue_network.venue_network
    end
  end

  # Boolean check if the user is in any venue now
  def has_activity_today?
    !self.active_in_venue.nil?
  end

  # Main method to filter users
  # 
  #     @params:
  # 
  #         - gender ("M", "F", or "A", default: "A")
  #         - min_age (integer for minimum age, default: ignore this filter)
  #         - max_age (integer for maximum age, default: ignore this filter)
  #         - min_distance (integer for minimum distance, default: 0)
  #         - max_distance (integer for maximum distance, default: 60)
  #         - everyone (true or false, default: true)
  #         - venue_id (not used anymore, might be used in the future)

  def fellow_participants(ignore_connected, gender, min_age, max_age, venue_id, min_distance, max_distance, everyone)
    current_venue = self.current_venue
    current_venue_network = self.current_venue_network
    # return nil if current_venue.nil? and current_venue_network.nil?
    if everyone # everyone will search the network if the option is true
      aivs = ActiveInVenueNetwork.where("user_id != ?", self.id)
    else # else we will just search the people in the venue
      aivs = ActiveInVenue.where("user_id != ?", self.id) # Give me all the users that are out that are not me.
      # aivn = ActiveInVenueNetwork.where("user_id != ?", self.id)
      if !venue_id.nil? #If a parameter was passed in for venue_id
        aivs = aivs.where(:venue_id => venue_id) #Search for all people active in that particular venue
      end
    end
    active_users_id = [] # Make empty array.
    aivs.each do |aiv| 
      active_users_id << aiv.user_id #Toss into the array the user_id's of the people that are out or in a particular venue.
    end
    # if aivn # If there are people acitve in venue network
    #   aivn.each do |aivn| # Loop
    #     if active_users_id.include? aivn.user_id
    #     else
    #       active_users_id << aivn.user_id # Throw each one into the array
    #     end
    #   end
    # end

    # users = User.where(id: active_users_id) #Find all the users with the id's in the array.
    max_distance = max_distance.blank? ? 60 : max_distance # Do max_distance to include distance ranges (i.e. 9-10km, people 10km are included)
    # only return users with avatar near current user 
    # users = User.includes(:user_avatars).where.not(user_avatars: { id: nil }).where(user_avatars: { is_active: true}).where(user_avatars: { default: true}).near(self, max_distance, :units => :km)
    # filter for is_connected 
    black_list = BlockUser.blocked_user_ids(self.id)
    black_list << self.id
    if ignore_connected
      users = User.includes(:user_avatars).where.not(id: black_list).where.not(user_avatars: { id: nil }).where(user_avatars: { is_active: true}).where(user_avatars: { order: 0}).near(self, max_distance, :units => :km)
    else
      users = User.includes(:user_avatars).where.not(id: black_list).where(is_connected: true).where.not(user_avatars: { id: nil }).where(user_avatars: { is_active: true}).where(user_avatars: { order: 0}).near(self, max_distance, :units => :km)
    end

    if !everyone
      users = users.where(id: active_users_id)
      puts "everyone filter:"
      puts users.length
    end
    users = self.additional_filter(users, gender, min_age, max_age, min_distance, max_distance, everyone)
    
    return users
  end

  def additional_filter(users, gender, min_age, max_age, min_distance, max_distance, everyone)


    # users.delete(self)
    if !gender.nil? || gender != "A"
      if gender == "M" or gender == "F"
        users = users.where(:gender => gender) #Filter by gender
      end
    end
    if !max_age.nil? 
      users = users.where("birthday >= ?", (max_age).years.ago + 1.day) #Filter by max age
    end
    if !min_age.nil? and min_age > 0
      users = users.where("birthday <= ?", (min_age).years.ago) # Filter by min age
    end
    min_distance = 0 if min_distance.nil? 
    max_distance = 60 if max_distance.nil?
    max_distance = max_distance.blank? ? 60 : max_distance
    self.user_sort(users, min_distance, max_distance) #Returns the users filtered

  end

  ##########################################################################
  #
  # Filter users by distance and sort them by distance
  # 
  #     @params:
  # 
  #         - users (array of users)
  #         - min_distance (integer for minimum distance, default: 0)
  #         - max_distance (integer for maximum distance, default: 60)
  ##########################################################################
  def user_sort(users, min_distance, max_distance)
    
    result_users = users.near(self, max_distance, :units => :km).order('distance DESC')
    if min_distance != 0
      remove_users = users.near(self, min_distance, :units => :km).order('distance DESC')
      result_users = result_users.reject{|user| remove_users.include? user}
    end
       
    return result_users
  end

  # TODO: check if used anywhere, replaced by last_active
  def last_activity
    self.activities.last
  end

  # user's profile photo
  def default_avatar
    self.user_avatars.where(order: 0).first
  end

  # user's age
  def age
    dob = self.birthday
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  # first_name (id) -> convenient for admins reading
  def name
    first_name + ' (' + id.to_s + ')'
  end

  # CORE function of serializing user to json structure
  def to_json(with_key)
    time_1 = Time.now
    data = Jbuilder.encode do |json|
      json.id id
      json.birthday birthday
      json.first_name first_name
      json.username username
      json.gender gender
      json.email email
      json.snapchat_id (snapchat_id.blank? ? '' : snapchat_id)
      json.instagram_id (instagram_id.blank? ? '' : instagram_id)
      json.instagram_token (instagram_token.blank? ? '' : instagram_token)
      json.spotify_id (spotify_id.blank? ? '' : spotify_id)
      json.spotify_token (spotify_token.blank? ? '' : spotify_token)
      json.wechat_id (wechat_id.blank? ? '' : wechat_id)
      json.line_id (line_id.blank? ? '' : line_id)
      json.introduction_1 (introduction_1.blank? ? '' : introduction_1)
      json.status (introduction_2.blank? ? '' : introduction_2)
      json.latitude (latitude.blank? ? 0 : latitude)
      json.longitude (longitude.blank? ? 0 : longitude)
      json.discovery discovery
      json.exclusive exclusive
      json.last_active (last_active.nil? ? 0 : last_active.to_i)
      # json.joined_today is_connected
      # json.last_status_active_time (last_status_active_time.nil? ? 0 : last_status_active_time.to_i)
      # json.current_venue (self.current_venue.blank? or self.current_venue.beacons.blank? or self.current_venue.beacons.first.key.blank? ) ? '' : self.current_venue.beacons.first.key.split('_').second
      # json.current_city current_city.blank? ? '' : current_city

      json.avatars do
        avatars = self.user_avatars.where(is_active: true).order(:order)
        if avatars.blank?
          Array.new 
        else
          json.array! avatars do |a|
            json.avatar a.origin_url
            json.thumbnail a.thumb_url
            json.avatar_id a.id
            json.order (a.order.nil? ? 100 : a.order)
          end
        end
      end

      json.notification_preferences do
        preferences = NotificationPreference.all
        json.array! preferences do |p|
          json.type p.name
          if p.name == "Leave venue network"
            json.enabled (p.user_notification_preference.where(:user_id => self.id).blank? ? false : true)
          else
            json.enabled (p.user_notification_preference.where(:user_id => self.id).blank? ? true : false)
          end
        end
      end

      # if with_key
      #   json.key key
      # end
    end

    response = JSON.parse(data)
    if response['avatars'].blank?
      response['avatars'] = Array.new
    end
    time_2 = Time.now
    puts "user.to_json TIME: "
    runtime = time_2 - time_1  
    puts runtime.inspect

    response
  end

  # keeps track of the latest activity of a user 
  # 
  # TODO: Check if used anywhere replaced by last_active
  def update_activity
    self.last_activity = Time.now
  end

  # def send_network_open_notification
  #   WhisperNotification.send_nightopen_notification(self.id) 
  # end

  # This code for usage with a CRON job. Currently done using Heroku Scheduler
  # def self.network_open
  #   time1 = Time.now

  #   times_result = TimeZonePlace.select(:timezone) #Grab all the timezones in db
  #   times_array = Array.new # Make a new array to hold the times that are at 5:00pm
  #   times_result.each do |timezone| # Check each timezone
  #     Time.zone = timezone["timezone"] # Assign timezone
  #     int_time = Time.zone.now.strftime("%H%M").to_i
  #     if int_time >= 1700 and int_time < 1710 # If time is 17:00 ~ 17:09
  #       open_network_tz = Time.zone.name.to_s #format it
  #       times_array << open_network_tz #Throw into array
  #     end
  #   end

  #   time2 = Time.now
  #   dbtime = time2 - time1
  #   puts "runtime2: "
  #   puts dbtime.inspect

  #   # if !times_array.empty?
  #   #   user_ids = UserLocation.find_by_dynamodb_timezone(times_array, false) #Find users of that timezone
  #   # end

  #   if !times_array.empty?    
  #     user_ids = User.where(:timezone_name => times_array).map(&:id)
  #     # people_array = UserLocation.find_by_dynamodb_timezone(times_array, true) #Find users of that timezone
  #   end


  #   time3 = Time.now
  #   dbtime = time3 - time2
  #   puts "runtime3: "
  #   puts dbtime.inspect
    
  #   if !user_ids.nil? and user_ids.length > 0
  #     users = User.where(id: user_ids)
  #   end


  #   if !users.nil? and users.length > 0
  #     people_array = Array.new 
  #     users.each do |tmp_user|
  #       user_hash = Hash.new
  #       user_hash['id'] = tmp_user.id
  #       user_hash['token'] = tmp_user.apn_token
  #       user_hash['updated_at'] = tmp_user.updated_at
  #       people_array << user_hash
  #     end
  #   end

  #   time4 = Time.now
  #   dbtime = time4 - time3
  #   puts "runtime4s: "
  #   puts dbtime.inspect

  #   # remove duplicated apn_tokens
  #   if !people_array.nil? and people_array.length > 0
  #     people_array = people_array.group_by { |x| x['token'] }.map {|x,y|y.max_by {|x|x['updated_at']}}

  #     people_array.each_slice(25) do |people_group|
  #       batch = AWS::DynamoDB::BatchWrite.new
  #       notification_array = Array.new
  #       people_group.each do |person|
  #         if !person.blank?
  #           request = Hash.new()
  #           request["target_id"] = person['id'].to_s
  #           request["timestamp"] = Time.now.to_i
  #           request["origin_id"] = '0'
  #           request["created_date"] = Date.today.to_s
  #           request["venue_id"] = '0'
  #           request["notification_type"] = '0'
  #           request["intro"] = "Yero is now online. Connect to your city's network."
  #           request["viewed"] = 0
  #           request["not_viewed_by_sender"] = 1
  #           request["accepted"] = 0
  #           notification_array << request

  #           user = User.find(person['id'].to_i)
  #           if UserNotificationPreference.no_preference_record_found(user, "Network online")
  #             user.delay.send_network_open_notification
  #           end
  #         end
  #       end
  #       if notification_array.count > 0
  #         table_name = WhisperNotification.table_prefix + 'WhisperNotification'
  #         batch.put(table_name, notification_array)
  #         batch.process!
  #       end
  #     end
  #   end
  #   time5 = Time.now
  #   dbtime = time5 - time4
  #   puts "runtime5: "
  #   puts dbtime.inspect

  #   puts "runtimeALL: "
  #   puts (time5 - time1).inspect
  # end

  # cron job method scheduled at 5am in user's local time to reset everything as a new day
  def self.handle_close(times_array)
    time1 = Time.now
    # disconnect all users
    people_array = Array.new 
    if !times_array.empty?    
      people_array = User.where(:timezone_name => times_array).where("version <> ? OR version is ?", '2.0', nil).map(&:id)
      # people_array = UserLocation.find_by_dynamodb_timezone(times_array, true) #Find users of that timezone
    end
    if !people_array.empty? 
      User.leave_activity(people_array)
      User.where(id: people_array).update_all(is_connected: false, enough_user_notification_sent_tonight: false) # disconnect users
      # WhisperNotification.expire(people_array, '2')
      # expire all whispers with type 2 of these users
      # whispers_today = WhisperToday.where(target_user_id: people_array)
      # whispers_today.delete_all
    end
    # cleanup active_in_venue_network & active_in_venue & enter_today
    venue_networks = VenueNetwork.where(:timezone => times_array)
    venue_networks.each do |vn|
      ActiveInVenueNetwork.five_am_cleanup(vn, people_array)
    end
    time2 = Time.now
    puts "CLOSE runtimeALL: "
    puts (time2 - time1).inspect
    return true
  end

  # :nocov:
  # This code for usage with a CRON job to force network close. Currently done using Heroku Scheduler
  def self.network_close
    times_result = TimeZonePlace.select(:timezone) #Grab all the timezones in db
    times_array = Array.new # Make a new array to hold the times that are at 5:00pm
    times_result.each do |timezone| # Check each timezone
      Time.zone = timezone["timezone"] # Assign timezone
      int_time = Time.zone.now.strftime("%H%M").to_i
      if int_time >= 500 and int_time < 519 # If time is 5:00 ~ 5:19
        open_network_tz = Time.zone.name.to_s #format it
        times_array << open_network_tz #Throw into array
      end
    end
    User.handle_close(times_array)
    
  end
  # :nocov:

  # Not used in current version
  def friends_by_like
    followees = self.followees(User)
    followers = self.followers(User)
    mutual_follow = followers & followees

    return mutual_follow
  end



  # gather actions
  def collect_whisper_actions(are_friends, can_reply, can_accept_delete, whisper_sent, user, pending_whispers)
    actions = Array.new
    if are_friends
      actions << "chat"
    end
    if can_reply
      actions << "reply"
      actions << "delete"
    end
    if can_accept_delete
      actions << "accept"
      actions << "delete"  
    end
    if !whisper_sent and !are_friends and !can_accept_delete and !can_reply and !(pending_whispers.include? user.id)
      actions << "whisper"
    end

    return actions.uniq
  end

  # gather messages array for whisper reply history
  def collect_whisper_message_history(user, actions)
    hash = Hash.new
    if actions.include? "reply" or actions.include? "delete"
      whisper_today = WhisperToday.find_pending_whisper(user.id, self.id)
      if !whisper_today.nil?
        hash['whisper_id'] = whisper_today.dynamo_id
        replies = WhisperReply.where(whisper_id: whisper_today.id).order("created_at DESC")
        if replies.count > 0
          messages_array = Array.new
          replies.each do |r|
            new_item = {
              speaker_id: r.speaker_id,
              timestamp: r.created_at.to_i,
              message: r.message.nil? ? '' : r.message
            }
            messages_array << new_item
          end
        end
        hash['messages_array'] = messages_array
      end
    end

    return hash
  end


  # CORE function to gather ppl, all parameters from controller
  # 
  #     @params:
  # 
  #         - gate_number (integer, minimum number of users people can see before filter)
  #         - gender ("M", "F", or "A", default: "A")
  #         - min_age (integer for minimum age, default: ignore this filter)
  #         - max_age (integer for maximum age, default: ignore this filter)
  #         - min_distance (integer for minimum distance, default: 0)
  #         - max_distance (integer for maximum distance, default: 60)
  #         - everyone (true or false, default: true)
  #         - venue_id (not used anymore, might be used in the future)
  #         - page_number (integer for pagination)
  #         - users_per_page (integer for pagination)

  def people_list(gate_number, gender, min_age, max_age, venue_id, min_distance, max_distance, everyone, page_number, users_per_page)
    diff_1 = 0
    diff_2 = 0
    result = Hash.new
    # check 
    # if ActiveInVenueNetwork.joins(:user).where('users.is_connected' => true).count >= gate_number
    ignore_connected = false
    all_users = self.fellow_participants(ignore_connected, nil, 0, 100, nil, 0, 60, true)
    number_of_users = all_users.length + 1
    if number_of_users >= gate_number  
      s_time = Time.now
      # collect all whispers sent 
      # TODO: use model to do it
      whispers_sent = WhisperNotification.collect_whispers(self)
      whispers_can_reply = WhisperNotification.collect_whispers_can_reply(self)
      whispers_can_accept_delete = WhisperNotification.collect_whispers_can_accept_delete(self)
      pending_whispers = WhisperToday.pending_whispers(self.id)

      # colect all users with "like"
      followees = self.followees(User)
      # collect all friends with mutual like AND whisper accepted friends
      mutual_follow = self.friends_by_like
      whisper_friends = FriendByWhisper.friends(self.id)
      friends = mutual_follow | whisper_friends

      # get all users with filter params
      return_users = self.fellow_participants(ignore_connected, gender, min_age, max_age, venue_id, min_distance, max_distance, everyone)
      puts "RETURN USERS:"
      puts everyone.to_s
      puts return_users.length
      if self.current_venue.blank?
        same_venue_user_ids = Array.new
      else
        same_venue_user_ids = ActiveInVenue.where(:venue_id => self.current_venue.id).map(&:user_id)
      end

      campus_id = VenueType.find_by_name("Campus")
      if campus_id
        campus_venue_ids = Venue.where(venue_type_id: campus_id.id.to_s).map(&:id)
      else
        campus_venue_ids = [nil]
      end
      if self.current_venue.blank?
        different_venue_user_ids = ActiveInVenue.where.not(:venue_id => campus_venue_ids).map(&:user_id)
      else
        campus_venue_ids << self.current_venue.id
        different_venue_user_ids = ActiveInVenue.where.not(:venue_id => campus_venue_ids).map(&:user_id)
      end

      # build json format
      users = Jbuilder.encode do |json|
        same_venue_time = 0
        different_venue_time = 0
        check_badge_time = 0
        avatar_time = 0
        other_time = 0
        json.array! return_users do |user|
          if user.id != self.id
            next unless user.user_avatars.present?
            next unless user.main_avatar.present?
            # main_avatar   =  user.user_avatars.where(order:0).where(is_active:true)
            # other_avatars =  user.user_avatars.where.not(order:0).where(is_active:true).order(:order)
            other_avatars = user.user_avatars.where(is_active:true).order(:order)
            avatar_array = Array.new

            # avatar_array[0] = {
            #       avatar: main_avatar.blank? ? '' : main_avatar.first.avatar.url,
            #       thumbnail: main_avatar.blank? ? '' : main_avatar.first.avatar.thumb.url,
            #       avatar_id: main_avatar.blank? ? '' : main_avatar.first.id,
            #       default: true,
            #       is_active: true,
            #       order: main_avatar.first.order.nil? ? '100' : main_avatar.first.order
            #     }
            if other_avatars.count > 0
              other_avatars.each do |oa|
                new_item = {
                  avatar: !oa.avatar.nil? ? oa.origin_url : '',
                  thumbnail: !oa.avatar.nil? ? oa.thumb_url : '',
                  avatar_id: oa.id,
                  default: oa.order.nil? ? true : (oa.order==0),
                  is_active: true,
                  order: oa.order.nil? ? '100' : oa.order
                }
                avatar_array << new_item
              end
            end

            json.avatars avatar_array


            json.whisper_sent whispers_sent.include? user.id.to_i
            are_friends = (friends.map(&:id).include? user.id)
            whisper_sent = (whispers_sent.include? user.id.to_i)
            can_reply = (whispers_can_reply.include?  user.id.to_i)
            can_accept_delete = (whispers_can_accept_delete.include?  user.id.to_i)

            

            actions = self.collect_whisper_actions(are_friends, can_reply, can_accept_delete, whisper_sent, user, pending_whispers)
            json.actions actions
            whisper_hash = self.collect_whisper_message_history(user, actions)
            if !whisper_hash['whisper_id'].nil?
                json.whisper_id whisper_hash['whisper_id']
            end
            if !whisper_hash['messages_array'].nil?
                json.messages_array whisper_hash['messages_array']
            end

            if followees.blank?
              json.like false
            else
              json.like followees.map(&:id).include? user.id
            end

            if friends.blank?
              json.friend false
            else
              json.friend friends.map(&:id).include? user.id
            end

            
            # json.same_venue_badge          self.same_venue_as?(user.id) # Returns a boolean of whether you're in the same venue as the other person.
            json.same_venue_badge          same_venue_user_ids.include? user.id
            # json.different_venue_badge     self.different_venue_as?(user.id)
            json.different_venue_badge          different_venue_user_ids.include? user.id
            # json.same_beacon               self.same_beacon_as?(user.id) # Returns a boolean of whether you're in the same venue as the other person.
            json.venue_type          (user.current_venue.nil? or user.current_venue.venue_type.nil? or user.current_venue.venue_type.name.nil?) ? '' : user.current_venue.venue_type.name
            

            json.id             user.id
            json.first_name     user.first_name
            # json.key            user.key
            # json.since_1970     (user.last_active - Time.new('1970')).seconds.to_i
            json.birthday       user.birthday
            json.gender         user.gender
            json.last_active    user.last_active.nil? ? 0 : user.last_active.to_i 
            json.last_status_active_time    user.last_status_active_time.nil? ? 0 : user.last_status_active_time.to_i 
            json.line_id      user.line_id.blank? ? '' : user.line_id
            json.wechat_id      user.wechat_id.blank? ? '' : user.wechat_id
            json.snapchat_id    user.snapchat_id.blank? ? '' : user.snapchat_id
            json.instagram_id   user.instagram_id.blank? ? '' : user.instagram_id
            json.spotify_id   user.spotify_id.blank? ? '' : user.spotify_id

            # json.apn_token      user.apn_token
            json.latitude       user.latitude  
            json.longitude      user.longitude 
            json.introduction_1 user.introduction_1.blank? ? '' : user.introduction_1
            json.status user.introduction_2.blank? ? '' : user.introduction_2
            json.exclusive      user.exclusive
          end
        end
        # json_e = Time.now
        # j_time = json_e-json_s
        # puts "The dbtime is: "
        # puts dbtime.inspect 
        # pre_time = pre_time_2 - s_time
        # friend_time = pre_time_3 - pre_time_2
        # p "Pre time:"
        # p pre_time.inspect
        # p "friend time:"
        # p friend_time.inspect

        # p "Json time:"
        # p j_time.inspect
        # p "avatar time:"
        # p avatar_time.inspect
        # p "same_venue time:"
        # p same_venue_time.inspect
        # p "different_venue time:"
        # p different_venue_time.inspect
        # p "check badge time:"
        # p check_badge_time.inspect
      end

      users = JSON.parse(users).delete_if(&:empty?)

      # TODO: Move to db level to improve performance
      different_venue_users = [] # Make a empty array for users in the different venue
      same_venue_users = [] #Make a empty array for users in the same venue
      no_badge_users = [] # Make an empty array for no badge users
      users.each do |u| # Go through the users
        if !!u['exclusive'] == true
          if u['same_venue_badge'].to_s == "true"
             same_venue_users << u # Throw the user into the array
          end
        else
          if !!u['exclusive'] == false
            if u['different_venue_badge'].to_s == "true" #If the users' same beacon field is true
              different_venue_users << u # Throw the user into the array
            elsif u['same_venue_badge'].to_s == "true" #If the users' same venue field is true
              same_venue_users << u # Throw the user into the array
            elsif everyone
              different_venue_users << u # Users who are not in a venue also thrown into here.
            end
          end
        end
      end
      
      # users = users - same_beacon_users - same_venue_users # Split out the users such that users only contain those that are not in the same venue or same beacon
      
      users = same_venue_users.shuffle + different_venue_users  #Sort users by distance
      # ADD Pagination
      if !page_number.nil? and !users_per_page.nil? and users_per_page > 0 and page_number >= 0
        users = Kaminari.paginate_array(users).page(page_number).per(users_per_page) if !users.nil?
      end


      e_time = Time.now
      runtime = e_time - s_time
      
      puts "The runtime is: "
      puts runtime.inspect

      # count = users.count
      result['users'] = users
      puts "USERS RESULT:"
      puts users.count
    else
      # count = ActiveInVenueNetwork.joins(:user).where('users.is_connected' => true).count
      count = number_of_users
      users = Array.new
      result['percentage'] = (count * 100 / gate_number).to_i
    end
    # puts "USERS RESULT:"
    # puts result.inspect
    return result
  end

  # :nocov:
  # mark array of whispers as viewed in dynamodb
  def viewed_by_sender(whispers)
    
    result = true
    # update dynamodb
    dynamo_db = AWS::DynamoDB.new
    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    table = dynamo_db.tables[table_name]
    if !table.schema_loaded?
      table.load_schema
    end
    puts "Read time: "
    items = table.items.where(:id).in(*whispers).where(:notification_type).not_equal_to("0").select(:target_id, :timestamp, :id, :origin_id, :accepted, :declined, :created_date, :venue_id, :notification_type, :intro, :expired, :viewed, :not_viewed_by_sender)
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
          request["expired"] = attributes['expired'] if !attributes['expired'].nil?
          request["viewed"] = 1
          request["not_viewed_by_sender"] = 0
          notification_array << request 
        end
      end
      if notification_array.count > 0
        batch.put(table_name, notification_array)
        batch.process!
      end
    end

    return result
  end
  # :nocov:

  # Serialize user to JSON in current_user's eyes
  def user_object(current_user)
    
    user_object = {
      # same_venue_badge:          current_user.same_venue_as?(self.id),
      # different_venue_badge:     current_user.different_venue_as?(self.id) ,
      id:              self.id,
      first_name:      self.first_name,
      username:        self.username,
      last_active:     self.last_active.nil? ? 0 : self.last_active.to_i,
      # last_status_active_time: self.last_status_active_time.nil? ? 0 : self.last_status_active_time.to_i,
      # last_activity:  self.last_activity,
      # since_1970:     (self.last_active - Time.new('1970')).seconds.to_i,
      gender:          self.gender,
      birthday:        (self.id != 0 ? self.birthday : ''),
      created_at:      self.created_at,
      updated_at:      self.updated_at,
      avatars:         self.user_avatar_object.blank? ? Array.new : self.user_avatar_object,
      email:           self.email,
      instagram_id:    self.instagram_id.blank? ? '' : self.instagram_id,
      instagram_token: self.instagram_token.blank? ? '' : self.instagram_token,
      spotify_id:      self.spotify_id.blank? ? '' : self.spotify_id,
      spotify_token:   self.spotify_token.blank? ? '' : self.spotify_token,
      snapchat_id:     self.snapchat_id.blank? ? '' : self.snapchat_id,
      wechat_id:       self.wechat_id.blank? ? '' : self.wechat_id,
      line_id:         self.line_id.blank? ? '' : self.line_id,
      latitude:        self.latitude,
      longitude:       self.longitude,
      introduction_1:  self.introduction_1.blank? ? '' : self.introduction_1,
      status:  self.introduction_2.blank? ? '' : self.introduction_2
    }

    return user_object
  end

  # Serialize user's avatars in JSON
  def user_avatar_object
    
    data = Jbuilder.encode do |json|
      json.avatars do
        avatars = self.user_avatars.where(is_active: true).order(:order)
        if avatars.empty?
          Array.new
        else
          json.array! avatars do |a|

            json.avatar a.origin_url
            json.thumbnail a.thumb_url
            # json.default (!a.order.nil? and a.order == 0)
            # json.is_active a.is_active
            json.avatar_id a.id
            json.order (a.order.nil? ? 100 : a.order)

          end
        end
      end
    end
    data = JSON.parse(data)
    return data["avatars"]
  end

  # Generate auth token
  def generate_token(with_expire_time = nil)
    expire_time = (Time.now.to_i + 3600*24)
    user = {:id => self.id, :exp => expire_time } # expire in 24 hours
    if Rails.env == 'development' or Rails.env == 'test'
      secret = 'secret'
    else
      secret = ENV['SECRET_KEY_BASE']
    end
    token = JWT.encode(user, secret)

    if with_expire_time.nil?
      return token
    else
      token_obj = Hash.new
      token_obj['expire'] = expire_time.to_i
      token_obj['token'] = token
      return token_obj
    end
  end

  # Join network with click the button
  def join_network
    if self.is_connected == false
      self.is_connected = true
      self.save
      RecentActivity.add_activity(self.id, '200', nil, nil, "online-"+self.id.to_s+"-"+Time.now.to_i.to_s)
    end
  end

  # Leave the network
  def leave_network
    self.is_connected = false
    self.save
  end

  # Create leave network activity for users in array
  # 
  #     @params:
  # 
  #         - people_array (array of user ids)
  def self.leave_activity(people_array)
    
    current_timestamp = Time.now.to_i
    people_array.each do |user|
      check_user = User.find_by_id(user.to_i)
      if check_user and check_user.is_connected
        RecentActivity.add_activity(user, '201', nil, nil, "offline-"+user.to_s+"-"+current_timestamp.to_s)
      end
    end
  end

  # reorder user's photos based on the order of photo ids in the array given by controller
  # 
  #     @params:
  # 
  #         - avatar_ids (array of photo ids)
  def avatar_reorder(avatar_ids)
    order = 0
    avatar_ids.each do |ua_id|
      ua = UserAvatar.find_by_id(ua_id)
      if ua and ua.user_id == self.id and ua.is_active
        ua.order = order
        if ua.save
          order += 1
        end
      end
    end
    return true
  end

  # Test method to forch last 100 users join the network
  def force_users_join_to_test
    users = User.order("id DESC").limit(100) 
    users.each do |user|
      user.join_network
    end
  end

  # Forch some test users join the network
  # 
  #     @params:
  # 
  #         - timezone (string user's timezone)
  #         - number_of_male (integer)
  #         - number_of_female (integer)

  def self.random_join_fake_users(timezone, number_of_male, number_of_female)
    female_fake_users = User.where(timezone_name: timezone).where(is_connected: false).where(fake_user: true).where(gender: 'F').sample(number_of_female)
    male_fake_users = User.where(timezone_name: timezone).where(is_connected: false).where(fake_user: true).where(gender: 'M').sample(number_of_male)

    if !female_fake_users.blank?
      female_fake_users.each do |user|
        user.join_network
      end
    end
    if !male_fake_users.blank?
      male_fake_users.each do |user|
        user.join_network
      end
    end
  end

  # :nocov:
  # Join test users
  def self.fake_users_join
    times_result = TimeZonePlace.select(:timezone) #Grab all the timezones in db
    times_array = Array.new # Make a new array to hold the times that are at 5:00pm
    times_result.each do |timezone| # Check each timezone
      Time.zone = timezone["timezone"] # Assign timezone
      int_time = Time.zone.now.strftime("%H%M").to_i
      if int_time >= 1700 and int_time < 1719 # If time is 17:00 ~ 17:19
        open_network_tz = Time.zone.name.to_s #format it
        times_array << open_network_tz #Throw into array
      end
    end

    round_array = [4, 5]
    random_round = round_array.sample
    (1..random_round).each do |i|
      User.delay(run_at: (30*i).minutes.from_now).random_join_fake_users(times_array, 1, 4)
    end
    User.random_join_fake_users(times_array, 1, 4)
  end
  # :nocov:

  def self.fake_users_activate
    
    timezones = User.where(fake_user: true).map(&:timezone_name).uniq

    times_day = Array.new
    times_night = Array.new
    timezones.each do |tz|
      Time.zone = tz # Assign timezone
      int_time = Time.zone.now.strftime("%H%M").to_i
      if int_time >= 100 and int_time < 1000 # If time is 1:00 ~ 10:00
        times_night << tz #Throw into array
      else
        times_day << tz
      end
    end

    User.activate_day(times_day)
    User.activate_night(times_night)


  end

  # :nocov:
  def self.activate_day(times_day)
    times_day.each do |tz|
      time_zone = TimeZonePlace.find_by_timezone(tz)
      if time_zone.has_attribute?(:time_no_active)
        case time_zone.time_no_active
        when nil
          posibility = [false, false, false, true]
          next_time = 1
        when 0
          posibility = [false, false, false, true]
          next_time = 1
        when 1
          posibility = [false, false, true]
          next_time = 2
        when 2
          posibility = [false, true]
          next_time = 3
        when 3
          posibility = [true]
          next_time = 0
        end

        if posibility.sample
          more_users = [0, 1].sample
          if !more_users.nil?
            fake_user = User.where(timezone_name: tz).where(fake_user: true).where(gender: 'F').where("last_active < ?", Time.now-24.hours).sample
            if !fake_user.nil?
              fake_user.update(last_active: Time.now)
              if more_users > 0
                fake_users = User.where(timezone_name: tz).where(fake_user: true).where.not(id: fake_user.id).sample(more_users)
                if !fake_users.blank?
                  fake_users.each do |u|
                    u.update(last_active: Time.now)
                  end
                end
              end
            else
              fake_user = User.where(timezone_name: tz).where(fake_user: true).where(gender: 'F').sample
              fake_user.update(last_active: Time.now)
              if more_users > 0
                fake_users = User.where(timezone_name: tz).where(fake_user: true).where.not(id: fake_user.id).sample(more_users)
                if !fake_users.blank?
                  fake_users.each do |u|
                    u.update(last_active: Time.now)
                  end
                end
              end
            end

          end
          time_zone.update(time_no_active: 0)
        else
          time_zone.update(time_no_active: next_time)
        end
      end
    end
  end


  def self.activate_night(times_night)
    times_night.each do |tz|
      time_zone = TimeZonePlace.find_by_timezone(tz)
      if time_zone.has_attribute?(:time_no_active)
        case time_zone.time_no_active
        when nil
          posibility = [false]
          next_time = 1
        when 0
          posibility = [false]
          next_time = 1
        when 1
          posibility = [false, false, true]
          next_time = 2
        when 2
          posibility = [false, true]
          next_time = 3
        when 3
          posibility = [true]
          next_time = 0
        end

        if posibility.sample
          fake_user = User.where(timezone_name: tz).where(fake_user: true).sample
          fake_user.update(last_active: Time.now)
          time_zone.update(time_no_active: 0)
        else
          time_zone.update(time_no_active: next_time)
        end
      end
    end


  end
  # :nocov:

  # Inport a single user with hash structure
  def self.import_single_user(user_obj)
    email = user_obj['Email'].nil? ? '' : user_obj['Email']
    check_user = User.find_by_email(email)
    if check_user.nil?
      first_name = user_obj['Name'].nil? ? '' : user_obj['Name']
      password = user_obj['Password'].nil? ? '' : user_obj['Password']
      key = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless User.exists?(key: random_token)
      end
      snapchat_id = rand(36**5).to_s(36)
      birthday = user_obj['Birthday']
      gender = user_obj['Gender']
      introduction_1 = user_obj['Bio']
      timezone_name = "America/Vancouver"
      current_city = "Vancovuer"
      latitude = user_obj['Latitude'].to_f
      longitude = user_obj['Longtitude'].to_f
      is_connected = false
      exclusive = false
      fake_user = true

      # create user
      user = User.create!(:email => email, :birthday => birthday, :first_name => first_name, :password => password, :key => key, :snapchat_id => snapchat_id, :gender => gender, :introduction_1 => introduction_1, :timezone_name => timezone_name, :current_city => current_city, :latitude => latitude, :longitude => longitude, :is_connected => false, :exclusive => false, :fake_user => true, :last_active => Time.now)

      if !user.nil?
        user.birthday = user.birthday + 1900.years
        user.save
        # create photos
        id_array = ['1', '2', '3', '4', '5', '6']
        id_array.each do |avatar_id|
          origin_img_url = 'http://s3-us-west-2.amazonaws.com/yero/Test+users/'+user.first_name+avatar_id+'.jpg'
          downcase_img_url = 'http://s3-us-west-2.amazonaws.com/yero/Test+users/'+user.first_name.downcase+avatar_id+'.jpg'
          res = Net::HTTP.get_response(URI.parse(origin_img_url))
          downcase_res = Net::HTTP.get_response(URI.parse(downcase_img_url))
          if res.code == '200'
            current_order = UserAvatar.where(:user_id => user.id).where(:is_active => true).maximum(:order)
            
            avatar = UserAvatar.new(user: user)
            next_order = current_order.nil? ? 0 : current_order+1
            avatar.order = next_order

            avatar.remote_avatar_url = origin_img_url
            if avatar.save
              avatar.origin_url = avatar.avatar.url
              avatar.thumb_url = avatar.avatar.thumb.url
              avatar.save
            end
          elsif downcase_res.code == '200'
            current_order = UserAvatar.where(:user_id => user.id).where(:is_active => true).maximum(:order)
            
            avatar = UserAvatar.new(user: user)
            next_order = current_order.nil? ? 0 : current_order+1
            avatar.order = next_order

            avatar.remote_avatar_url = downcase_img_url
            if avatar.save
              avatar.origin_url = avatar.avatar.url
              avatar.thumb_url = avatar.avatar.thumb.url
              avatar.save
            end
          end
        end
      end
    else
      # create photos
      latitude = user_obj['Latitude'].to_f
      longitude = user_obj['Longtitude'].to_f
      check_user.update(:latitude => latitude, :longitude => longitude)
      id_array = ['1', '2', '3', '4', '5', '6']
      id_array.each do |avatar_id|
        current_order = UserAvatar.where(:user_id => check_user.id).where(:is_active => true).maximum(:order)
        
        avatar = UserAvatar.new(user: check_user)
        next_order = current_order.nil? ? 0 : current_order+1
        if next_order < avatar_id.to_i
          origin_img_url = 'http://s3-us-west-2.amazonaws.com/yero/Test+users/'+check_user.first_name+avatar_id+'.jpg'
          downcase_img_url = 'http://s3-us-west-2.amazonaws.com/yero/Test+users/'+check_user.first_name.downcase+avatar_id+'.jpg'
          res = Net::HTTP.get_response(URI.parse(origin_img_url))
          downcase_res = Net::HTTP.get_response(URI.parse(downcase_img_url))

          if res.code == '200'
            avatar.order = next_order

            avatar.remote_avatar_url = origin_img_url
            if avatar.save
              avatar.origin_url = avatar.avatar.url
              avatar.thumb_url = avatar.avatar.thumb.url
              avatar.save
            end
          elsif downcase_res.code == '200'
            avatar.order = next_order

            avatar.remote_avatar_url = downcase_img_url
            if avatar.save
              avatar.origin_url = avatar.avatar.url
              avatar.thumb_url = avatar.avatar.thumb.url
              avatar.save
            end
          end
        end
      end

    end
  end

  # :nocov:
  # Inport users in csv file
  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      user_obj = row.to_hash
      User.import_single_user(user_obj)
    end
    return true
  end
  # :nocov:



  def collect_users(gender, min_age, max_age, venue_id, min_distance, max_distance, everyone)
    ignore_connected = true
    time_1 = Time.now
    black_list = BlockUser.blocked_user_ids(self.id)
    black_list << self.id
    all_users = User.includes(:user_avatars).where.not(id: black_list).where.not(user_avatars: { id: nil }).where(user_avatars: { is_active: true}).where(user_avatars: { order: 0}).where("exclusive is ? OR exclusive = ?", nil, false)
    all_users = self.additional_filter(all_users, gender, min_age, max_age, min_distance, max_distance, everyone).sort_by{ |hsh| hsh.last_active }.reverse
    time_2 = Time.now
    campus_id = VenueType.find_by_name("Campus")
    if campus_id
      campus_venue_ids = Venue.where(venue_type_id: campus_id.id.to_s).map(&:id)
    else
      campus_venue_ids = [nil]
    end
    if self.current_venue.blank?
      same_venue_user_ids = Array.new
      different_venue_user_ids = ActiveInVenue.where.not(:venue_id => campus_venue_ids).map(&:user_id)
    else
      same_venue_user_ids = ActiveInVenue.where(:venue_id => self.current_venue.id).map(&:user_id)
      campus_venue_ids << self.current_venue.id
      different_venue_user_ids = ActiveInVenue.where.not(:venue_id => campus_venue_ids).map(&:user_id)

    end
    time_3 = Time.now
    same_venue_users = User.includes(:user_avatars).where.not(id: black_list).where(id: same_venue_user_ids).where.not(user_avatars: { id: nil }).where(user_avatars: { is_active: true}).where(user_avatars: { order: 0}).where("last_active > ?", Time.now-14.days)
    same_venue_users = self.additional_filter(same_venue_users, gender, min_age, max_age, min_distance, max_distance, everyone).sort_by{ |hsh| hsh.last_active }.reverse

    different_venue_users = User.includes(:user_avatars).where.not(id: black_list).where(id: different_venue_user_ids).where("exclusive is ? OR exclusive = ?", nil, false).where.not(user_avatars: { id: nil }).where(user_avatars: { is_active: true}).where(user_avatars: { order: 0})
    different_venue_users = self.additional_filter(different_venue_users, gender, min_age, max_age, min_distance, max_distance, everyone).sort_by{ |hsh| hsh.last_active }.reverse
    time_4  = Time.now
    if everyone
      all_users = same_venue_users + (all_users - same_venue_users)
    else
      all_users = same_venue_users + different_venue_users
    end
    time_5 = Time.now

    puts "All TT"
    puts (time_2-time_1).inspect
    puts "Venue id TT"
    puts (time_3-time_2).inspect
    puts "Venue users TT"
    puts (time_4-time_3).inspect
    puts "Everyone TT"
    puts (time_5-time_4).inspect

    puts "Total TT"
    puts (time_5-time_1).inspect

    return all_users
  end


############################################ API V 2 ############################################


  # API V2
  # CORE function to gather ppl, all parameters from controller
  # 
  #     @params:
  # 
  #         - gate_number (integer, minimum number of users people can see before filter)
  #         - gender ("M", "F", or "A", default: "A")
  #         - min_age (integer for minimum age, default: ignore this filter)
  #         - max_age (integer for maximum age, default: ignore this filter)
  #         - min_distance (integer for minimum distance, default: 0)
  #         - max_distance (integer for maximum distance, default: 60)
  #         - everyone (true or false, default: true)
  #         - venue_id (not used anymore, might be used in the future)
  #         - page_number (integer for pagination)
  #         - users_per_page (integer for pagination)

  def people_list_2_0(gate_number, gender, min_age, max_age, venue_id, min_distance, max_distance, everyone, page_number, users_per_page)
    diff_1 = 0
    diff_2 = 0
    result = Hash.new
    # check 
    # if ActiveInVenueNetwork.joins(:user).where('users.is_connected' => true).count >= gate_number
    all_users = self.collect_users('A', 0, 100, nil, 0, 60, true)
    number_of_users = all_users.length + 1
    if number_of_users >= gate_number  
      # ADD Pagination
      s_time = Time.now
      # collect all whispers sent 
      # TODO: use model to do it
      whispers_sent = WhisperNotification.collect_whispers(self)
      whispers_can_reply = WhisperNotification.collect_whispers_can_reply(self)
      whispers_can_accept_delete = WhisperNotification.collect_whispers_can_accept_delete(self)
      pending_whispers = WhisperToday.pending_whispers(self.id)
      # colect all users with "like"
      # followees = self.followees(User)
      # collect all friends with mutual like AND whisper accepted friends
      # mutual_follow = self.friends_by_like
      # whisper_friends = FriendByWhisper.friends(self.id)
      # friends = mutual_follow | whisper_friends

      # get all users with filter params
      return_users = self.collect_users(gender, min_age, max_age, venue_id, min_distance, max_distance, everyone)
      if !page_number.nil? and !users_per_page.nil? and users_per_page > 0 and page_number >= 0
        pagination = Hash.new
        pagination['page'] = page_number - 1
        pagination['per_page'] = users_per_page
        pagination['total_count'] = return_users.length
        result['pagination'] = pagination
        return_users = Kaminari.paginate_array(return_users).page(page_number).per(users_per_page) if !return_users.nil?
      end
      if self.current_venue.blank?
        same_venue_user_ids = Array.new
      else
        same_venue_user_ids = ActiveInVenue.where(:venue_id => self.current_venue.id).map(&:user_id)
      end

      campus_id = VenueType.find_by_name("Campus")
      if campus_id
        campus_venue_ids = Venue.where(venue_type_id: campus_id.id.to_s).map(&:id)
      else
        campus_venue_ids = [nil]
      end
      if self.current_venue.blank?
        different_venue_user_ids = ActiveInVenue.where.not(:venue_id => campus_venue_ids).map(&:user_id)
      else
        campus_venue_ids << self.current_venue.id
        different_venue_user_ids = ActiveInVenue.where.not(:venue_id => campus_venue_ids).map(&:user_id)
      end

      # build json format
      time_j_s = Time.now

      users = Jbuilder.encode do |json|
        same_venue_time = 0
        different_venue_time = 0
        check_badge_time = 0
        time_avatar = 0
        actions_time = 0
        whispers_time = 0
        json.array! return_users do |user|
          if user.id != self.id
            next unless user.user_avatars.present?
            next unless user.main_avatar.present?
            time_avatar_a = Time.now
            other_avatars = user.user_avatars.where(is_active:true).order(:order)
            avatar_array = Array.new

            if other_avatars.count > 0
              other_avatars.each do |oa|
                new_item = {
                  avatar: !oa.avatar.nil? ? oa.origin_url : '',
                  thumbnail: !oa.avatar.nil? ? oa.thumb_url : '',
                  avatar_id: oa.id,
                  # default: oa.order.nil? ? true : (oa.order==0),
                  # is_active: true,
                  order: oa.order.nil? ? '100' : oa.order
                }
                avatar_array << new_item
              end
            end

            json.avatars avatar_array
            time_avatar_b = Time.now
            time_avatar += (time_avatar_b - time_avatar_a)

            actions_time_a = Time.now
            json.whisper_sent whispers_sent.include? user.id.to_i
            # are_friends = (friends.map(&:id).include? user.id)
            whisper_sent = (whispers_sent.include? user.id.to_i)
            can_reply = (whispers_can_reply.include?  user.id.to_i)
            can_accept_delete = (whispers_can_accept_delete.include?  user.id.to_i)
            actions = self.collect_whisper_actions(false, can_reply, can_accept_delete, whisper_sent, user, pending_whispers)
            json.actions actions
            actions_time_b = Time.now
            actions_time += (actions_time_b - actions_time_a)
            
            whispers_time_a = Time.now
            whisper_hash = self.collect_whisper_message_history(user, actions)
            if !whisper_hash['whisper_id'].nil?
                json.whisper_id whisper_hash['whisper_id']
            end
            if !whisper_hash['messages_array'].nil?
                json.messages_array whisper_hash['messages_array']
            end
            whispers_time_b = Time.now
            whispers_time += (whispers_time_b - whispers_time_a)
            

            # if followees.blank?
            #   json.like false
            # else
            #   json.like followees.map(&:id).include? user.id
            # end

            # if friends.blank?
            #   json.friend false
            # else
            #   json.friend friends.map(&:id).include? user.id
            # end

            

            json.same_venue_badge          same_venue_user_ids.include? user.id

            json.different_venue_badge          different_venue_user_ids.include? user.id

            json.venue_type          (user.current_venue.nil? or user.current_venue.venue_type.nil? or user.current_venue.venue_type.name.nil?) ? '' : user.current_venue.venue_type.name
            

            json.id             user.id
            json.first_name     user.first_name
            json.username     user.username
            json.birthday       user.birthday
            json.gender         user.gender
            json.last_active    user.last_active.nil? ? 0 : user.last_active.to_i 
            # json.last_status_active_time    user.last_status_active_time.nil? ? 0 : user.last_status_active_time.to_i 
            json.line_id      user.line_id.blank? ? '' : user.line_id
            json.wechat_id      user.wechat_id.blank? ? '' : user.wechat_id
            json.snapchat_id    user.snapchat_id.blank? ? '' : user.snapchat_id
            json.instagram_id   user.instagram_id.blank? ? '' : user.instagram_id
            json.spotify_id   user.spotify_id.blank? ? '' : user.spotify_id

            json.latitude       user.latitude  
            json.longitude      user.longitude 
            json.introduction_1 user.introduction_1.blank? ? '' : user.introduction_1
            json.status user.introduction_2.blank? ? '' : user.introduction_2
            json.exclusive      user.exclusive
          end
        end
        puts "The avatar time is: "
        puts time_avatar.inspect

        puts "The actions time is: "
        puts actions_time.inspect

        puts "The whisper time is: "
        puts whispers_time.inspect
      end

      users = JSON.parse(users).delete_if(&:empty?)
      time_j_e = Time.now
      # TODO: Move to db level to improve performance
        # different_venue_users = [] # Make a empty array for users in the different venue
        # same_venue_users = [] #Make a empty array for users in the same venue
        # no_badge_users = [] # Make an empty array for no badge users
        # users.each do |u| # Go through the users
        #   if !!u['exclusive'] == true
        #     if u['same_venue_badge'].to_s == "true"
        #        same_venue_users << u # Throw the user into the array
        #     end
        #   else
        #     if !!u['exclusive'] == false
        #       if u['different_venue_badge'].to_s == "true" #If the users' same beacon field is true
        #         different_venue_users << u # Throw the user into the array
        #       elsif u['same_venue_badge'].to_s == "true" #If the users' same venue field is true
        #         same_venue_users << u # Throw the user into the array
        #       elsif everyone
        #         different_venue_users << u # Users who are not in a venue also thrown into here.
        #       end
        #     end
        #   end
        # end
        
        # # users = users - same_beacon_users - same_venue_users # Split out the users such that users only contain those that are not in the same venue or same beacon
        # puts "count A"
        # puts users.count
        # users = (same_venue_users.sort_by{ |hsh| hsh['last_active'] }.reverse) + (different_venue_users.sort_by{ |hsh| hsh['last_active'] }.reverse)  #Sort users by activity
        # puts "count B"
        # puts users.count
      # ADD Pagination
      

      


      e_time = Time.now
      runtime = time_j_e - time_j_s
      puts "The json time is: "
      puts runtime.inspect

      runtime = e_time - s_time
      puts "The runtime is: "
      puts runtime.inspect

      # count = users.count
      result['users'] = users
      puts "USERS RESULT:"
      puts users.count
    else
      # count = ActiveInVenueNetwork.joins(:user).where('users.is_connected' => true).count
      count = number_of_users
      users = Array.new
      result['percentage'] = (count * 100 / gate_number).to_i
    end
    # puts "USERS RESULT:"
    # puts result.inspect
    return result
  end


  def self.authenticate_v2(token)
    if Rails.env == 'development' or Rails.env == 'test'
      secret = 'secret'
    else
      secret = ENV['SECRET_KEY_BASE']
    end
    if token.blank?
      error_obj = {
        code: 499,
        message: "Token required"
      }
      result = {'success' => false, 'error_data' => error_obj}
      return result
    else
      token = token.split(' ').last
      begin
        token_info = JWT.decode(token, secret)
        if token_info.nil? or token_info.empty? or token_info.first.nil?
          error_obj = {
            code: 497,
            message: "Token Invalid"
          }
          result = {'success' => false, 'error_data' => error_obj}
          return result
        else
          user_info = token_info.first
          user_id = user_info['id']
          if user_id.nil?
            error_obj = {
              code: 497,
              message: "Token Invalid"
            }
            result = {'success' => false, 'error_data' => error_obj}
            return result
          else
            user = User.find_by_id(user_id.to_i)
            if user.nil?
              error_obj = {
                code: 497,
                message: "Token Invalid"
              }
              result = {'success' => false, 'error_data' => error_obj}
              return result
            else
              user.last_active = Time.now + 1.second
              user.version = "2.0"
              user.save!
              # user.update(last_active: Time.now+1.second)
              result = {'success' => true}
              return result
            end
          end
        end

      rescue JWT::ExpiredSignature
        error_obj = {
          code: 497,
          message: "Token Expired"
        }
        result = {'success' => false, 'error_data' => error_obj}
        return result
      rescue JWT::DecodeError
        error_obj = {
          code: 497,
          message: "Token Invalid"
        }
        result = {'success' => false, 'error_data' => error_obj}
        return result
      end
    end
  end

  def pusher_private_online
    self.update(pusher_private_online: true)
  end

  def pusher_private_offline
    self.update(pusher_private_online: false)
  end

  def pusher_delete_photo_event
    channel = "private-user-"+self.id.to_s
    data = self.user_avatar_object
    event = "Delete photo"
    Pusher.trigger(channel, event, {data: data})
  end

end
