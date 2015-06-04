class AddDraftPendingToGreetingMessage < ActiveRecord::Migration
  def change
  	add_column :greeting_messages, :draft_pending, :boolean, default: false
  	add_column :greeting_messages, :pending_second_dj, :string
  	add_column :greeting_messages, :pending_first_dj, :string
  	add_column :greeting_messages, :pending_last_call, :string
  	add_column :greeting_messages, :pending_admission_fee, :float
  	add_column :greeting_messages, :pending_drink_special, :string
  	add_column :greeting_messages, :pending_description, :text
  	
  end
end
