class AddArchieveToWhisperToday < ActiveRecord::Migration
  def change
  	add_column :whisper_todays, :target_user_archieve, :boolean, default: false
  	add_column :whisper_todays, :origin_user_archieve, :boolean, default: false
  	add_column :whisper_replies, :read, :boolean, default: false
  end
end
