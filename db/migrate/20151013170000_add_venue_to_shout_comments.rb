class AddVenueToShoutComments < ActiveRecord::Migration
  def change
  	add_column :shout_comments, :venue_id, :integer
  end
end
