class CreateVenueEnteredToday < ActiveRecord::Migration
  def change
    create_table :venue_entered_todays do |t|
      t.integer     :venue_id,              null: false
      t.integer     :user_id,               null: false
      t.datetime    :enter_time,            null: false,     default: Time.now
    end
  end
  
end
