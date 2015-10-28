class AddLastPushTimeToConversation < ActiveRecord::Migration
  def change
  	add_column :conversations, :last_target_user_push_time, :integer
  	add_column :conversations, :last_origin_user_push_time, :integer
  end
end

