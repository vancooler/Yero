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

  # mount_uploader :avatar, AvatarUploader
  before_save   :update_activity

  validates :birthday, :first_name, :gender, presence: true

  def current_venue
    Acitivity.for_user(self.id).todays_activities.with_beacons.last
    if activity.action == "Enter Beacon"
      activity.beacon.room.venue
    else
      nil
    end
  end

  def self.in_venue_now_for_user(user_key)
    venue_activities = Activity.at_venue_tonight(venue_id)
    active_user_id = []

    activities_grouped_by_user_ids = venue_activities.group_by { |a| a[:user_id] }
    # activities_grouped_by_user_ids = activities_grouped_by_user_ids.delete(User.find_by(user_key: user_key).id).delete
    activities_grouped_by_user_ids.each do |id_activity|
      ordered_user_activity = id_activity[1].sort_by!{|t| t[:created_at]}
      if ordered_user_activity.last.action == "Enter Beacon"
        qualified = true
      elsif ordered_user_activity.last.action == "Exit Beacon"
        qualified = true
      # todo
      # elsif exit && before timeout && entered
      #elsif if the current user is not in venue
      else
        qualified = false
      end
      active_user_id << id_activity[0] if qualified
    end
    where(id: active_user_id)
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
