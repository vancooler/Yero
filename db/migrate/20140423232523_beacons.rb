class Beacons < ActiveRecord::Migration
  def change
    create_table(:beacons) do |t|
      t.integer :room_id,               null: false
      t.string  :key,                   null: false
      t.string  :name
      t.string  :type
    end

    create_table(:rooms) do |t|
      t.integer :venue_id,              null: false
    end

    create_table(:traffics) do |t|
      t.integer :room_id,               null: false
      t.integer :beacon_id,             null: false
      t.integer :user_id,               null: false
      t.string  :location,              null: false
    end
  end
end
