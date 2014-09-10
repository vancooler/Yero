class CreateActiveInVenue < ActiveRecord::Migration
  def change
    create_table :active_in_venues do |t|
      t.integer     :venue_id,              null: false
      t.integer     :user_id,               null: false
      t.datetime    :last_activity,         null: false,     default: Time.now
      t.datetime    :enter_time,            null: false,     default: Time.now
    end
  end
  
end
