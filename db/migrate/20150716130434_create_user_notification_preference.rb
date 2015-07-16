class CreateUserNotificationPreference < ActiveRecord::Migration
  def change
    create_table :user_notification_preferences do |t|
      t.integer     :notification_preference_id,              null: false
      t.integer     :user_id,               null: false
      t.timestamps
    end
  end
  
end