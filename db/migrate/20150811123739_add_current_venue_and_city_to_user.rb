class AddCurrentVenueAndCityToUser < ActiveRecord::Migration
  def change
  	add_column :users, :current_venue, :string
  	add_column :users, :current_city, :string
  end
end