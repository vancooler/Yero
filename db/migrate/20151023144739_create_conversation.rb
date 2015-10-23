class CreateConversation < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
        t.integer  :target_user_id,                       null: false
        t.integer  :origin_user_id
        t.integer  :venue_id
        t.integer  :whisper_type,                         null: false
        t.boolean  :viewed,               default: false
        t.boolean  :accepted,             default: false
        t.boolean  :declined,             default: false
        t.text     :message,              default: ""
        t.timestamps
        t.string   :dynamo_id
        t.integer  :paper_owner_id
        t.text     :message_b,            default: ""
        t.boolean  :target_user_archieve, default: false
        t.boolean  :origin_user_archieve, default: false
    end

    add_index :conversations, ["target_user_id"],     :name => "index_conversations_on_target_user_id"
  end
end