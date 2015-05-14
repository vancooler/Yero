class AddTimezoneToVenueNetwork < ActiveRecord::Migration
  def change
  	add_column :venue_networks, :timezone, :string
  end
end
