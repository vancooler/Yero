class AddContentToRecentActivity < ActiveRecord::Migration
  def change
  	remove_column :recent_activities, :deep_link
  	add_column :recent_activities, :content_type, :string
  	add_column :recent_activities, :content_id, :integer
  end
end
