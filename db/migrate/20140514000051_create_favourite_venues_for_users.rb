class CreateFavouriteVenuesForUsers < ActiveRecord::Migration
  def change
    create_table :favourite_venues do |t|
      t.integer :user_id
      t.integer :venue_id
    end
  end
end
