class AddVenueIdToBeacons < ActiveRecord::Migration
  def change
  	add_column :beacons, :venue_id, :integer
  end
end
