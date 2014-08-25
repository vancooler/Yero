class RemoveNonNilConstraintOfVenueIdInRoomsForTesting < ActiveRecord::Migration
  def change
    change_column :rooms, :venue_id, :integer, :null => true
  end
end
