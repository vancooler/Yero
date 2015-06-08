class CreatePresetGreetingImages < ActiveRecord::Migration
  def change
    create_table :preset_greeting_images do |t|
    	t.integer :greeting_message_id
    	t.string :avatar
    	t.boolean :is_active
    	t.timestamps
    end
  end
end