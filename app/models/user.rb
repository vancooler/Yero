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
    user_avatars.find_by(default: true)
  end

  # Checks if you are in the same venue as the other person
  def same_venue_as?(user_id)
    if fellow_participant = User.find(user_id)
      
      fellow_participant_venue = fellow_participant.current_venue
      self_venue = self.current_venue

      return false if fellow_participant_venue.nil? || self_venue.nil?

      self.current_venue.id == fellow_participant.current_venue.id
    else
      false
    end
  end

  # Checks if you are in a different venue as the other person
  def different_venue_as?(user_id)
    if fellow_participant = User.find(user_id)
      
      fellow_participant_venue = fellow_participant.current_venue
      self_venue = self.current_venue

      if !fellow_participant_venue.nil? && self_venue.nil?
        return true
      elsif !fellow_participant_venue.nil? && !self_venue.nil?
        if self.current_venue.id != fellow_participant.current_venue.id
          return true
        end
      end
      false
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
    user_avatars.where.not(default: true)
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
    users = User.includes(:user_avatars).where(is_connected: true).where.not(user_avatars: { id: nil }).where(user_avatars: { is_active: true}).where(user_avatars: { default: true}).near(self, max_distance, :units => :km)

    if !gender.nil? || gender != "A"
      if gender == "M" or gender == "F"
        users = users.where(:gender => gender) #Filter by gender
      end
    end
    if !max_age.nil? 
      users = users.where("birthday >= ?", (max_age + 1).years.ago + 1.day) #Filter by max age
    end
    if !min_age.nil? and min_age > 0
      users = users.where("birthday <= ?", (min_age + 1).years.ago) # Filter by min age
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
    self.user_avatars.where(default: true).first
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
      json.snapchat_id snapchat_id
      json.instagram_id instagram_id
      json.wechat_id wechat_id
      json.discovery discovery
      json.exclusive exclusive

      json.avatars do
        avatars = self.user_avatars.all

        json.array! avatars do |a|
          json.avatar a.avatar.thumb.url
          json.default a.default
          json.avatar_id a.id
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

  # This code for usage with a CRON job. Currently done using Heroku Scheduler
  def self.network_open
    times_result = TimeZonePlace.select(:timezone) #Grab all the timezones in db
    times_array = Array.new # Make a new array to hold the times that are at 5:00pm
    times_result.each do |timezone| # Check each timezone
      Time.zone = timezone["timezone"] # Assign timezone
      int_time = Time.zone.now.strftime("%H%M").to_i
      if int_time >= 1700 and int_time < 1709 # If time is 17:00 ~ 17:09
        open_network_tz = [Time.zone.name.to_s] #format it
        times_array << open_network_tz #Throw into array
      end
    end
    puts times_array
    people_array = Array.new 
    times_array << ["America/Vancouver"] if times_array.include? ["America/Los_Angeles"]
    times_array.each do |timezone| #Each timezone that we found to be at 17:00
      usersInTimezone = UserLocation.find_by_dynamodb_timezone(timezone[0]) #Find users of that timezone
      
      if !usersInTimezone.nil? # If there are people in that timezone
        usersInTimezone.each do |user|
          attributes = user.attributes.to_h # Turn the people into usable attributes
          if !attributes["user_id"].nil?
            people_array << attributes["user_id"].to_i #Assign new attributes
          end  
        end
      end 
    end

    people_array.each_slice(25) do |people_group|
      batch = AWS::DynamoDB::BatchWrite.new
      notification_array = Array.new
      people_group.each do |person|
        if !person.blank?
          request = Hash.new()
          request["target_id"] = person.to_s
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
          # TODO: use job queue?
          WhisperNotification.send_nightopen_notification(person.to_i)  
        end
      end
      if notification_array.count > 0
        batch.put('WhisperNotification', notification_array)
        batch.process!
      end
    end
  end

  # This code for usage with a CRON job. Currently done using Heroku Scheduler
  def self.network_close
    times_result = TimeZonePlace.select(:timezone) #Grab all the timezones in db
    times_array = Array.new # Make a new array to hold the times that are at 5:00pm
    times_result.each do |timezone| # Check each timezone
      Time.zone = timezone["timezone"] # Assign timezone
      int_time = Time.zone.now.strftime("%H%M").to_i
      if int_time >= 500 and int_time < 509 # If time is 5:00 ~ 5:09
        open_network_tz = [Time.zone.name.to_s] #format it
        times_array << open_network_tz #Throw into array
      end
    end
    puts times_array
    people_array = Array.new 
    times_array << ["America/Vancouver"] if times_array.include? ["America/Los_Angeles"]
    times_array.each do |timezone| #Each timezone that we found to be at 17:00
      usersInTimezone = UserLocation.find_by_dynamodb_timezone(timezone[0]) #Find users of that timezone
      
      if !usersInTimezone.nil? # If there are people in that timezone
        usersInTimezone.each do |user|
          attributes = user.attributes.to_h # Turn the people into usable attributes
          if !attributes["user_id"].nil?
            people_array << attributes["user_id"].to_i #Assign new attributes
          end  
        end
      end 
    end

    User.where(id: people_array).update_all(is_connected: false)
  end


  def people_list(gate_number, gender, min_age, max_age, venue_id, min_distance, max_distance, everyone, page_number, users_per_page)
    diff_1 = 0
    diff_2 = 0
    result = Hash.new
    if ActiveInVenueNetwork.joins(:user).where('users.is_connected' => true).count >= gate_number
      s_time = Time.now
      collected_whispers = WhisperNotification.collect_whispers(self)
      return_users = self.fellow_participants(gender, min_age, max_age, venue_id, min_distance, max_distance, everyone)
      
      users = Jbuilder.encode do |json|
        retus = Time.now

        reten = Time.now
        dbtime = reten-retus
        
        json_s = Time.now
        json.array! return_users do |user|
          if user.id != self.id
            next unless user.user_avatars.present?
            next unless user.main_avatar.present?
            main_avatar   =  user.user_avatars.find_by(default:true)
            other_avatars =  user.user_avatars.where.not(default:true)
            avatar_array = Array.new
            avatar_array[0] = {
                  thumbnail: main_avatar.nil? ? '' : main_avatar.avatar.thumb.url,
                }
            avatar_array[1] = {
                  avatar: main_avatar.nil? ? '' : main_avatar.avatar.url,
                  avatar_id: main_avatar.nil? ? '' : main_avatar.id,
                  default: true
                }
            if other_avatars.count > 0
              avatar_array[2] = {
                    avatar: other_avatars.count > 0 ? other_avatars.first.avatar.url : '',
                    avatar_id: other_avatars.count > 0 ? other_avatars.first.id : '',
                    default: false
                  }
              if other_avatars.count > 1
                avatar_array[3] = {
                      avatar: other_avatars.count > 1 ? other_avatars.last.avatar.url : '',
                      avatar_id: other_avatars.count > 1 ? other_avatars.last.id : '',
                      default: false
                    }
              end
            end
            json.avatars do |a|
              json.array! avatar_array do |avatar|
                a.avatar      avatar[:avatar]    if !avatar[:avatar].nil?
                a.thumbnail   avatar[:thumbnail] if !avatar[:thumbnail].nil?
                a.avatar_id   avatar[:avatar_id] if !avatar[:avatar_id].nil?
                a.default     avatar[:default]   if !avatar[:default].nil?
              end
            end

            collected_whispers.each do |cwid|
              if cwid.to_s == user.id.to_s
                json.whisper_sent true
              end
            end
            start_time = Time.now
            # json.whisper_sent WhisperNotification.whisper_sent(self, user) #Returns a boolean of whether a whisper was sent between this user and target user
            end_time = Time.now
            diff_1 += (end_time - start_time)
            json.same_venue_badge          self.same_venue_as?(user.id) # Returns a boolean of whether you're in the same venue as the other person.
            json.different_venue_badge     self.different_venue_as?(user.id)
            json.same_beacon               self.same_beacon_as?(user.id) # Returns a boolean of whether you're in the same venue as the other person.
            json.id             user.id
            json.first_name     user.first_name
            json.key            user.key
            json.since_1970     (user.last_active - Time.new('1970')).seconds.to_i
            json.birthday       user.birthday
            # json.gender         user.gender
            # json.distance       self.distance_label(user) # Returns a label such as "Within 2 km"
            json.wechat_id      user.wechat_id
            json.snapchat_id    user.snapchat_id
            json.instagram_id   user.instagram_id
            json.apn_token      user.apn_token
            json.latitude       user.latitude  
            json.longitude      user.longitude 
            json.introduction_1 user.introduction_1.blank? ? nil : user.introduction_1
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
            else 
              different_venue_users << u # Users who are not in a venue also thrown into here.
            end
          end
        end
      end
      
      # users = users - same_beacon_users - same_venue_users # Split out the users such that users only contain those that are not in the same venue or same beacon
      
      users = same_venue_users.sort_by { |hsh| hsh[:actual_distance] } + different_venue_users.sort_by { |hsh| hsh[:actual_distance] }  #Sort users by distance
      # ADD Pagination
      if !page_number.nil? and !users_per_page.nil?
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
      count = ActiveInVenueNetwork.joins(:user).where('users.is_connected' => true).count
      users = Array.new
      result['percentage'] = (count * 100 / gate_number).to_i
    end
    return result
  end

  def viewed_by_sender(whispers)
    result = true
    dynamo_db = AWS::DynamoDB.new
    table = dynamo_db.tables['WhisperNotification']
    table.load_schema
    puts "Read time: "

    items = table.items.where(:id).in(*whispers).where(:notification_type).not_equal_to("0")
    
    items.each_slice(25) do |whisper_group|
      batch = AWS::DynamoDB::BatchWrite.new
      notification_array = Array.new
      whisper_group.each do |w|
        if !w.blank?
          attributes = w.attributes.to_h
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
          request["viewed"] = 1
          request["not_viewed_by_sender"] = 0
          notification_array << request 
        end
      end
      if notification_array.count > 0
        batch.put('WhisperNotification', notification_array)
        batch.process!
      end
    end

    return result
  end

end
