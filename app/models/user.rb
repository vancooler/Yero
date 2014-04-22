class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  mount_uploader :avatar, AvatarUploader
  before_create :create_key

  validates :email, uniqueness: true
  validates :email, :birthday, :first_name, :last_initial, :gender, presence: true

  def create_key
    self.key = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Api.exists?(key: random_token)
    end
  end

  def to_json(with_key)
    data = Jbuilder.encode do |json|
      json.birthday birthday
      json.first_name first_name
      json.last_initial last_initial
      json.gender gender
      json.avatar

      if with_key
        json.key = key
      end
    end

    JSON.parse(data)
  end
end
