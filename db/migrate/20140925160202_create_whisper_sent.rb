class CreateWhisperSent < ActiveRecord::Migration
  def change
    create_table :whisper_sents do |t|
      t.integer     :target_user_id,              null: false
      t.integer     :origin_user_id,               null: false
      t.datetime    :whisper_time,            null: false,     default: Time.now
    end
  end
  
end
