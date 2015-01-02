class User < ActiveRecord::Base
  has_many :traffics
  has_many :winners
  has_many :pokes, foreign_key: "pokee_id"
  has_many :favourite_venues
  has_many :venues, through: :favourite_venues
  has_many :user_avatars
  accepts_nested_attributes_for :user_avatars
  has_one  :participant
  has_many :activities, dependent: :destroy
  has_many :locations
  has_one :read_notification, dependent: :destroy
  has_one :active_in_venue, dependent: :destroy
  has_one :active_in_venue_network, dependent: :destroy

  reverse_geocoded_by :latitude, :longitude

  # mount_uploader :avatar, AvatarUploader
  before_save   :update_activity

  validates :birthday, :first_name, :gender, presence: true

  scope :sort_by_last_active, -> { 
    where.not(last_active: nil).
    order("last_active desc") 
  }

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

      if !fellow_participant_venue.nil? && !self_venue.nil?
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
=begin
    venue_activities = []

    Venue.all.each do |venue|
      venue_activities << Activity.at_venue_tonight(venue.id)
    end
    venue_activities.flatten!
    
    active_users_id = []

    activities_grouped_by_user_ids = venue_activities.group_by { |a| a[:user_id] }
    activities_grouped_by_user_ids.delete(self.id) #remove current_user id from the list
    activities_grouped_by_user_ids.each do |id_activity|
      ordered_user_activity = id_activity[1].sort_by!{|t| t[:created_at]}
      if ordered_user_activity.last.action == "Enter Beacon"
        qualified = true
      elsif ordered_user_activity.last.action == "Exit Beacon"
        qualified = false
      # todo
      # elsif exit && before timeout 
      else
        qualified = false
      end
      active_users_id << id_activity[0] if qualified
    end
=end
    users = User.where(id: active_users_id) #Find all the users with the id's in the array.
    if !gender.nil? || gender != "A"
      if gender.downcase == "male" or gender.downcase == "female" or gender == "M" or gender == "F"
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
    puts "In the user.rb"
    puts active_users_id.inspect
    
    puts active_users_id.inspect
    # users = User.where(id: active_users_id)
    return users
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

  def actual_distance(user)
    distance = self.distance_from([user.latitude,user.longitude]) * 1.609344
    return distance
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

  def to_json(with_key)
    data = Jbuilder.encode do |json|
      json.id id
      json.birthday birthday
      json.first_name first_name
      json.gender gender
      json.email email
      json.snapchat_id snapchat_id
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
end
