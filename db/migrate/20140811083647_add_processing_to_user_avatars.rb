class AddProcessingToUserAvatars < ActiveRecord::Migration
  def change
    add_column :user_avatars, :processing, :boolean
  end
end
