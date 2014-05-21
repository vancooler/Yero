class MultipleAvatars < ActiveRecord::Migration
  def change
    create_table :user_avatars do |t|
      t.integer :user_id
      t.string  :avatar
      t.boolean :default, default: false
      t.timestamps
    end
  end
end
