class AddViewedToFriendByWhisper < ActiveRecord::Migration
  def change
  	add_column :friend_by_whispers, :viewed, :boolean
  end
end