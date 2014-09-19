class WhisperNotification < AWS::Record::HashModel
  string_attr :target_id
  string_attr :origin_id

  integer_attr :timestamp
  string_attr :created_date
  string_attr :venue_id
  string_attr :notification_type
  boolean_attr :viewed
  boolean_attr :accepted


  #create user's Notification log in AWS DynamoDB
  def self.create_in_aws(target_id, origin_id, venue_id, notification_type)

    n = WhisperNotification.new
    n.target_id = target_id
    n.origin_id = origin_id
    n.venue_id = venue_id
    n.notification_type = notification_type
    n.timestamp = Time.now
    n.created_date = Date.today.to_s
    n.viewed = false
    n.accepted = false
    n.save!

    return n
  end

  def self.read_notification(id, user)
    # mark as 'viewed' in aws dynamoDB notification table
    dynamo_db = AWS::DynamoDB.new
    table = dynamo_db.tables['WhisperNotification']
    table.load_schema
    #item = table.items[target_id.to_s, timestamp.to_i]
    item = table.items.where(:id).equals(id.to_s).first
    item.attributes.update do |u|
      u.set 'viewed' => 1
    end
    
    # number of notification to read for this user: -1
    if user.notification_read.nil? or user.notification_read <= 0
      user.notification_read = 0
    else
      user.notification_read = user.notification_read - 1
    end
    user.save
  end


  def send_push_notification_to_target_user(message)
    #this shall be refactored once we have more phones to test with
    app_local_path = Rails.root

    if self.origin_id != "0"
      origin_user = User.find(self.origin_id) 
      origin_user_key = origin_user.key
    else
      origin_user_key = "SYSTEM"
    end
    target_user = User.find(self.target_id) 

    apn = Houston::Client.development
    apn.certificate = File.read("#{app_local_path}/apple_push_notification.pem")

    # An example of the token sent back when a device registers for notifications
    token = User.find(self.target_id).apn_token # "<443e69367fbbbce9c722fdf392f72af2111bde5626a916007d97382687d4b029>"
    # Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
    notification = Houston::Notification.new(device: token)
    notification.alert = message # "Hi #{target_user.first_name || "Whisper User"}, You got a Whisper!"

    # Notifications can also change the badge count, have a custom sound, have a category identifier, indicate available Newsstand content, or pass along arbitrary data.
    notification.badge = 1
    notification.sound = "sosumi.aiff"
    notification.category = "INVITE_CATEGORY"
    notification.content_available = true
    notification.custom_data = {
          whisper_id: self.id,
          origin_user: origin_user_key,
          target_user: target_user.key,
          timestamp: self.timestamp,
          target_apn: token,
          viewed: self.viewed,
          accepted: self.accepted
      }
    # And... sent! That's all it takes.
    apn.push(notification)

  end

end