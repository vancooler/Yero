class AddBeaconToActiveInVenue < ActiveRecord::Migration
  def change
    add_column :active_in_venues, :beacon_id, :integer
  end
end