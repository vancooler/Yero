class CreateReadNotifications < ActiveRecord::Migration
  def change
    create_table :read_notifications do |t|
      t.references :user, index: true
      t.boolean :before_sending_whisper_notification

      t.timestamps
    end
  end
end
