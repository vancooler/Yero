class AddNotificationReadToUsers < ActiveRecord::Migration
  def change
    add_column :users, :notification_read, :integer
  end
end