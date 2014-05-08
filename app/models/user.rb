class User < ActiveRecord::Base

  has_many :traffics
  has_many :winners
  has_many :pokes
  has_one  :participant

  mount_uploader :avatar, AvatarUploader
  before_create :create_key
  before_save   :update_activity

  validates :email, uniqueness: true
  validates :email, :birthday, :first_name, :last_initial, :gender, presence: true

  # create a unique key for API usagebefore create
  def create_key
    self.key = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless User.exists?(key: random_token)
    end
  end

  def age
    dob = self.birthday
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def to_json(with_key)
    data = Jbuilder.encode do |json|
      json.birthday birthday
      json.first_name first_name
      json.last_initial last_initial
      json.gender gender

      if avatar
        json.avatar avatar.thumb.url
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
