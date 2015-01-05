class CreateVenueAvatars < ActiveRecord::Migration
  def change
    create_table :venue_avatars do |t|
    	t.integer :venue_id
    	t.string :avatar
    	t.boolean :default
    	t.timestamps
    end
  end
end
