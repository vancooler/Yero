class AddPaperOwnerIdsToWhisper < ActiveRecord::Migration
  def change
  	add_column :whisper_sents, :paper_owner_id, :integer
  	add_column :whisper_todays, :paper_owner_id, :integer
  end
end