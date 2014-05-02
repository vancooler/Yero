class Winner < ActiveRecord::Base
  belongs_to :user
  belongs_to :venue

  before_create :create_key

  # create a unique key for API usagebefore create
  def create_key
    self.winner_id = loop do
      random_token = rand.to_s[2..6]
      break random_token unless Winner.exists?(winner_id: random_token)
    end
  end

  def send_notification
    if Rails.env.development?
      apn = Houston::Client.development
    else
      apn = Houston::Client.production
    end

    apn.certificate = AWS::S3.new.buckets[ENV['S3_BUCKET_NAME']].objects['private/cert.pem'].read

    token = self.user.apn_token

    notification = Houston::Notification.new(device: token)
    notification.alert = "You won a free drink!"

    apn.push(notification)
  end

  def to_json
    data = Jbuilder.encode do |json|
      json.birthday birthday
    end

    JSON.parse(data)
  end
end