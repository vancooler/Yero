class NotificationPreference < ActiveRecord::Base
  # A beacon has a unique ID

  has_many :user_notification_preference, dependent: :destroy

end