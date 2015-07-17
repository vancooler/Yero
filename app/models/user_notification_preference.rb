class UserNotificationPreference < ActiveRecord::Base
  belongs_to :notification_preference
  belongs_to :user
  validates_uniqueness_of :notification_preference_id, :scope => [:user_id]

  def self.update_preferences_settings(current_user, network_online, enter_venue_network, leave_venue_network)
  	n_o = NotificationPreference.find_by_name("Network online")

    if network_online 
      if n_o and current_user.user_notification_preference.where(:notification_preference_id => n_o.id).blank?
        # create
        UserNotificationPreference.create!(:notification_preference_id => n_o.id, :user_id => current_user.id)
      end
    else
      if n_o and !current_user.user_notification_preference.where(:notification_preference_id => n_o.id).blank?
        # remove
        current_user.user_notification_preference.where(:notification_preference_id => n_o.id).delete_all
      end
    end

    e_v_n = NotificationPreference.find_by_name("Enter venue network")
    if enter_venue_network 
      if e_v_n and current_user.user_notification_preference.where(:notification_preference_id => e_v_n.id).blank?
        # create
        UserNotificationPreference.create!(:notification_preference_id => e_v_n.id, :user_id => current_user.id)
      end
    else
      if e_v_n and !current_user.user_notification_preference.where(:notification_preference_id => e_v_n.id).blank?
        # remove
        current_user.user_notification_preference.where(:notification_preference_id => e_v_n.id).delete_all
      end
    end

    l_v_n = NotificationPreference.find_by_name("Leave venue network")
    if leave_venue_network
      if l_v_n and current_user.user_notification_preference.where(:notification_preference_id => l_v_n.id).blank?
        # create
        UserNotificationPreference.create!(:notification_preference_id => l_v_n.id, :user_id => current_user.id)
      end
    else
      if l_v_n and !current_user.user_notification_preference.where(:notification_preference_id => l_v_n.id).blank?
        # remove
        current_user.user_notification_preference.where(:notification_preference_id => l_v_n.id).delete_all
      end
    end
    return true
  end
end