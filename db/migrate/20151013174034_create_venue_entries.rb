class CreateVenueEntries < ActiveRecord::Migration
  def change
    create_table :venue_entries do |t|
      t.references :venue, index: true
      t.references :user
      t.timestamps
    end
  end
end
