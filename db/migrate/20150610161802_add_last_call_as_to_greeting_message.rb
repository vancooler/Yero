class AddLastCallAsToGreetingMessage < ActiveRecord::Migration
  def change
  	add_column :greeting_messages, :last_call_as, :string
  	add_column :greeting_messages, :pending_last_call_as, :string
  	add_column :preset_greeting_images, :default_template, :boolean, default: false
  end
end
