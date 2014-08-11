class AddImageProcessedToUserAvatars < ActiveRecord::Migration
  def change
    add_column :user_avatars, :image_processed, :boolean
  end
end
