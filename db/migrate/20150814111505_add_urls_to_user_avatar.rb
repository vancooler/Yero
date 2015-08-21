class AddUrlsToUserAvatar < ActiveRecord::Migration
  def change
  	add_column :users, :fake_user, :boolean, default: false
  	add_column :user_avatars, :origin_url, :text
  	add_column :user_avatars, :thumb_url, :text
  end
end