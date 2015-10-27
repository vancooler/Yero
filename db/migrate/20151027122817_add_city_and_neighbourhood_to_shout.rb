class AddCityAndNeighbourhoodToShout < ActiveRecord::Migration
  def change
  	add_column :shouts, :city, :string
  	add_column :shout_comments, :city, :string
  	add_column :shouts, :neighbourhood, :string
  	add_column :shout_comments, :neighbourhood, :string
  end
end

