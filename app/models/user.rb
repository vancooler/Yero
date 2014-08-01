class User < ActiveRecord::Base
  has_many :traffics
  has_many :winners
  has_many :pokes, foreign_key: "pokee_id"
  has_many :favourite_venues
  has_many :venues, through: :favourite_venues
  has_many :user_avatars
  accepts_nested_attributes_for :user_avatars
  has_one  :participant

  # mount_uploader :avatar, AvatarUploader
  before_create :create_key
  before_save   :update_activity

  validates :email, uniqueness: true
  validates :email, :birthday, :first_name, :gender, presence: true

  # create a unique key for API usagebefore create
  def create_key
    self.key = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless User.exists?(key: random_token)
    end
  end

  def venue_network
    if self.participant
      self.participant.room.venue.venue_network
    end
  end

  def default_avatar
    self.user_avatars.where(default: true).first
  end

  def create_layer_account
    cert = AWS::S3.new.buckets[ENV['S3_BUCKET_NAME']].objects['private/layer/layer.crt'].read
    key = AWS::S3.new.buckets[ENV['S3_BUCKET_NAME']].objects['private/layer/layer.key'].read

    require "net/https"
    require "uri"
    require "json"

    uri = URI "https://api-beta.layer.com/users"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.key = OpenSSL::PKey::RSA.new(key)
    http.cert = OpenSSL::X509::Certificate.new(cert)

    request = Net::HTTP::Post.new(uri.request_uri)

    data = [{ "id" => self.id, "access_token" => self.key }].to_json
    request.body = data
    request["Content-Type"] = "application/json"

    response = http.request(request)
    self.layer_id = JSON.parse(response.body)["users"][0]["layer_id"]
    
    save
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
