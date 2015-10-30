class AddClientSideIdToChattingMessage < ActiveRecord::Migration
  def change
  	add_column :chatting_messages, :client_side_id, :string
  end
end

