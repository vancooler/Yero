class AddNetworkToShouts < ActiveRecord::Migration
  def change
  	add_column :shouts, :allow_nearby, :boolean
  	add_column :shouts, :latitude, :float
  	add_column :shouts, :longitude, :float
  	add_column :shouts, :venue_id, :integer
  end
end
