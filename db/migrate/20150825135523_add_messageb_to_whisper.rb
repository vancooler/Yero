class AddMessagebToWhisper < ActiveRecord::Migration
  def change
  	add_column :whisper_todays, :message_b, :text
  end
end