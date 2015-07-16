class CreateNotificationPreference < ActiveRecord::Migration
  def change
    create_table(:notification_preferences) do |t|
      t.string :name,              null: false
      t.timestamps
    end

    add_index :notification_preferences, :name,                unique: true
  end
end
