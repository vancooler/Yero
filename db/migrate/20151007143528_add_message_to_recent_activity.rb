class AddMessageToRecentActivity < ActiveRecord::Migration
  def change
  	add_column :recent_activities, :deep_link, :string
  	add_column :recent_activities, :message, :text
  end
end
