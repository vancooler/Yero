class CreateChattingMessages < ActiveRecord::Migration
  def change
    create_table :chatting_messages do |t|
        t.integer  :speaker_id,                 null: false
        t.integer  :whisper_id,                 null: false
        t.text     :message
        t.boolean  :read,       default: false
        t.timestamps
    end

    add_index :chatting_messages, ["whisper_id"], :name => "index_chatting_messages_on_whisper_id"

  end

  
end