class AddAvatarProcessingToUserAvatars < ActiveRecord::Migration
  def change
    add_column :user_avatars, :avatar_processing, :boolean
  end
end
