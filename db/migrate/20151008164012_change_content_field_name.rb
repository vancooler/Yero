class ChangeContentFieldName < ActiveRecord::Migration
  def change
    rename_column :recent_activities, :content_type, :contentable_type
    rename_column :recent_activities, :content_id, :contentable_id
  end
end