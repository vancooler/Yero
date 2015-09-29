class AddPusherPrivateOnlineToUser < ActiveRecord::Migration
  def change
  	add_column :users, :pusher_private_online, :boolean, default: false
  end
end
