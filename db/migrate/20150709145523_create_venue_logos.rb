class CreateVenueLogos < ActiveRecord::Migration
  def change
    create_table :venue_logos do |t|
    	t.integer :venue_id
    	t.string :avatar
    	t.boolean :pending
    	t.timestamps
    end
  end
end