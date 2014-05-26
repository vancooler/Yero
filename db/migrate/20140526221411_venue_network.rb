class VenueNetwork < ActiveRecord::Migration
  def change
    create_table :venue_networks do |t|
      t.string     :city
      t.integer    :area
      t.string     :name
      t.timestamps
    end

    add_column :venues, :venue_network_id, :integer
  end
end
