class Whisper < ActiveRecord::Base
  validates_presence_of :origin_id, :target_id
  after_save :send_push_notification_to_target_user

  def send_push_notification_to_target_user
    #this shall be refactored once we have more phones to test with
    app_local_path = Rails.root

    origin_user = User.find(self.origin_id)
    target_user = User.find(self.target_id)

    apn = Houston::Client.development
    apn.certificate = File.read("#{app_local_path}/apple_push_notification.pem")

    # An example of the token sent back when a device registers for notifications
    token = User.find(self.target_id).apn_token # "<443e69367fbbbce9c722fdf392f72af2111bde5626a916007d97382687d4b029>"
    # Create a notification that alerts a message to the user, plays a sound, and sets the badge on the app
    notification = Houston::Notification.new(device: token)
    notification.alert = "Hi #{target_user.first_name || "Whisper User"}, You got a Whisper!"

    # Notifications can also change the badge count, have a custom sound, have a category identifier, indicate available Newsstand content, or pass along arbitrary data.
    notification.badge = 1
    notification.sound = "sosumi.aiff"
    notification.category = "INVITE_CATEGORY"
    notification.content_available = true
    notification.custom_data = {
          whisper_id: self.id,
          origin_user: origin_user.key,
          target_user: target_user.key,
          target_apn: token,
          viewed: self.viewed,
          accepted: self.accepted
      }
    # And... sent! That's all it takes.
    apn.push(notification)

  end

end
