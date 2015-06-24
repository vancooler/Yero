class AddEnoughUserSentTonightToUser < ActiveRecord::Migration
  def change
  	add_column :users, :enough_user_notification_sent_tonight, :boolean, default: false
  end
end
