class CreateWhisperReply < ActiveRecord::Migration
  def change
    create_table :whisper_replies do |t|
      t.integer     :speaker_id,              null: false
      t.integer     :whisper_id,              null: false
      t.text		:message
      t.timestamps
    end


    add_index :whisper_replies, :whisper_id
  end
  
end
