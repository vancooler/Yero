class CreateVenueTypes < ActiveRecord::Migration
  def change
    create_table :venue_types do |t|
      t.string :name

      t.timestamps
    end
  end
  def data
    VenueType.create!([{name: 'Club'},{name:'Lounge'},{name: 'Bar'}])
  end
end
