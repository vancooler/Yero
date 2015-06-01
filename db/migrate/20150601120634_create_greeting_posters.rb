class CreateGreetingPosters < ActiveRecord::Migration
  def change
    create_table :greeting_posters do |t|
    	t.integer :greeting_message_id
    	t.string :avatar
    	t.boolean :default
    	t.timestamps
    end
  end
end