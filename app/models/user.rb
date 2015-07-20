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

  # Like feature
  acts_as_follower
  acts_as_followable


  reverse_geocoded_by :latitude, :longitude

  # mount_uploader :avatar, AvatarUploader
  before_save   :update_activity

  validates :email, :birthday, :first_name, :gender, presence: true

  scope :sort_by_last_active, -> { 
    where.not(last_active: nil).
    order("last_active desc") 
  }
  has_secure_password

  def main_avatar
    user_avatars.find_by(order: 0)
  end

  # Checks if you are in the same venue as the other person
  def same_venue_as?(user_id)
    if User.exists? id: user_id 
      fellow_participant = User.find(user_id)
      
      fellow_participant_venue = fellow_participant.current_venue
      self_venue = self.current_venue

      return false if fellow_participant_venue.nil? || self_venue.nil?

      return self.current_venue.id == fellow_participant.current_venue.id

    else
      false
    end
  end

  # Checks if you are in a different venue as the other person
  def different_venue_as?(user_id)
    if User.exists? id: user_id 
      fellow_participant = User.find(user_id)
      
      fellow_participant_venue = fellow_participant.current_venue
      self_venue = self.current_venue

      if fellow_participant_venue.nil? or fellow_participant_venue.venue_type.nil? or fellow_participant_venue.venue_type.name.nil? or fellow_participant_venue.venue_type.name.include? "Campus" 
          # fellow not in venue or in campus
          return false
      elsif !fellow_participant_venue.nil? and !self_venue.nil? and !self_venue.venue_type.nil? and !self_venue.venue_type.name.nil? and !(self_venue.venue_type.name.include? "Campus") and self_venue.id == fellow_participant_venue.id
          # in a same non-campus venue as fellow
          return false
      else
          # other situation
          return true
      end
    else
      false
    end
  end


  ##########################################################################
  #
  # Check whether a user is in the same beacon as the current user
  #
  ##########################################################################
  def same_beacon_as?(user_id)
    if fellow_participant = User.find(user_id)
      
      fellow_participant_beacon = fellow_participant.current_beacon
      self_beacon = self.current_beacon

      return false if fellow_participant_beacon.nil? || self_beacon.nil?

      self.current_beacon.id == fellow_participant.current_beacon.id
    else
      false
    end
  end

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
  def has_activity_today?
    #self.activities.on_current_day.count > 0
    !self.active_in_venue.nil?
  end
  def fellow_participants(gender, min_age, max_age, venue_id, min_distance, max_distance, everyone)
    current_venue = self.current_venue
    current_venue_network = self.current_venue_network
    # return nil if current_venue.nil? and current_venue_network.nil?
    if everyone # everyone will search the network if the option is true
      aivs = ActiveInVenueNetwork.where("user_id != ?", self.id)
    else # else we will just search the people in the venue
      aivs = ActiveInVenue.where("user_id != ?", self.id) # Give me all the users that are out that are not me.
      aivn = ActiveInVenueNetwork.where("user_id != ?", self.id)
      if !venue_id.nil? #If a parameter was passed in for venue_id
        aivs = aivs.where(:venue_id => venue_id) #Search for all people active in that particular venue
      end
    end
    active_users_id = [] # Make empty array.
    aivs.each do |aiv| 
      active_users_id << aiv.user_id #Toss into the array the user_id's of the people that are out or in a particular venue.
    end
    if aivn # If there are people acitve in venue network
      aivn.each do |aivn| # Loop
        if active_users_id.include? aivn.user_id
        else
          active_users_id << aivn.user_id # Throw each one into the array
        end
      end
    end

    # users = User.where(id: active_users_id) #Find all the users with the id's in the array.
    max_distance = max_distance.blank? ? 20 : max_distance+1 # Do max_distance+1 to include distance ranges (i.e. 9-10km, people 10km are included)
    # only return users with avatar near current user 
    # users = User.includes(:user_avatars).where.not(user_avatars: { id: nil }).where(user_avatars: { is_active: true}).where(user_avatars: { default: true}).near(self, max_distance, :units => :km)
    # filter for is_connected 
    users = User.includes(:user_avatars).where.not(id: self.id).where(is_connected: true).where.not(user_avatars: { id: nil }).where(user_avatars: { is_active: true}).where(user_avatars: { order: 0}).near(self, max_distance, :units => :km)
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
    self.user_sort(users, min_distance, max_distance) #Returns the users filtered
  end

  def whisper_friends
    active_users_id = WhisperNotification.find_friends(self.id)
  end

  def whisper_venue
    venue = WhisperNotification.system_notification(self.id)
    return venue
  end

  def fellow_participants_sorted #by distance then by activity
    results = self.fellow_participants
    results_with_location = results.where.not(latitude:nil, longitude:nil)
    results_with_no_location = results - results_with_location
    results = results.near(self, 50, unit: :km).sort_by_last_active
    results_with_no_location = results_with_no_location.
    sorted_results = results_with_location + results_with_no_location
  end

  ##########################################################################
  #
  # Sort the users in same beacon in random order
  #
  ##########################################################################
  def same_beacon_users(users)
    users.each do |u|
      if !self.same_beacon_as?(u.id)
        users.reject{|user| user.id == u.id}
      end
    end
    users = users.shuffle
    return users
  end

  ##########################################################################
  #
  # Sort the users in same venue in random order
  #
  ##########################################################################
  def same_venue_users(users)
    users.each do |u|
      if !self.same_venue_as?(u.id)
        users.reject{|user| user.id == u.id}
      end
    end
    users = users.shuffle
    return users
  end

  ##########################################################################
  #
  # Sort the users list by same beacon, same venue, distance and random
  #
  ##########################################################################
  def user_sort(users, min_distance, max_distance)
    
    result_users = users.near(self, max_distance, :units => :km).order('distance DESC')
    if min_distance != 0
      remove_users = users.near(self, min_distance, :units => :km).order('distance DESC')
      result_users = result_users.reject{|user| remove_users.include? user}
    end
       
    return result_users
  end

  def distance_label(user)
    if user.latitude.nil? or user .longitude.nil?
      return "More than 60km"
    else
      distance = self.distance_from([user.latitude,user.longitude]) * 1.609344
      case distance 
      when 0..2    
        return "Within 2km" 
      when 2..5    
        return "Within 5km" 
      when 5..10    
        return "Within 10km" 
      when 10..20    
        return "Within 20km" 
      when 20..40    
        return "Within 40km" 
      when 40..61    
        return "Within 60km" 
      else
        return "More than 60km"
      end
    end
  end

  def actual_distance(user)
    if user.latitude.nil? or user .longitude.nil?
      return 10000
    else
      distance = self.distance_from([user.latitude,user.longitude]) * 1.609344
      return distance
    end
  end

  def last_activity
    self.activities.last
  end

  def venue_network
    if self.participant
      self.participant.room.venue.venue_network
    end
  end

  def default_avatar
    self.user_avatars.where(order: 0).first
  end

  def age
    dob = self.birthday
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def name
    first_name + ' (' + id.to_s + ')'
  end

  def to_json(with_key)
    data = Jbuilder.encode do |json|
      json.id id
      json.birthday birthday
      json.first_name first_name
      json.gender gender
      json.email email
      json.snapchat_id (snapchat_id.blank? ? '' : snapchat_id)
      json.instagram_id (instagram_id.blank? ? '' : instagram_id)
      json.wechat_id (wechat_id.blank? ? '' : wechat_id)
      json.line_id (line_id.blank? ? '' : line_id)
      json.introduction_1 (introduction_1.blank? ? '' : introduction_1)
      json.discovery discovery
      json.exclusive exclusive
      json.joined_today is_connected

      json.avatars do
        avatars = self.user_avatars.where(is_active: true).order(:order)

        json.array! avatars do |a|

          json.avatar a.avatar.url
          json.thumbnail a.avatar.thumb.url
          json.default (!a.order.nil? and a.order == 0)
          json.is_active a.is_active
          json.avatar_id a.id
          json.order (a.order.nil? ? 100 : a.order)

        end
      end

      json.notification_preferences do
        preferences = NotificationPreference.all
        json.array! preferences do |p|
          json.type p.name
          json.disabled (p.user_notification_preference.where(:user_id => self.id).blank? ? false : true)
        end
      end

      if with_key
        json.key key
      end
    end

    JSON.parse(data)
  end

  # keeps track of the latest activity of a user
  def update_activity
    self.last_activity = Time.now
  end

  def send_network_open_notification
    WhisperNotification.send_nightopen_notification(self.id) 
  end

  # This code for usage with a CRON job. Currently done using Heroku Scheduler
  def self.network_open
    time1 = Time.now

    times_result = TimeZonePlace.select(:timezone) #Grab all the timezones in db
    times_array = Array.new # Make a new array to hold the times that are at 5:00pm
    times_result.each do |timezone| # Check each timezone
      Time.zone = timezone["timezone"] # Assign timezone
      int_time = Time.zone.now.strftime("%H%M").to_i
      if int_time >= 1700 and int_time < 1710 # If time is 17:00 ~ 17:09
        open_network_tz = Time.zone.name.to_s #format it
        times_array << open_network_tz #Throw into array
      end
    end

    time2 = Time.now
    dbtime = time2 - time1
    puts "runtime2: "
    puts dbtime.inspect

    if !times_array.empty?
      user_ids = UserLocation.find_by_dynamodb_timezone(times_array, false) #Find users of that timezone
    end
    # usersInTimezone = UserLocation.find_by_dynamodb_timezone(times_array, false) #Find users of that timezone


    # user_ids = Array.new
    # if !usersInTimezone.nil? # If there are people in that timezone
    #   usersInTimezone.each do |user|
    #     attributes = user.attributes.to_h # Turn the people into usable attributes
    #     if !attributes["user_id"].nil? 
    #       user_ids << attributes["user_id"].to_i

    #     end  
    #   end
    # end 

    time3 = Time.now
    dbtime = time3 - time2
    puts "runtime3: "
    puts dbtime.inspect
    
    if !user_ids.nil? and user_ids.length > 0
      users = User.where(id: user_ids)
    end


    if !users.nil? and users.length > 0
      people_array = Array.new 
      users.each do |tmp_user|
        user_hash = Hash.new
        user_hash['id'] = tmp_user.id
        user_hash['token'] = tmp_user.apn_token
        user_hash['updated_at'] = tmp_user.updated_at
        people_array << user_hash
      end
    end

    time4 = Time.now
    dbtime = time4 - time3
    puts "runtime4s: "
    puts dbtime.inspect

    # remove duplicated apn_tokens
    if !people_array.nil? and people_array.length > 0
      people_array = people_array.group_by { |x| x['token'] }.map {|x,y|y.max_by {|x|x['updated_at']}}

      people_array.each_slice(25) do |people_group|
        batch = AWS::DynamoDB::BatchWrite.new
        notification_array = Array.new
        people_group.each do |person|
          if !person.blank?
            request = Hash.new()
            request["target_id"] = person['id'].to_s
            request["timestamp"] = Time.now.to_i
            request["origin_id"] = '0'
            request["created_date"] = Date.today.to_s
            request["venue_id"] = '0'
            request["notification_type"] = '0'
            request["intro"] = "Yero is now online. Connect to your city's network."
            request["viewed"] = 0
            request["not_viewed_by_sender"] = 1
            request["accepted"] = 0
            notification_array << request

            user = User.find(person['id'].to_i)
            if UserNotificationPreference.no_preference_record_found(user, "Network online")
              user.delay.send_network_open_notification
            end
          end
        end
        if notification_array.count > 0
          table_name = WhisperNotification.table_prefix + 'WhisperNotification'
          batch.put(table_name, notification_array)
          batch.process!
        end
      end
    end
    time5 = Time.now
    dbtime = time5 - time4
    puts "runtime5: "
    puts dbtime.inspect

    puts "runtimeALL: "
    puts (time5 - time1).inspect
  end

  # This code for usage with a CRON job. Currently done using Heroku Scheduler
  def self.network_close
    time1 = Time.now
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
    puts "CLOSE Timezones:"
    puts times_array.inspect
    # disconnect all users
    people_array = Array.new 
    if !times_array.empty?    
      people_array = UserLocation.find_by_dynamodb_timezone(times_array, true) #Find users of that timezone
    end
    puts "CLOSE People:"
    puts people_array.inspect
    if !people_array.empty? 
      User.where(id: people_array).update_all(is_connected: false, enough_user_notification_sent_tonight: false) # disconnect users
      # expire all whispers with type 2 of these users
      WhisperNotification.expire(people_array, '2')
      User.leave_activity(people_array)
    end
    # cleanup active_in_venue_network & active_in_venue & enter_today
    venue_networks = VenueNetwork.where(:timezone => times_array)
    venue_networks.each do |vn|
      ActiveInVenueNetwork.five_am_cleanup(vn)
    end
    puts "CLOSE Networks:"
    puts venue_networks.inspect
    time2 = Time.now
    puts "CLOSE runtimeALL: "
    puts (time2 - time1).inspect
  end

  def friends_by_like
    followees = self.followees(User)
    followers = self.followers(User)
    mutual_follow = followers & followees

    return mutual_follow
  end

  # find friends built by accepting whisper
  def friends_by_whisper    
    dynamo_db = AWS::DynamoDB.new # Make an AWS DynamoDB object
    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    table = dynamo_db.tables[table_name] # Choose the table
    table.load_schema 

    friends_accepted = table.items.where(:origin_id).equals(self.id.to_s).where(:notification_type).equals("3").select(:target_id)
    friends_whispered = table.items.where(:target_id).equals(self.id.to_s).where(:notification_type).equals("3").select(:origin_id)

    first_friends_id_array = Array.new
    second_friends_id_array = Array.new

    if friends_accepted and friends_accepted.count > 0
      friends_accepted.each do |friend|
        attributes = friend.attributes
        friend_id = attributes['target_id'].to_i
        if first_friends_id_array.include? friend_id
          p 'in the array'
        else
          first_friends_id_array << friend_id
        end 
      end
    end

    if friends_whispered and friends_whispered.count > 0
      friends_whispered.each do |friend|      
        attributes = friend.attributes
        friend_id = attributes['origin_id'].to_i
        if second_friends_id_array.include? friend_id
          p 'in the array'
        else
          second_friends_id_array << friend_id 
        end 
      end
    end

    users = Array.new
    users = first_friends_id_array | second_friends_id_array
    return_users = Array.new
    return_users = User.where(:id => users)
    return return_users

  end

  def people_list(gate_number, gender, min_age, max_age, venue_id, min_distance, max_distance, everyone, page_number, users_per_page)
    diff_1 = 0
    diff_2 = 0
    result = Hash.new
    # check 
    # if ActiveInVenueNetwork.joins(:user).where('users.is_connected' => true).count >= gate_number
    all_users = self.fellow_participants(nil, 0, 100, nil, 0, 60, true)
    number_of_users = all_users.length
    if number_of_users >= gate_number  
      s_time = Time.now
      # collect all whispers sent 
      collected_whispers = WhisperNotification.collect_whispers(self)
      # colect all users with "like"
      followees = self.followees(User)
      # collect all friends with mutual like AND whisper accepted friends
      mutual_follow = self.friends_by_like
      whisper_friends = self.friends_by_whisper
      friends = mutual_follow | whisper_friends


      retus = Time.now
      # get all users with filter params
      return_users = self.fellow_participants(gender, min_age, max_age, venue_id, min_distance, max_distance, everyone)
      reten = Time.now
      dbtime = reten-retus

      # build json format
      users = Jbuilder.encode do |json|
        
        json_s = Time.now
        json.array! return_users do |user|
          if user.id != self.id
            next unless user.user_avatars.present?
            next unless user.main_avatar.present?
            user_avatar_object(self)
            main_avatar   =  user.user_avatars.where(order:0).where(is_active:true)
            other_avatars =  user.user_avatars.where.not(order:0).where(is_active:true).order(:order)
            avatar_array = Array.new

            avatar_array[0] = {
                  avatar: main_avatar.blank? ? '' : main_avatar.first.avatar.url,
                  thumbnail: main_avatar.blank? ? '' : main_avatar.first.avatar.thumb.url,
                  avatar_id: main_avatar.blank? ? '' : main_avatar.first.id,
                  default: true,
                  is_active: true,
                  order: main_avatar.first.order.nil? ? '100' : main_avatar.first.order
                }
            if other_avatars.count > 0
              other_avatars.each do |oa|
                new_item = {
                  avatar: !oa.avatar.nil? ? oa.avatar.url : '',
                  thumbnail: !oa.avatar.nil? ? oa.avatar.thumb.url : '',
                  avatar_id: oa.id,
                  default: false,
                  is_active: true,
                  order: oa.order.nil? ? '100' : oa.order
                }
                avatar_array << new_item
              end
            end
            json.avatars do |a|
              json.array! avatar_array do |avatar|
                a.avatar      avatar[:avatar]    if !avatar[:avatar].nil?
                a.thumbnail   avatar[:thumbnail] if !avatar[:thumbnail].nil?
                a.avatar_id   avatar[:avatar_id] if !avatar[:avatar_id].nil?
                a.default     avatar[:default]   if !avatar[:default].nil?
                a.is_active     avatar[:is_active]   if !avatar[:is_active].nil?
                a.order     avatar[:order]   if !avatar[:order].nil?
              end
            end

            sent = false
            collected_whispers.each do |cwid|
              if cwid.to_s == user.id.to_s
                json.whisper_sent true
                sent = true
              end
            end

            if !sent
              json.whisper_sent false
            end

            if followees.blank?
              json.like false
            else
              json.like followees.map(&:id).include? user.id
            end

            if friends.blank?
              json.mutual_like false
            else
              json.mutual_like friends.map(&:id).include? user.id
            end

            start_time = Time.now
            # json.whisper_sent WhisperNotification.whisper_sent(self, user) #Returns a boolean of whether a whisper was sent between this user and target user
            end_time = Time.now
            diff_1 += (end_time - start_time)
            json.same_venue_badge          self.same_venue_as?(user.id) # Returns a boolean of whether you're in the same venue as the other person.
            json.different_venue_badge     self.different_venue_as?(user.id)
            json.same_beacon               self.same_beacon_as?(user.id) # Returns a boolean of whether you're in the same venue as the other person.
            json.venue_type          (user.current_venue.nil? or user.current_venue.venue_type.nil? or user.current_venue.venue_type.name.nil?) ? '' : user.current_venue.venue_type.name
            json.id             user.id
            json.first_name     user.first_name
            # json.key            user.key
            json.since_1970     (user.last_active - Time.new('1970')).seconds.to_i
            json.birthday       user.birthday
            # json.gender         user.gender
            # json.distance       self.distance_label(user) # Returns a label such as "Within 2 km"
            json.line_id      user.line_id.blank? ? '' : user.line_id
            json.wechat_id      user.wechat_id.blank? ? '' : user.wechat_id
            json.snapchat_id    user.snapchat_id.blank? ? '' : user.snapchat_id
            json.instagram_id   user.instagram_id.blank? ? '' : user.instagram_id

            # json.apn_token      user.apn_token
            json.latitude       user.latitude  
            json.longitude      user.longitude 
            json.introduction_1 user.introduction_1.blank? ? '' : user.introduction_1
            json.exclusive      user.exclusive
          end
        end
        json_e = Time.now
        j_time = json_e-json_s
        puts "The dbtime is: "
        puts dbtime.inspect 
        p "Json time:"
        p j_time.inspect
      end
      users = JSON.parse(users).delete_if(&:empty?)
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
      
      users = same_venue_users.sort_by { |hsh| hsh[:actual_distance] } + different_venue_users.sort_by { |hsh| hsh[:actual_distance] }  #Sort users by distance
      # ADD Pagination
      if !page_number.nil? and !users_per_page.nil? and users_per_page > 0 and page_number >= 0
        users = Kaminari.paginate_array(users).page(page_number).per(users_per_page) if !users.nil?
      end

      final_time = Time.now
      # diff_2 = final_time - end_time
      e_time = Time.now
      runtime = e_time - s_time
      


      puts "The runtime is: "
      puts runtime.inspect
      logger.info "NEWTIME: " + diff_1.to_s 
      # count = users.count
      result['users'] = users
    else
      # count = ActiveInVenueNetwork.joins(:user).where('users.is_connected' => true).count
      count = number_of_users
      users = Array.new
      result['percentage'] = (count * 100 / gate_number).to_i
    end
    return result
  end

  def viewed_by_sender(whispers)
    result = true
    dynamo_db = AWS::DynamoDB.new
    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    table = dynamo_db.tables[table_name]
    table.load_schema
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


  def user_object(current_user)
    # target_user = User.find_by_id(user["target_user"]["id"].to_i)
    # user_info = self.to_json(false)
    # user_info['avatars'] = user_info['avatars'].sort_by { |hsh| hsh["order"] }
    # user_info["avatars"].each do |a|
    #   thumb = a['avatar']
    #   a['avatar'] = thumb.gsub! 'thumb_', ''
    # end


    user_object = {
      same_venue_badge:          current_user.same_venue_as?(self.id),
      different_venue_badge:     current_user.different_venue_as?(self.id) ,
      actual_distance:           current_user.actual_distance(self),
      id:             self.id,
      first_name:     self.first_name,
      last_active:    self.last_active,
      last_activity:  self.last_activity,
      since_1970:     (self.last_active - Time.new('1970')).seconds.to_i,
      gender:         self.gender,
      birthday:       (self.id != 0 ? self.birthday : ''),
      distance:       (self.id != 0 ? current_user.distance_label(self) : ''),
      created_at:     self.created_at,
      updated_at:     self.updated_at,
      avatars:         user_avatar_object(self),
      email:  self.email,
      instagram_id:  self.instagram_id.blank? ? '' : self.instagram_id,
      snapchat_id:  self.snapchat_id.blank? ? '' : self.snapchat_id,
      wechat_id:  self.wechat_id.blank? ? '' : self.wechat_id,
      line_id:  self.line_id.blank? ? '' : self.line_id,
      latitude:       self.latitude,
      longitude:      self.longitude,
      introduction_1: self.introduction_1.blank? ? '' : self.introduction_1
    }

    return user_object
  end

  def user_avatar_object(user)
    user_info = user.to_json(false)
    # user_info['avatars'] = user_info['avatars'].sort_by { |hsh| hsh["order"] }
    
    return user_info["avatars"]
  end


  def generate_token
    user = {:id => self.id, :exp => (Time.now.to_i + 3600*24) } # expire in 24 hours
    if Rails.env == 'development'
      secret = 'secret'
    else
      secret = ENV['SECRET_KEY_BASE']
    end
    token = JWT.encode(user, secret)

    return token
  end


  def join_network
    if self.is_connected == false
      self.is_connected = true
      self.save
      WhisperNotification.create_in_aws(self.id, nil, nil, "200", '')
    end
  end

  def leave_network
    self.is_connected = false
    self.save
  end

  def self.leave_activity(people_array)
    dynamo_db = AWS::DynamoDB.new
    table_name = WhisperNotification.table_prefix + 'WhisperNotification'
    table = dynamo_db.tables[table_name]
    table.load_schema

    people_array.each_slice(25) do |whisper_group|
      batch = AWS::DynamoDB::BatchWrite.new
      current_timestamp = Time.now.to_i
      notification_array = Array.new
      whisper_group.each do |w|
        if !w.blank?
          request = Hash.new()
          request["target_id"] = w.to_s
          request["timestamp"] = current_timestamp
          request["accepted"] = 0
          request["declined"] = 0
          request["id"] = "offline-"+w.to_s+"-"+current_timestamp.to_s + 
          request["notification_type"] = '201'
          request["viewed"] = 0
          notification_array << request 
        end
      end
      if notification_array.count > 0
        batch.put(table_name, notification_array)
        batch.process!
      end
    end
  end

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

  def force_users_join_to_test
    users = User.order("id DESC").limit(100) 
    users.update_all(is_connected: true)
  end
end
