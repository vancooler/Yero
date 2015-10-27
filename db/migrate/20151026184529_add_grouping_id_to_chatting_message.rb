class AddGroupingIdToChattingMessage < ActiveRecord::Migration
  def change
  	add_column :chatting_messages, :grouping_id, :integer
  end
end

