class CreateRecentActivity < ActiveRecord::Migration
  def change
    create_table :recent_activities do |t|
      t.integer     :target_user_id,              null: false
      t.integer     :origin_user_id
      t.integer		:venue_id
      t.string		:activity_type,              null: false
      t.timestamps
    end
  end
  
end
