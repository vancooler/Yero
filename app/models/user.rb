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

  def secondary_avatars
    user_avatars.where.not(default: true)
  end

  def current_venue
    return nil unless self.has_activity_today?
=begin
    activity = Activity.for_user(self.id).on_current_day.with_beacons.last
    if activity.action == "Enter Beacon"
      activity.trackable.room.venue
    else
      nil
    end
=end
    return self.active_in_venue.venue
  end
  def has_activity_today?
    #self.activities.on_current_day.count > 0
    !self.active_in_venue.nil?
  end
  def fellow_participants
    current_venue = self.current_venue
    #return nil if (current_venue == nil || self.activities.on_current_day.count == 0)
    return nil if current_venue.nil?
    aivs = ActiveInVenue.where("user_id != ?", self.id)
    active_users_id = []
    aivs.each do |aiv|
      active_users_id << aiv.user_id
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
    users = User.where(id: active_users_id)
    self.user_sort(users)
  end

  def fellow_participants_sorted #by distance then by activity
    results = self.fellow_participants
    results_with_location = results.where.not(latitude:nil, longitude:nil)
    results_with_no_location = results - results_with_location
    results = results.near(self, 50, unit: :km).sort_by_last_active
    results_with_no_location = results_with_no_location.
    sorted_results = results_with_location + results_with_no_location
  end

  def user_sort(users)
    users_with_location = users.where.not(latitude:nil, longitude:nil)
    users_with_no_location = users - users_with_location
    # users_2 = users.near(self, 2, unit: :km).order('distance DESC')
    # users_5 = users.near(self, 5, unit: :km).order('distance DESC') - users_2
    # users_10 = users.near(self, 10, unit: :km).order('distance DESC') - users_5 - users_2
    # users_20 = users.near(self, 20, unit: :km).order('distance DESC') - users_10 - users_5 - users_2
    # users_40 = users.near(self, 40, unit: :km).order('distance DESC') - users_20 - users_10 - users_5 - users_2
    # users_60 = users.near(self, 60, unit: :km).order('distance DESC') - users_40 - users_20 - users_10 - users_5 - users_2
    # logger.info "2km : " + users_2.length.to_s + "\n" +
    #             "5km : " + users_5.length.to_s + "\n" +
    #             "10km: " + users_10.length.to_s + "\n" +
    #             "20km: " + users_20.length.to_s + "\n" +
    #             "40km: " + users_40.length.to_s + "\n" +
    #             "60km: " + users_60.length.to_s
    result_users = users.near(self, 60, :units => :km).order('distance DESC')
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
      json.layer_id layer_id

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
