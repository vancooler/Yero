class AddIndexToRecentActivity < ActiveRecord::Migration
  def change
    add_index :recent_activities, :target_user_id
  end
end