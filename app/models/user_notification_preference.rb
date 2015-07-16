class UserNotificationPreference < ActiveRecord::Base
  belongs_to :notification_preference
  belongs_to :user


  
end