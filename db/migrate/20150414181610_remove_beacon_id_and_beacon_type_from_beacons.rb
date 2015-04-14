class RemoveBeaconIdAndBeaconTypeFromBeacons < ActiveRecord::Migration
  def change
  	remove_column :beacons, :room_id, :integer
  	remove_column :beacons, :room_type, :string
  end
end
