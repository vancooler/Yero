class CreateWhisperToday < ActiveRecord::Migration
  def change
    create_table :whisper_todays do |t|
      t.integer     :target_user_id,              null: false
      t.integer     :origin_user_id
      t.integer		:venue_id
      t.integer		:whisper_type,              null: false
      t.boolean		:viewed, 					default: false
      t.boolean		:accepted, 					default: false
      t.boolean		:declined, 					default: false 
      t.text		:message,					default: ""     
      t.timestamps
    end

    add_index :whisper_todays, :target_user_id
  end
  
end
