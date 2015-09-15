class AddDefaultToNotificationPreference < ActiveRecord::Migration
  def change
  	add_column :notification_preferences, :default_value, :boolean
  end
end