class AddVenueIdToBeacons < ActiveRecord::Migration
  def change
  	add_column :beacons, :venue_id, :integer
  	remove_column :beacons, :room_id, :integer
  	remove_columm :beacons, :room_type, :string
  end
end
