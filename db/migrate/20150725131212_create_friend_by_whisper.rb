class CreateFriendByWhisper < ActiveRecord::Migration
  def change
    create_table :friend_by_whispers do |t|
      t.integer     :target_user_id,              null: false
      t.integer     :origin_user_id,               null: false
      t.datetime    :friend_time,            null: false,     default: Time.now
    end
  end
  
end
