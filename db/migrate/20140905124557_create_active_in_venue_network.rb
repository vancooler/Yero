class CreateActiveInVenueNetwork < ActiveRecord::Migration
  def change
    create_table :active_in_venue_networks do |t|
      t.integer       :venue_network_id,      null: false
      t.integer       :user_id,               null: false
      t.datetime      :last_activity,         null: false,     default: Time.now
      t.datetime      :enter_time,            null: false,     default: Time.now
      t.integer       :active_status,         :default => 1
    end
  end
  
end
