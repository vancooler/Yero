class AddTmpToUserAvatars < ActiveRecord::Migration
  def change
  	add_column :user_avatars, :avatar_tmp, :string
  end
end
