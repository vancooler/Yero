class AddLocationToShoutComments < ActiveRecord::Migration
  def change
  	add_column :shout_comments, :latitude, :float
  	add_column :shout_comments, :longitude, :float
  end
end
