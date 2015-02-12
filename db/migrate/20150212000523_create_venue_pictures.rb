class CreateVenuePictures < ActiveRecord::Migration
  def change
    create_table :venue_pictures do |t|
    	t.string :pic_location
    	t.references :venue
    	t.timestamps
    end
  end
end
