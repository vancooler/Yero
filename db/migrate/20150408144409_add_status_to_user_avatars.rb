class AddStatusToUserAvatars < ActiveRecord::Migration
  def change
  	add_column :user_avatars, :is_active, :boolean, default: true
  end
end
