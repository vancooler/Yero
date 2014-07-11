class Winner < ActiveRecord::Base
  # A winner is a generic model for a User who has won something
  # Could be drinks, food, etc

  belongs_to :user
  belongs_to :venue

  before_create :create_key

  # Create a unique key for API usage before create.
  # The unique key will allow users to claim them when
  # showing the venue this key
  def create_key
    self.winner_id = loop do
      random_token = rand.to_s[2..6]
      break random_token unless Winner.exists?(winner_id: random_token)
    end
  end

  # TODO Create a claim_key method
  # def claim_key
  # end

  # Send a notification to the use through APNS
  def send_notification

    # TODO this seems hacky
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